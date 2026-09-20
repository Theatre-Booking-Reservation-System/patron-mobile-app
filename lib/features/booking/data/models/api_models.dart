class ProductionDto {
  const ProductionDto({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.language,
    required this.genre,
    required this.baseTicketCost,
    required this.posterSeed,
    required this.performances,
  });

  factory ProductionDto.fromJson(Map<String, Object?> json) => ProductionDto(
    id: json['id']! as String,
    title: Map<String, String>.from(json['title']! as Map),
    synopsis: Map<String, String>.from(json['synopsis']! as Map),
    language: json['language']! as String,
    genre: json['genre']! as String,
    baseTicketCost: json['baseTicketCost']! as int,
    posterSeed: json['posterSeed']! as int,
    performances: (json['performances']! as List)
        .cast<Map<String, Object?>>()
        .map(PerformanceDto.fromJson)
        .toList(growable: false),
  );

  final String id;
  final Map<String, String> title;
  final Map<String, String> synopsis;
  final String language;
  final String genre;
  final int baseTicketCost;
  final int posterSeed;
  final List<PerformanceDto> performances;
}

class PerformanceDto {
  const PerformanceDto({
    required this.id,
    required this.dateTime,
    required this.session,
    required this.earlyAccessOnly,
    required this.isPoyaDay,
  });

  factory PerformanceDto.fromJson(Map<String, Object?> json) => PerformanceDto(
    id: json['id']! as String,
    dateTime: DateTime.parse(json['dateTime']! as String),
    session: json['session']! as String,
    earlyAccessOnly: json['earlyAccessOnly']! as bool,
    isPoyaDay: json['isPoyaDay']! as bool,
  );

  final String id;
  final DateTime dateTime;
  final String session;
  final bool earlyAccessOnly;
  final bool isPoyaDay;
}

class SeatDto {
  const SeatDto({
    required this.id,
    required this.section,
    required this.row,
    required this.number,
    required this.status,
    required this.isAccessible,
  });

  factory SeatDto.fromJson(Map<String, Object?> json) => SeatDto(
    id: json['id']! as String,
    section: json['section']! as String,
    row: json['row']! as String,
    number: json['number']! as int,
    status: json['status']! as String,
    isAccessible: json['isAccessible']! as bool,
  );

  final String id;
  final String section;
  final String row;
  final int number;
  final String status;
  final bool isAccessible;
}
