import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/services/seat_zone_resolver.dart';

class MockTheatreRepository implements TheatreRepository {
  MockTheatreRepository(this._client);

  final TheatreApiClient _client;
  final List<Booking> _bookings = [];
  int _referenceCounter = 125;

  @override
  Future<List<Production>> getProductions() async =>
      (await _client.getProductions())
          .map(_mapProduction)
          .toList(growable: false);

  @override
  Future<List<Seat>> getSeats(
    Production production,
    Performance performance,
  ) async {
    final seats = await _client.getSeatMap(performance.id);
    return seats
        .map((dto) {
          final section = SeatSection.values.byName(dto.section);
          final zone = SeatZoneResolver.resolve(section, dto.row, dto.number);
          final multiplier = zone.multiplier(performance.session);
          return Seat(
            id: dto.id,
            bookingSeatId: dto.bookingSeatId,
            section: section,
            row: dto.row,
            number: dto.number,
            zoneName: zone.name,
            multiplierPercent: multiplier,
            netPrice: (production.baseTicketCost * multiplier / 100).round(),
            status: SeatStatus.values.byName(dto.status),
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final reference = 'ST-${DateTime.now().year}-${_referenceCounter++}';
    final booking = Booking(
      id: reference,
      reference: reference,
      production: draft.production,
      performance: draft.performance,
      seats: draft.seats,
      quote: quote,
      total: quote.total,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      createdAt: DateTime.now(),
      patronEmail: patron.email,
      isFlagged: patron.isFlagged,
    );
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<List<Booking>> getBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return List.unmodifiable(_bookings);
  }

  @override
  Future<Booking> getBooking(String reference) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    for (final booking in _bookings) {
      if (booking.reference.toLowerCase() == reference.toLowerCase()) {
        return booking;
      }
    }
    throw StateError('Booking not found.');
  }

  @override
  Future<Booking> cancelBooking(Booking booking) async {
    final cancelled = Booking(
      id: booking.id,
      reference: booking.reference,
      production: booking.production,
      performance: booking.performance,
      seats: booking.seats,
      quote: booking.quote,
      total: booking.total,
      status: BookingStatus.cancelledPatron,
      paymentStatus: booking.paymentStatus == PaymentStatus.paid
          ? PaymentStatus.refunded
          : booking.paymentStatus,
      createdAt: booking.createdAt,
      patronEmail: booking.patronEmail,
      isFlagged: booking.isFlagged,
      ticketType: booking.ticketType,
      cardLast4: booking.cardLast4,
      qrCode: booking.qrCode,
    );
    final index = _bookings.indexWhere((item) => item.id == booking.id);
    if (index >= 0) _bookings[index] = cancelled;
    return cancelled;
  }

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
    language: ProductionLanguage.values.byName(dto.language),
    genre: dto.genre,
    baseTicketCost: dto.baseTicketCost,
    posterImageUrl: dto.posterImageUrl,
    releaseDate: dto.releaseDate,
    performances: dto.performances.map(_mapPerformance).toList(growable: false),
  );

  Performance _mapPerformance(PerformanceDto dto) => Performance(
    id: dto.id,
    dateTime: dto.dateTime,
    session: PerformanceSession.values.byName(dto.session),
  );
}
