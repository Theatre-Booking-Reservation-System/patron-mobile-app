import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

void main() {
  test('reads clock times and minute counts from the catalogue', () {
    expect(
      parseProductionDuration('2h 45m'),
      const Duration(hours: 2, minutes: 45),
    );
    expect(parseProductionDuration('120'), const Duration(minutes: 120));
    expect(parseProductionDuration('45m'), const Duration(minutes: 45));
  });

  test('ignores missing or non-numeric durations', () {
    expect(parseProductionDuration(null), isNull);
    expect(parseProductionDuration(''), isNull);
    expect(parseProductionDuration('NaN'), isNull);
  });

  test('formats the running time for the production screen', () {
    const hoursAndMinutes = Production(
      id: 'id',
      title: LocalizedText(en: 'Hamlet', si: '', ta: ''),
      synopsis: LocalizedText(en: '', si: '', ta: ''),
      language: ProductionLanguage.english,
      genre: 'Drama',
      baseTicketCost: 1000,
      performances: [],
      duration: Duration(hours: 2, minutes: 45),
    );
    const wholeHours = Production(
      id: 'id',
      title: LocalizedText(en: 'Hamlet', si: '', ta: ''),
      synopsis: LocalizedText(en: '', si: '', ta: ''),
      language: ProductionLanguage.english,
      genre: 'Drama',
      baseTicketCost: 1000,
      performances: [],
      duration: Duration(minutes: 120),
    );

    expect(hoursAndMinutes.durationLabel, '2h 45m');
    expect(wholeHours.durationLabel, '2h');
  });
}
