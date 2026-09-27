import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/remote_theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class _MockClient extends Mock implements TheatreApiClient {}

class _MockSessionStore extends Mock implements AuthSessionStore {}

void main() {
  test(
    'matches a seat zone by section and name when its id is stale',
    () async {
      final client = _MockClient();
      when(() => client.getSeatMap('performance-id')).thenAnswer(
        (_) async => const [
          SeatDto(
            id: 'seat-id',
            zoneId: 'stale-zone-id',
            section: 'circle',
            zoneName: 'Centre',
            row: 'A',
            number: 1,
            status: 'available',
            isAccessible: false,
          ),
        ],
      );
      when(client.getSeatZones).thenAnswer(
        (_) async => const [
          SeatZoneDto(
            id: 'current-zone-id',
            section: 'circle',
            name: 'Centre',
            matineePercent: 100,
            eveningPercent: 120,
          ),
        ],
      );
      final repository = RemoteTheatreRepository(client, _MockSessionStore());

      final seats = await repository.getSeats(_production, _performance);

      expect(seats, hasLength(1));
      expect(seats.single.section, SeatSection.circle);
      expect(seats.single.netPrice, 1200);
    },
  );
}

final _performance = Performance(
  id: 'performance-id',
  dateTime: DateTime(2026, 10, 9, 18, 30),
  session: PerformanceSession.evening,
);

final _production = Production(
  id: 'production-id',
  title: const LocalizedText(en: 'Production', si: '', ta: ''),
  synopsis: const LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Drama',
  baseTicketCost: 1000,
  performances: [_performance],
);
