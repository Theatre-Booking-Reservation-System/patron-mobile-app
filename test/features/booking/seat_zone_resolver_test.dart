import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/services/seat_zone_resolver.dart';

void main() {
  group('SeatZoneResolver', () {
    test('resolves all stalls bands', () {
      expect(
        SeatZoneResolver.resolve(SeatSection.stalls, 'AA', 1).eveningPercent,
        250,
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.stalls, 'M', 12).matineePercent,
        150,
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.stalls, 'P', 12).matineePercent,
        100,
      );
    });

    test('resolves circle boundary seats', () {
      expect(
        SeatZoneResolver.resolve(SeatSection.circle, 'A', 6).name,
        'Side Outer',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.circle, 'A', 7).name,
        'Side Inner',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.circle, 'A', 28).name,
        'Centre',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.circle, 'A', 71).name,
        'Side Outer',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.circle, 'D', 1).eveningPercent,
        220,
      );
    });

    test('resolves upper circle ranges and base fallback', () {
      expect(
        SeatZoneResolver.resolve(SeatSection.upperCircle, 'B', 34).name,
        'Side Inner',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.upperCircle, 'B', 35).name,
        'Centre',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.upperCircle, 'B', 79).name,
        'Base',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.upperCircle, 'B', 80).name,
        'Side Inner',
      );
      expect(
        SeatZoneResolver.resolve(SeatSection.upperCircle, 'C', 25).name,
        'Base',
      );
    });
  });
}
