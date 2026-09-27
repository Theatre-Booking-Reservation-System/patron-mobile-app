import 'package:equatable/equatable.dart';

enum ProductionLanguage { sinhala, tamil, english }

enum PerformanceSession { matinee, evening }

enum SeatSection { stalls, circle, upperCircle }

enum SeatStatus { available, held, booked, unavailable }

enum ConcessionType { none, under16, over70, largeParty }

enum BookingStatus {
  pending,
  confirmed,
  cancelledPatron,
  cancelledAdmin,
  expired,
}

enum PaymentStatus { unpaid, paid, refunded, failed }

class LocalizedText extends Equatable {
  const LocalizedText({required this.en, required this.si, required this.ta});

  final String en;
  final String si;
  final String ta;

  String resolve(String locale) => switch (locale) {
    'si' => si.isEmpty ? en : si,
    'ta' => ta.isEmpty ? en : ta,
    _ => en,
  };

  @override
  List<Object?> get props => [en, si, ta];
}

class Performance extends Equatable {
  const Performance({
    required this.id,
    required this.dateTime,
    required this.session,
  });

  final String id;
  final DateTime dateTime;
  final PerformanceSession session;

  @override
  List<Object?> get props => [id, dateTime, session];
}

class Production extends Equatable {
  const Production({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.language,
    required this.genre,
    required this.baseTicketCost,
    required this.performances,
    this.posterImageUrl,
    this.releaseDate,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText synopsis;
  final ProductionLanguage language;
  final String genre;
  final int baseTicketCost;
  final List<Performance> performances;
  final String? posterImageUrl;
  final DateTime? releaseDate;

  int get startingPrice => baseTicketCost ~/ 2;

  DateTime? get loyaltyAccessDate =>
      releaseDate?.subtract(const Duration(days: 7));

  bool isReleasedAt(DateTime moment) =>
      releaseDate == null || !_day(moment).isBefore(_day(releaseDate!));

  bool isLoyaltyEarlyAccessAt(DateTime moment) {
    final earlyAccess = loyaltyAccessDate;
    return earlyAccess != null &&
        !_day(moment).isBefore(_day(earlyAccess)) &&
        !isReleasedAt(moment);
  }

  bool canBookAt(DateTime moment, {required bool isLoyaltyMember}) =>
      isReleasedAt(moment) ||
      (isLoyaltyMember && isLoyaltyEarlyAccessAt(moment));

  @override
  List<Object?> get props => [
    id,
    title,
    synopsis,
    language,
    genre,
    baseTicketCost,
    performances,
    posterImageUrl,
    releaseDate,
  ];
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

class Seat extends Equatable {
  const Seat({
    required this.id,
    required this.section,
    required this.row,
    required this.number,
    required this.zoneName,
    required this.multiplierPercent,
    required this.netPrice,
    required this.status,
    this.isAccessible = false,
    this.bookingSeatId,
  });

  final String id;
  final SeatSection section;
  final String row;
  final int number;
  final String zoneName;
  final int multiplierPercent;
  final int netPrice;
  final SeatStatus status;
  final bool isAccessible;
  final String? bookingSeatId;

  String get label => '${section.name} $row$number';

  @override
  List<Object?> get props => [
    id,
    section,
    row,
    number,
    zoneName,
    multiplierPercent,
    netPrice,
    status,
    isAccessible,
    bookingSeatId,
  ];
}

class TicketPrice extends Equatable {
  const TicketPrice({
    required this.seat,
    required this.concession,
    required this.concessionDiscount,
    required this.loyaltyDiscount,
    required this.netAfterDiscounts,
    required this.vatAmount,
    required this.total,
  });

  final Seat seat;
  final ConcessionType concession;
  final int concessionDiscount;
  final int loyaltyDiscount;
  final int netAfterDiscounts;
  final int vatAmount;
  final int total;

  @override
  List<Object?> get props => [
    seat,
    concession,
    concessionDiscount,
    loyaltyDiscount,
    netAfterDiscounts,
    vatAmount,
    total,
  ];
}

class BookingQuote extends Equatable {
  const BookingQuote({required this.lines, required this.vatPercent});

  final List<TicketPrice> lines;
  final int vatPercent;

  int get netTotal =>
      lines.fold(0, (sum, line) => sum + line.netAfterDiscounts);
  int get concessionTotal =>
      lines.fold(0, (sum, line) => sum + line.concessionDiscount);
  int get loyaltyTotal =>
      lines.fold(0, (sum, line) => sum + line.loyaltyDiscount);
  int get vatTotal => lines.fold(0, (sum, line) => sum + line.vatAmount);
  int get total => lines.fold(0, (sum, line) => sum + line.total);

  @override
  List<Object?> get props => [lines, vatPercent];
}

class PatronDetails extends Equatable {
  const PatronDetails({
    required this.name,
    required this.email,
    required this.phone,
    this.concession = ConcessionType.none,
    this.identityDocument = '',
  });

  final String name;
  final String email;
  final String phone;
  final ConcessionType concession;
  final String identityDocument;

  bool get isFlagged => concession != ConcessionType.none;

  @override
  List<Object?> get props => [name, email, phone, concession, identityDocument];
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.reference,
    required this.production,
    required this.performance,
    required this.seats,
    this.quote,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.patronEmail,
    required this.isFlagged,
    this.ticketType,
    this.cardLast4,
    this.qrCode,
  });

  final String id;
  final String reference;
  final Production production;
  final Performance performance;
  final List<Seat> seats;
  final BookingQuote? quote;
  final int total;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final String patronEmail;
  final bool isFlagged;
  final String? ticketType;
  final String? cardLast4;
  final String? qrCode;

  bool get canCancel =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  @override
  List<Object?> get props => [
    id,
    reference,
    production,
    performance,
    seats,
    quote,
    total,
    status,
    paymentStatus,
    createdAt,
    patronEmail,
    isFlagged,
    ticketType,
    cardLast4,
    qrCode,
  ];
}

class BookingDraft extends Equatable {
  const BookingDraft({
    required this.production,
    required this.performance,
    required this.seats,
  });

  final Production production;
  final Performance performance;
  final List<Seat> seats;

  @override
  List<Object?> get props => [production, performance, seats];
}
