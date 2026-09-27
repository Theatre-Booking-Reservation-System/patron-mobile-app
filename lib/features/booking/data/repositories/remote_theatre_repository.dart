import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';

class RemoteTheatreRepository implements TheatreRepository {
  RemoteTheatreRepository(this._client, this._sessionStore);

  final TheatreApiClient _client;
  final AuthSessionStore _sessionStore;
  List<Production>? _programmeCache;
  List<SeatZoneDto>? _zoneCache;

  @override
  Future<List<Production>> getProductions() async {
    final productionDtos = await _client.getProductions();
    final enriched = await Future.wait(
      productionDtos.map((production) async {
        final performances = await _client.getPerformances(production.id);
        return production.withPerformances(
          performances.where((item) => item.status != 9).toList(),
        );
      }),
    );
    final productions = enriched
        .where((item) => item.status != 9)
        .map(_mapProduction)
        .toList(growable: false);
    _programmeCache = productions;
    return productions;
  }

  @override
  Future<List<Seat>> getSeats(
    Production production,
    Performance performance,
  ) async {
    final results = await Future.wait<Object>([
      _client.getSeatMap(performance.id),
      _getSeatZones(),
    ]);
    final seatDtos = results[0] as List<SeatDto>;
    final zones = results[1] as List<SeatZoneDto>;
    final zonesById = {for (final zone in zones) zone.id: zone};

    return seatDtos
        .map((dto) {
          final zone = _resolveZone(dto, zonesById, zones);
          final multiplier = switch (performance.session) {
            PerformanceSession.matinee => zone?.matineePercent,
            PerformanceSession.evening => zone?.eveningPercent,
          };
          if (multiplier == null) {
            throw ApiException(
              ApiFailureType.invalidResponse,
              message: 'Seat ${dto.id} references an unknown zone.',
            );
          }
          return Seat(
            id: dto.id,
            bookingSeatId: dto.bookingSeatId,
            section: _seatSection(dto.section),
            row: dto.row,
            number: dto.number,
            zoneName: dto.zoneName ?? zone!.name,
            multiplierPercent: multiplier,
            netPrice: (production.baseTicketCost * multiplier / 100).round(),
            status: _seatStatus(dto.status),
            isAccessible: dto.isAccessible,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<Booking> confirmBooking({
    required BookingDraft draft,
    required PatronDetails patron,
    required BookingQuote quote,
  }) async {
    final session = await _requireSession();
    final currentSeats = await getSeats(draft.production, draft.performance);
    final currentById = {for (final seat in currentSeats) seat.id: seat};
    final unavailable = draft.seats.any(
      (selected) => currentById[selected.id]?.status != SeatStatus.available,
    );
    if (unavailable) {
      throw const ApiException(
        ApiFailureType.conflict,
        message: 'One or more selected seats are no longer available.',
      );
    }

    final request = BookingRequestDto(
      patronId:
          session.userId ??
          (throw const ApiException(
            ApiFailureType.unauthenticated,
            message: 'The signed-in patron id is unavailable.',
          )),
      performanceId: draft.performance.id,
      seats: draft.seats
          .map(
            (seat) => BookingSeatRequestDto(
              seatId: seat.bookingSeatId ?? seat.id,
              seatReference: '${seat.row}${seat.number}',
              zoneName: seat.zoneName,
              section: _seatSectionToApi(seat.section),
            ),
          )
          .toList(growable: false),
      ticketType: quote.loyaltyTotal > 0
          ? 'LOYALTY'
          : draft.seats.length >= 10
          ? 'GROUP'
          : 'REGULAR',
      paymentMethod: 'CREDIT_CARD',
      paymentDetails: PaymentDetailsDto(
        cardNumber: '4111111111111111',
        expiry: '12/30',
        cvv: '123',
        cardHolderName: patron.name,
      ),
    );
    final response = await _client.createBooking(request);
    return _mapBooking(
      response,
      production: draft.production,
      performance: draft.performance,
      seats: draft.seats,
      quote: quote,
      fallbackEmail: patron.email,
    );
  }

  @override
  Future<List<Booking>> getBookings() async {
    final session = await _requireSession();
    final patronId = session.userId;
    if (patronId == null || patronId.isEmpty) {
      throw const ApiException(
        ApiFailureType.unauthenticated,
        message: 'The signed-in patron id is unavailable.',
      );
    }
    final summaries = await _client.getBookings(patronId);
    return Future.wait(
      summaries.map((summary) async {
        final context = await _resolvePerformance(summary.performanceId);
        return Booking(
          id: summary.id,
          reference: summary.reference,
          production: context.production,
          performance: context.performance,
          seats: const [],
          total: summary.total,
          status: _bookingStatus(summary.status),
          paymentStatus: _paymentStatus(summary.paymentStatus),
          createdAt: summary.createdAt,
          patronEmail: session.email,
          isFlagged: false,
        );
      }),
    );
  }

  @override
  Future<Booking> getBooking(String reference) async {
    final response = await _client.getBooking(reference);
    return _enrichBooking(response);
  }

  @override
  Future<Booking> cancelBooking(Booking booking) async {
    final response = await _client.cancelBooking(booking.id);
    return _enrichBooking(response);
  }

  Future<List<SeatZoneDto>> _getSeatZones() async =>
      _zoneCache ??= await _client.getSeatZones();

  SeatZoneDto? _resolveZone(
    SeatDto seat,
    Map<String, SeatZoneDto> zonesById,
    List<SeatZoneDto> zones,
  ) {
    final zoneId = seat.zoneId;
    if (zoneId != null) {
      final matchingId = zonesById[zoneId];
      if (matchingId != null) return matchingId;
    }

    final zoneName = seat.zoneName?.trim().toLowerCase();
    if (zoneName == null) return null;
    for (final zone in zones) {
      if (zone.section == seat.section &&
          zone.name.trim().toLowerCase() == zoneName) {
        return zone;
      }
    }
    return null;
  }

  Future<AuthSessionData> _requireSession() async {
    final session = await _sessionStore.read();
    if (session == null) {
      throw const ApiException(ApiFailureType.unauthenticated);
    }
    return session;
  }

  Future<({Production production, Performance performance})>
  _resolvePerformance(String performanceId) async {
    final productions = _programmeCache ?? await getProductions();
    for (final production in productions) {
      for (final performance in production.performances) {
        if (performance.id == performanceId) {
          return (production: production, performance: performance);
        }
      }
    }
    throw ApiException(
      ApiFailureType.invalidResponse,
      message: 'No catalogue performance exists for $performanceId.',
    );
  }

  Future<Booking> _enrichBooking(BookingDto response) async {
    final context = await _resolvePerformance(response.performanceId);
    final availableSeats = await getSeats(
      context.production,
      context.performance,
    );
    final byId = {
      for (final seat in availableSeats) seat.id: seat,
      for (final seat in availableSeats)
        if (seat.bookingSeatId != null) seat.bookingSeatId!: seat,
    };
    final ticketLines = response.lines
        .map((line) {
          final seat =
              byId[line.performanceSeatId] ??
              Seat(
                id: line.performanceSeatId,
                section: SeatSection.stalls,
                row: line.seatReference,
                number: 0,
                zoneName: line.zoneName,
                multiplierPercent: 100,
                netPrice: line.basePrice,
                status: SeatStatus.booked,
              );
          return TicketPrice(
            seat: seat,
            concession: _concessionFromApi(line.concessionType),
            concessionDiscount: line.concessionDiscount,
            loyaltyDiscount: line.loyaltyDiscount,
            netAfterDiscounts:
                line.basePrice - line.concessionDiscount - line.loyaltyDiscount,
            vatAmount: line.vat,
            total: line.finalPrice,
          );
        })
        .toList(growable: false);
    final responseSeats = response.seats
        .map((item) => byId[item.seatId] ?? _fallbackBookingSeat(item))
        .toList(growable: false);
    final session = await _sessionStore.read();
    return _mapBooking(
      response,
      production: context.production,
      performance: context.performance,
      seats: ticketLines.isNotEmpty
          ? ticketLines.map((line) => line.seat).toList(growable: false)
          : responseSeats,
      quote: ticketLines.isEmpty
          ? null
          : BookingQuote(lines: ticketLines, vatPercent: 18),
      fallbackEmail: session?.email ?? '',
    );
  }

  Booking _mapBooking(
    BookingDto dto, {
    required Production production,
    required Performance performance,
    required List<Seat> seats,
    BookingQuote? quote,
    required String fallbackEmail,
  }) => Booking(
    id: dto.id,
    reference: dto.reference,
    production: production,
    performance: performance,
    seats: seats,
    quote: quote,
    total: dto.total,
    status: _bookingStatus(dto.status),
    paymentStatus: _paymentStatus(dto.paymentStatus),
    createdAt: dto.createdAt,
    patronEmail: dto.guestEmail ?? fallbackEmail,
    isFlagged: dto.isFlagged,
    ticketType: dto.ticketType,
    cardLast4: dto.cardLast4,
    qrCode: dto.qrCode,
  );

  Production _mapProduction(ProductionDto dto) => Production(
    id: dto.id,
    title: LocalizedText(
      en: dto.title['en'] ?? '',
      si: dto.title['si'] ?? '',
      ta: dto.title['ta'] ?? '',
    ),
    synopsis: LocalizedText(
      en: dto.synopsis['en'] ?? '',
      si: dto.synopsis['si'] ?? '',
      ta: dto.synopsis['ta'] ?? '',
    ),
    language: _productionLanguage(dto.language),
    genre: dto.genre,
    baseTicketCost: dto.baseTicketCost,
    posterImageUrl: dto.posterImageUrl,
    releaseDate: dto.releaseDate,
    performances: dto.performances.map(_mapPerformance).toList(growable: false),
  );

  Performance _mapPerformance(PerformanceDto dto) => Performance(
    id: dto.id,
    dateTime: dto.dateTime,
    session: _performanceSession(dto.session),
  );
}

Seat _fallbackBookingSeat(BookingSeatDto item) {
  final match = RegExp(r'^(.*?)(\d+)$').firstMatch(item.seatReference);
  return Seat(
    id: item.seatId,
    bookingSeatId: item.seatId,
    section: _bookingSection(item.section),
    row: match?.group(1) ?? item.seatReference,
    number: int.tryParse(match?.group(2) ?? '') ?? 0,
    zoneName: item.zoneName,
    multiplierPercent: 100,
    netPrice: 0,
    status: SeatStatus.booked,
  );
}

String _seatSectionToApi(SeatSection value) => switch (value) {
  SeatSection.stalls => 'STALLS',
  SeatSection.circle => 'CIRCLE',
  SeatSection.upperCircle => 'UPPER_CIRCLE',
};

SeatSection _bookingSection(String value) => switch (value.toUpperCase()) {
  'CIRCLE' => SeatSection.circle,
  'UPPER_CIRCLE' || 'UPPERCIRCLE' => SeatSection.upperCircle,
  _ => SeatSection.stalls,
};

ProductionLanguage _productionLanguage(String value) => switch (value) {
  'sinhala' => ProductionLanguage.sinhala,
  'tamil' => ProductionLanguage.tamil,
  'english' => ProductionLanguage.english,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported production language: $value',
  ),
};

PerformanceSession _performanceSession(String value) => switch (value) {
  'matinee' => PerformanceSession.matinee,
  'evening' => PerformanceSession.evening,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported performance session: $value',
  ),
};

SeatSection _seatSection(String value) => switch (value) {
  'stalls' => SeatSection.stalls,
  'circle' => SeatSection.circle,
  'upperCircle' => SeatSection.upperCircle,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported seat section: $value',
  ),
};

SeatStatus _seatStatus(String value) => switch (value) {
  'available' => SeatStatus.available,
  'held' => SeatStatus.held,
  'booked' => SeatStatus.booked,
  'unavailable' => SeatStatus.unavailable,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported seat status: $value',
  ),
};

BookingStatus _bookingStatus(String value) => switch (value) {
  'PENDING' => BookingStatus.pending,
  'CONFIRMED' => BookingStatus.confirmed,
  'CANCELLED_PATRON' => BookingStatus.cancelledPatron,
  'CANCELLED_ADMIN' => BookingStatus.cancelledAdmin,
  'EXPIRED' => BookingStatus.expired,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported booking status: $value',
  ),
};

PaymentStatus _paymentStatus(String value) => switch (value) {
  'UNPAID' => PaymentStatus.unpaid,
  'PAID' => PaymentStatus.paid,
  'REFUNDED' => PaymentStatus.refunded,
  'FAILED' => PaymentStatus.failed,
  _ => throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Unsupported payment status: $value',
  ),
};

ConcessionType _concessionFromApi(String? value) => switch (value) {
  'UNDER_16' => ConcessionType.under16,
  'OVER_70' => ConcessionType.over70,
  'LARGE_PARTY' => ConcessionType.largeParty,
  _ => ConcessionType.none,
};
