import 'package:patron_mobile_app/core/network/api_exception.dart';

class ProductionDto {
  const ProductionDto({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.language,
    required this.genre,
    required this.baseTicketCost,
    required this.performances,
    this.posterImageUrl,
    this.releaseDate,
    this.status = 1,
  });

  factory ProductionDto.fromJson(Map<String, Object?> json) {
    final legacyTitle = _map(json['title']);
    final legacySynopsis = _map(json['synopsis']);
    final scalarTitle = _string(json, 'title');
    final scalarDescription = _string(json, 'description');
    final rawPerformances = _list(json['performances']);
    return ProductionDto(
      id: _requiredString(
        json,
        json.containsKey('productionId') ? 'productionId' : 'id',
      ),
      title: {
        'en':
            _string(json, 'titleEn') ??
            _mapString(legacyTitle, 'en').nullIfEmpty ??
            scalarTitle ??
            '',
        'si': _string(json, 'titleSi') ?? _mapString(legacyTitle, 'si'),
        'ta': _string(json, 'titleTa') ?? _mapString(legacyTitle, 'ta'),
      },
      synopsis: {
        'en':
            _string(json, 'descriptionEn') ??
            _mapString(legacySynopsis, 'en').nullIfEmpty ??
            scalarDescription ??
            '',
        'si':
            _string(json, 'descriptionSi') ?? _mapString(legacySynopsis, 'si'),
        'ta':
            _string(json, 'descriptionTa') ?? _mapString(legacySynopsis, 'ta'),
      },
      language: _requiredString(json, 'language').toLowerCase(),
      genre: _string(json, 'genre') ?? '',
      baseTicketCost: _number(json, 'baseTicketCost').round(),
      posterImageUrl: _nullableNonEmptyString(json, 'posterImageUrl'),
      releaseDate: _optionalDate(json, 'releaseDate'),
      status: _int(json, 'status') ?? 1,
      performances: rawPerformances
          .map(PerformanceDto.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final Map<String, String> title;
  final Map<String, String> synopsis;
  final String language;
  final String genre;
  final int baseTicketCost;
  final String? posterImageUrl;
  final DateTime? releaseDate;
  final int status;
  final List<PerformanceDto> performances;

  ProductionDto withPerformances(List<PerformanceDto> value) => ProductionDto(
    id: id,
    title: title,
    synopsis: synopsis,
    language: language,
    genre: genre,
    baseTicketCost: baseTicketCost,
    posterImageUrl: posterImageUrl,
    releaseDate: releaseDate,
    status: status,
    performances: value,
  );
}

class PerformanceDto {
  const PerformanceDto({
    required this.id,
    required this.dateTime,
    required this.session,
    this.productionId,
    this.status = 1,
  });

  factory PerformanceDto.fromJson(Map<String, Object?> json) {
    final legacyDateTime = _string(json, 'dateTime');
    final date = _string(json, 'date');
    final time = _string(json, 'time');
    final parsedDateTime = legacyDateTime != null
        ? DateTime.parse(legacyDateTime)
        : DateTime.parse(
            '${date ?? _missing('date')}T${time ?? _missing('time')}',
          );
    return PerformanceDto(
      id: _requiredString(
        json,
        json.containsKey('performanceId') ? 'performanceId' : 'id',
      ),
      productionId: _nullableNonEmptyString(json, 'productionId'),
      dateTime: parsedDateTime,
      session: _requiredString(
        json,
        json.containsKey('sessionType') ? 'sessionType' : 'session',
      ).toLowerCase(),
      status: _int(json, 'status') ?? 1,
    );
  }

  final String id;
  final String? productionId;
  final DateTime dateTime;
  final String session;
  final int status;
}

class SeatZoneDto {
  const SeatZoneDto({
    required this.id,
    required this.section,
    required this.name,
    required this.matineePercent,
    required this.eveningPercent,
  });

  factory SeatZoneDto.fromJson(Map<String, Object?> json) => SeatZoneDto(
    id: _requiredString(json, 'zoneId'),
    section: _normalizeSection(_requiredString(json, 'section')),
    name: _requiredString(json, 'zoneName'),
    matineePercent: _number(json, 'matineePct').round(),
    eveningPercent: _number(json, 'eveningPct').round(),
  );

  final String id;
  final String section;
  final String name;
  final int matineePercent;
  final int eveningPercent;
}

class SeatDto {
  const SeatDto({
    required this.id,
    required this.section,
    required this.row,
    required this.number,
    required this.status,
    required this.isAccessible,
    this.bookingSeatId,
    this.zoneId,
    this.zoneName,
  });

  factory SeatDto.fromJson(Map<String, Object?> json) => SeatDto(
    id: _requiredString(
      json,
      json.containsKey('perfSeatId')
          ? 'perfSeatId'
          : json.containsKey('seatId')
          ? 'seatId'
          : 'id',
    ),
    bookingSeatId: _nullableNonEmptyString(json, 'seatId'),
    zoneId: _nullableNonEmptyString(json, 'zoneId'),
    section: _normalizeSection(_requiredString(json, 'section')),
    zoneName: _nullableNonEmptyString(json, 'zoneName'),
    row: _requiredString(
      json,
      json.containsKey('rowLabel') ? 'rowLabel' : 'row',
    ),
    number: _requiredInt(
      json,
      json.containsKey('seatNumber') ? 'seatNumber' : 'number',
    ),
    status: _normalizeSeatStatus(_requiredString(json, 'status')),
    isAccessible:
        _bool(json, 'wheelchairSpace') ?? _bool(json, 'isAccessible') ?? false,
  );

  final String id;
  final String? bookingSeatId;
  final String? zoneId;
  final String section;
  final String? zoneName;
  final String row;
  final int number;
  final String status;
  final bool isAccessible;
}

class BookingSeatRequestDto {
  const BookingSeatRequestDto({
    required this.seatId,
    required this.seatReference,
    required this.zoneName,
    required this.section,
  });

  final String seatId;
  final String seatReference;
  final String zoneName;
  final String section;

  Map<String, Object?> toJson() => {
    'seatId': seatId,
    'seatRef': seatReference,
    'zoneName': zoneName,
    'section': section,
  };
}

class PaymentDetailsDto {
  const PaymentDetailsDto({
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.cardHolderName,
  });

  final String cardNumber;
  final String expiry;
  final String cvv;
  final String cardHolderName;

  Map<String, Object?> toJson() => {
    'cardNumber': cardNumber,
    'expiry': expiry,
    'cvv': cvv,
    'cardHolderName': cardHolderName,
  };
}

class BookingRequestDto {
  const BookingRequestDto({
    required this.patronId,
    required this.performanceId,
    required this.seats,
    required this.ticketType,
    required this.paymentMethod,
    required this.paymentDetails,
  });

  final String patronId;
  final String performanceId;
  final List<BookingSeatRequestDto> seats;
  final String ticketType;
  final String paymentMethod;
  final PaymentDetailsDto paymentDetails;

  Map<String, Object?> toJson() => {
    'patronId': patronId,
    'performanceId': performanceId,
    'seats': seats.map((seat) => seat.toJson()).toList(growable: false),
    'ticketType': ticketType,
    'paymentMethod': paymentMethod,
    'paymentDetails': paymentDetails.toJson(),
  };
}

class BookingLineDto {
  const BookingLineDto({
    required this.performanceSeatId,
    required this.seatReference,
    required this.zoneName,
    required this.sessionType,
    required this.basePrice,
    required this.concessionDiscount,
    required this.loyaltyDiscount,
    required this.vat,
    required this.finalPrice,
    this.concessionType,
  });

  factory BookingLineDto.fromJson(Map<String, Object?> json) => BookingLineDto(
    performanceSeatId: _requiredString(json, 'perfSeatId'),
    seatReference: _string(json, 'seatRef') ?? '',
    zoneName: _string(json, 'zoneName') ?? '',
    sessionType: _string(json, 'sessionType') ?? '',
    concessionType: _nullableNonEmptyString(json, 'concessionType'),
    basePrice: _number(json, 'basePriceLkr').round(),
    concessionDiscount: _number(json, 'concessionDiscLkr').round(),
    loyaltyDiscount: _number(json, 'loyaltyDiscLkr').round(),
    vat: _number(json, 'vatLkr').round(),
    finalPrice: _number(json, 'finalPriceLkr').round(),
  );

  final String performanceSeatId;
  final String seatReference;
  final String zoneName;
  final String sessionType;
  final String? concessionType;
  final int basePrice;
  final int concessionDiscount;
  final int loyaltyDiscount;
  final int vat;
  final int finalPrice;
}

class BookingDto {
  const BookingDto({
    required this.id,
    required this.reference,
    required this.performanceId,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
    required this.lines,
    required this.seats,
    this.patronId,
    this.guestEmail,
    this.productionName,
    this.ticketType,
    this.cardLast4,
    this.qrCode,
    this.isFlagged = false,
  });

  factory BookingDto.fromJson(Map<String, Object?> json) => BookingDto(
    id: _requiredString(json, 'bookingId'),
    reference: _requiredString(json, 'bookingRef'),
    patronId: _nullableNonEmptyString(json, 'patronId'),
    guestEmail: _nullableNonEmptyString(json, 'guestEmail'),
    performanceId: _requiredString(json, 'performanceId'),
    status: _requiredString(json, 'status'),
    paymentStatus: _requiredString(json, 'paymentStatus'),
    total: _number(json, 'totalLkr').round(),
    createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
    isFlagged: _bool(json, 'isFlagged') ?? false,
    productionName: _nullableNonEmptyString(json, 'productionName'),
    ticketType: _nullableNonEmptyString(json, 'ticketType'),
    cardLast4: _nullableNonEmptyString(json, 'cardLast4'),
    qrCode: _nullableNonEmptyString(json, 'qrCode'),
    seats: _list(
      json['seats'],
    ).map(BookingSeatDto.fromJson).toList(growable: false),
    lines: _list(
      json['lines'],
    ).map(BookingLineDto.fromJson).toList(growable: false),
  );

  final String id;
  final String reference;
  final String? patronId;
  final String? guestEmail;
  final String? productionName;
  final String? ticketType;
  final String? cardLast4;
  final String? qrCode;
  final String performanceId;
  final String status;
  final bool isFlagged;
  final int total;
  final String paymentStatus;
  final DateTime createdAt;
  final List<BookingLineDto> lines;
  final List<BookingSeatDto> seats;
}

class BookingSeatDto {
  const BookingSeatDto({
    required this.seatId,
    required this.seatReference,
    required this.zoneName,
    required this.section,
  });

  factory BookingSeatDto.fromJson(Map<String, Object?> json) => BookingSeatDto(
    seatId: _requiredString(json, 'seatId'),
    seatReference: _string(json, 'seatRef') ?? '',
    zoneName: _string(json, 'zoneName') ?? '',
    section: _string(json, 'section') ?? '',
  );

  final String seatId;
  final String seatReference;
  final String zoneName;
  final String section;
}

class BookingSummaryDto {
  const BookingSummaryDto({
    required this.id,
    required this.reference,
    required this.performanceId,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
  });

  factory BookingSummaryDto.fromJson(Map<String, Object?> json) =>
      BookingSummaryDto(
        id: _requiredString(json, 'bookingId'),
        reference: _requiredString(json, 'bookingRef'),
        performanceId: _requiredString(json, 'performanceId'),
        status: _requiredString(json, 'status'),
        paymentStatus: _requiredString(json, 'paymentStatus'),
        total: _number(json, 'totalLkr').round(),
        createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
      );

  final String id;
  final String reference;
  final String performanceId;
  final String status;
  final String paymentStatus;
  final int total;
  final DateTime createdAt;
}

Map<String, Object?> _map(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : const {};

List<Map<String, Object?>> _list(Object? value) => value is List
    ? value
          .whereType<Map>()
          .map((item) => item.cast<String, Object?>())
          .toList(growable: false)
    : const [];

String _mapString(Map<String, Object?> map, String key) =>
    map[key] is String ? map[key]! as String : '';

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (value == null || value.isEmpty) return _missing(key);
  return value;
}

String? _string(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is String ? value.trim() : null;
}

String? _nullableNonEmptyString(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  return value == null || value.isEmpty ? null : value;
}

DateTime? _optionalDate(Map<String, Object?> json, String key) {
  final value = _nullableNonEmptyString(json, key);
  return value == null ? null : DateTime.parse(value);
}

num _number(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is num) return value;
  return _missing(key);
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = _int(json, key);
  return value ?? _missing(key);
}

int? _int(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is num ? value.toInt() : null;
}

bool? _bool(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is bool ? value : null;
}

Never _missing(String field) => throw ApiException(
  ApiFailureType.invalidResponse,
  message: 'Missing or invalid $field in the server response.',
);

String _normalizeSection(String value) => switch (value.toUpperCase()) {
  'STALLS' => 'stalls',
  'CIRCLE' => 'circle',
  'UPPER_CIRCLE' || 'UPPERCIRCLE' => 'upperCircle',
  _ => _missing('section'),
};

String _normalizeSeatStatus(String value) => switch (value.toUpperCase()) {
  'AVAILABLE' => 'available',
  'HELD' => 'held',
  'BOOKED' => 'booked',
  'BLOCKED' => 'unavailable',
  _ => _missing('status'),
};
