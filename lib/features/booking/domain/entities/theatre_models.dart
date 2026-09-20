import 'package:equatable/equatable.dart';

enum ProductionLanguage { sinhala, tamil, english }

enum PerformanceSession { matinee, evening }

enum SeatSection { stalls, circle, upperCircle }

enum SeatStatus { available, held, booked, unavailable }

enum ConcessionType { none, under16, over70, largeParty }

enum BookingStatus { confirmed, past, cancelled }

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
    this.earlyAccessOnly = false,
    this.isPoyaDay = false,
  });

  final String id;
  final DateTime dateTime;
  final PerformanceSession session;
  final bool earlyAccessOnly;
  final bool isPoyaDay;

  @override
  List<Object?> get props => [
    id,
    dateTime,
    session,
    earlyAccessOnly,
    isPoyaDay,
  ];
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
    required this.posterSeed,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText synopsis;
  final ProductionLanguage language;
  final String genre;
  final int baseTicketCost;
  final List<Performance> performances;
  final int posterSeed;

  int get startingPrice => baseTicketCost ~/ 2;

  @override
  List<Object?> get props => [
    id,
    title,
    synopsis,
    language,
    genre,
    baseTicketCost,
    performances,
    posterSeed,
  ];
}

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
    required this.reference,
    required this.production,
    required this.performance,
    required this.seats,
    required this.quote,
    required this.status,
    required this.patronEmail,
    required this.isFlagged,
  });

  final String reference;
  final Production production;
  final Performance performance;
  final List<Seat> seats;
  final BookingQuote quote;
  final BookingStatus status;
  final String patronEmail;
  final bool isFlagged;

  @override
  List<Object?> get props => [
    reference,
    production,
    performance,
    seats,
    quote,
    status,
    patronEmail,
    isFlagged,
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
