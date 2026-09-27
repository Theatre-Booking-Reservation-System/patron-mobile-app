import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/mock_theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/mock_theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/home/domain/today_shows.dart';

void main() {
  test('mock programme has three performances on 25 September 2026', () async {
    final productions = await MockTheatreRepository(
      MockTheatreApiClient(),
    ).getProductions();
    final shows = todayShowsFor(productions, DateTime(2026, 9, 25));

    expect(shows.length, 3);
    expect(shows.map((show) => show.performances.single.id), [
      'sk-20260925',
      'yo-20260925',
      'mv-20260925',
    ]);
  });

  test('shows only performances scheduled for the given day', () {
    final day = DateTime(2026, 9, 24);
    final earlier = _production('earlier', [
      _performance('tomorrow', DateTime(2026, 9, 25, 14)),
      _performance('evening', DateTime(2026, 9, 24, 19)),
      _performance('matinee', DateTime(2026, 9, 24, 14)),
    ]);
    final later = _production('later', [
      _performance('noon', DateTime(2026, 9, 24, 12)),
      _performance('late', DateTime(2026, 9, 24, 20)),
    ]);
    final otherDay = _production('other', [
      _performance('other-day', DateTime(2026, 9, 23, 20)),
    ]);

    final shows = todayShowsFor([later, otherDay, earlier], day);

    expect(shows.map((show) => show.production.id), ['later', 'earlier']);
    expect(shows.last.performances.map((show) => show.id), [
      'matinee',
      'evening',
    ]);
    expect(shows.first.performances.map((show) => show.id), ['noon', 'late']);
    expect(todayShowsFor([otherDay], day), isEmpty);
  });
}

Production _production(String id, List<Performance> performances) => Production(
  id: id,
  title: LocalizedText(en: id, si: id, ta: id),
  synopsis: const LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Drama',
  baseTicketCost: 800,
  performances: performances,
);

Performance _performance(String id, DateTime dateTime) => Performance(
  id: id,
  dateTime: dateTime,
  session: PerformanceSession.evening,
);
