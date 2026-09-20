import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/services/ticket_pricing_service.dart';

void main() {
  const seat = Seat(
    id: 'seat-1',
    section: SeatSection.stalls,
    row: 'A',
    number: 1,
    zoneName: 'Mid',
    multiplierPercent: 175,
    netPrice: 4000,
    status: SeatStatus.available,
  );

  test('applies mock VAT and loyalty without concession', () {
    const service = TicketPricingService();
    final quote = service.quote(
      seats: const [seat],
      isLoyaltyMember: true,
      concession: ConcessionType.none,
    );

    expect(quote.loyaltyTotal, 400);
    expect(quote.netTotal, 3600);
    expect(quote.vatTotal, 648);
    expect(quote.total, 4248);
  });

  test('bypasses unresolved concession rates and stacking', () {
    const service = TicketPricingService();
    final quote = service.quote(
      seats: const [seat],
      isLoyaltyMember: true,
      concession: ConcessionType.under16,
    );

    expect(quote.concessionTotal, 0);
    expect(quote.loyaltyTotal, 0);
    expect(quote.vatTotal, 720);
    expect(quote.total, 4720);
  });
}
