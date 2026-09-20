import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class MockPricingConfiguration {
  const MockPricingConfiguration({
    this.vatPercent = 18,
    this.loyaltyPercent = 10,
    this.allowLoyaltyWithConcession = false,
  });

  final int vatPercent;
  final int loyaltyPercent;
  final bool allowLoyaltyWithConcession;
}

class TicketPricingService {
  const TicketPricingService({
    this.configuration = const MockPricingConfiguration(),
  });

  final MockPricingConfiguration configuration;

  int vatInclusivePreview(Seat seat) =>
      seat.netPrice + (seat.netPrice * configuration.vatPercent / 100).round();

  BookingQuote quote({
    required List<Seat> seats,
    required bool isLoyaltyMember,
    required ConcessionType concession,
  }) {
    final lines = seats
        .map((seat) {
          // Rates are zero until the backend team confirms concession percentages.
          const concessionDiscount = 0;
          final canApplyLoyalty =
              isLoyaltyMember &&
              (concession == ConcessionType.none ||
                  configuration.allowLoyaltyWithConcession);
          final loyaltyDiscount = canApplyLoyalty
              ? (seat.netPrice * configuration.loyaltyPercent / 100).round()
              : 0;
          final net = seat.netPrice - concessionDiscount - loyaltyDiscount;
          final vat = (net * configuration.vatPercent / 100).round();
          return TicketPrice(
            seat: seat,
            concession: concession,
            concessionDiscount: concessionDiscount,
            loyaltyDiscount: loyaltyDiscount,
            netAfterDiscounts: net,
            vatAmount: vat,
            total: net + vat,
          );
        })
        .toList(growable: false);
    return BookingQuote(lines: lines, vatPercent: configuration.vatPercent);
  }
}
