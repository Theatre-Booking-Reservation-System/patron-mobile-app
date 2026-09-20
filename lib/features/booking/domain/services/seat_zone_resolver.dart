import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class SeatZoneDefinition {
  const SeatZoneDefinition(this.name, this.matineePercent, this.eveningPercent);

  final String name;
  final int matineePercent;
  final int eveningPercent;

  int multiplier(PerformanceSession session) =>
      session == PerformanceSession.matinee ? matineePercent : eveningPercent;
}

abstract final class SeatZoneResolver {
  static SeatZoneDefinition resolve(SeatSection section, String row, int seat) {
    return switch (section) {
      SeatSection.stalls => _stalls(row),
      SeatSection.circle => _circle(row, seat),
      SeatSection.upperCircle => _upperCircle(row, seat),
    };
  }

  static SeatZoneDefinition _stalls(String row) {
    if (const {'AA', 'BB', 'CC', 'DD'}.contains(row)) {
      return const SeatZoneDefinition('Premium', 200, 250);
    }
    final code = row.codeUnitAt(0);
    if (code >= 'A'.codeUnitAt(0) && code <= 'M'.codeUnitAt(0)) {
      return const SeatZoneDefinition('Mid', 150, 175);
    }
    return const SeatZoneDefinition('Standard', 100, 150);
  }

  static SeatZoneDefinition _circle(String row, int seat) {
    final outer = switch (row) {
      'A' => seat <= 6 || (seat >= 71 && seat <= 76),
      'B' => seat <= 8 || (seat >= 75 && seat <= 82),
      'C' => seat <= 8 || (seat >= 82 && seat <= 89),
      _ => false,
    };
    if (outer) return const SeatZoneDefinition('Side Outer', 150, 175);
    final inner = switch (row) {
      'A' => (seat >= 7 && seat <= 27) || (seat >= 50 && seat <= 70),
      'B' => (seat >= 9 && seat <= 31) || (seat >= 52 && seat <= 74),
      'C' => (seat >= 9 && seat <= 34) || (seat >= 56 && seat <= 81),
      _ => false,
    };
    if (inner) return const SeatZoneDefinition('Side Inner', 125, 150);
    return const SeatZoneDefinition('Centre', 210, 220);
  }

  static SeatZoneDefinition _upperCircle(String row, int seat) {
    final outer = switch (row) {
      'A' => seat <= 6 || (seat >= 83 && seat <= 88),
      'B' => seat <= 8 || (seat >= 86 && seat <= 93),
      'C' => seat <= 8 || (seat >= 69 && seat <= 76),
      _ => false,
    };
    if (outer) return const SeatZoneDefinition('Side Outer', 80, 100);
    final inner = switch (row) {
      'A' => (seat >= 7 && seat <= 32) || (seat >= 57 && seat <= 82),
      'B' => (seat >= 9 && seat <= 34) || (seat >= 80 && seat <= 85),
      'C' => (seat >= 9 && seat <= 24) || (seat >= 53 && seat <= 68),
      _ => false,
    };
    if (inner) return const SeatZoneDefinition('Side Inner', 50, 70);
    final centreAlt =
        (row == 'A' && seat >= 33 && seat <= 56) ||
        (row == 'B' && seat >= 35 && seat <= 59);
    if (centreAlt) return const SeatZoneDefinition('Centre', 75, 100);
    return const SeatZoneDefinition('Base', 100, 100);
  }
}
