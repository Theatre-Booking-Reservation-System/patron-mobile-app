import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/checkout/domain/card_payment_validation.dart';

void main() {
  group('card number', () {
    test('accepts 13 to 19 digits after stripping non-digits', () {
      expect(isValidCardNumber('1234567890123'), isTrue);
      expect(isValidCardNumber('4111 1111 1111 1111'), isTrue);
      expect(isValidCardNumber('1234-5678-9012-3456-789'), isTrue);
    });

    test('rejects numbers outside 13 to 19 digits', () {
      expect(isValidCardNumber('123456789012'), isFalse);
      expect(isValidCardNumber('12345678901234567890'), isFalse);
      expect(isValidCardNumber(''), isFalse);
    });
  });

  group('cvv', () {
    test('accepts exactly 3 or 4 digits', () {
      expect(isValidCvv('123'), isTrue);
      expect(isValidCvv('1234'), isTrue);
    });

    test('rejects any other length or characters', () {
      expect(isValidCvv('12'), isFalse);
      expect(isValidCvv('12345'), isFalse);
      expect(isValidCvv('12a'), isFalse);
    });
  });

  group('expiry', () {
    test('accepts months 01 to 12 in MM/YY and MM/YYYY', () {
      expect(isValidCardExpiry('01/30'), isTrue);
      expect(isValidCardExpiry('12/30'), isTrue);
      expect(isValidCardExpiry('12/2030'), isTrue);
    });

    test('rejects a month above 12', () {
      expect(cardExpiryFailure('13/30'), CardExpiryFailure.month);
      expect(cardExpiryFailure('99/2030'), CardExpiryFailure.month);
      expect(cardExpiryFailure('00/30'), CardExpiryFailure.month);
    });

    test('rejects other expiry formats', () {
      expect(isValidCardExpiry('12/3'), isFalse);
      expect(isValidCardExpiry('12/20301'), isFalse);
      expect(isValidCardExpiry('1230'), isFalse);
      expect(isValidCardExpiry(''), isFalse);
    });
  });
}
