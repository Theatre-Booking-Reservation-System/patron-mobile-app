import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/home/domain/today_shows.dart';

void main() {
  test('shows only scheduled, non-Poya performances for the given day', () {
    final day = DateTime(2026, 9, 24);
    final earlier = _production('earlier', [
      _performance('tomorrow', DateTime(2026, 9, 25, 14)),
      _performance('evening', DateTime(2026, 9, 24, 19)),
      _performance('matinee', DateTime(2026, 9, 24, 14)),
    ]);
    final later = _production('later', [
      _performance('poya', DateTime(2026, 9, 24, 12), isPoyaDay: true),
      _performance('late', DateTime(2026, 9, 24, 20)),
    ]);
    final otherDay = _production('other', [
      _performance('other-day', DateTime(2026, 9, 23, 20)),
    ]);

    final shows = todayShowsFor([later, otherDay, earlier], day);

    expect(shows.map((show) => show.production.id), ['earlier', 'later']);
    expect(shows.first.performances.map((show) => show.id), [
      'matinee',
      'evening',
    ]);
    expect(shows.last.performances.single.id, 'late');
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
  posterSeed: 0,
);

Performance _performance(
  String id,
  DateTime dateTime, {
  bool isPoyaDay = false,
}) => Performance(
  id: id,
  dateTime: dateTime,
  session: PerformanceSession.evening,
  isPoyaDay: isPoyaDay,
);
