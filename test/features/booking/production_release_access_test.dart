import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

void main() {
  final production = Production(
    id: 'production-id',
    title: const LocalizedText(en: 'Production', si: '', ta: ''),
    synopsis: const LocalizedText(en: '', si: '', ta: ''),
    language: ProductionLanguage.english,
    genre: 'Drama',
    baseTicketCost: 1000,
    releaseDate: DateTime(2026, 10, 10),
    performances: const [],
  );

  test('blocks everyone before the production early-access window', () {
    final date = DateTime(2026, 10, 2, 23, 59);

    expect(production.canBookAt(date, isLoyaltyMember: false), isFalse);
    expect(production.canBookAt(date, isLoyaltyMember: true), isFalse);
  });

  test('allows only loyalty members seven days before release', () {
    final date = DateTime(2026, 10, 3);

    expect(production.isLoyaltyEarlyAccessAt(date), isTrue);
    expect(production.canBookAt(date, isLoyaltyMember: false), isFalse);
    expect(production.canBookAt(date, isLoyaltyMember: true), isTrue);
  });

  test('allows all patrons from the production release date', () {
    final date = DateTime(2026, 10, 10);

    expect(production.canBookAt(date, isLoyaltyMember: false), isTrue);
    expect(production.canBookAt(date, isLoyaltyMember: true), isTrue);
  });
}
