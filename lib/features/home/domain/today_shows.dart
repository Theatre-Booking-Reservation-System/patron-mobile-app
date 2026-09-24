import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

typedef TodayShow = ({Production production, List<Performance> performances});

List<TodayShow> todayShowsFor(List<Production> productions, DateTime day) {
  final shows = <TodayShow>[];
  for (final production in productions) {
    final performances =
        production.performances
            .where(
              (performance) =>
                  !performance.isPoyaDay &&
                  performance.dateTime.year == day.year &&
                  performance.dateTime.month == day.month &&
                  performance.dateTime.day == day.day,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    if (performances.isNotEmpty) {
      shows.add((production: production, performances: performances));
    }
  }
  shows.sort(
    (a, b) =>
        a.performances.first.dateTime.compareTo(b.performances.first.dateTime),
  );
  return List.unmodifiable(shows);
}
