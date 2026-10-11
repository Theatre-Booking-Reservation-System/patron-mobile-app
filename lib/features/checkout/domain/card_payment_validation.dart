final _nonDigits = RegExp(r'\D');

bool isValidCardNumber(String value) {
  final digits = value.replaceAll(_nonDigits, '');
  return RegExp(r'^\d{13,19}$').hasMatch(digits);
}

bool isValidCvv(String value) => RegExp(r'^\d{3,4}$').hasMatch(value);

enum CardExpiryFailure { format, month }

CardExpiryFailure? cardExpiryFailure(String value) {
  if (!RegExp(r'^\d{2}/\d{2,4}$').hasMatch(value)) {
    return CardExpiryFailure.format;
  }
  final month = int.parse(value.substring(0, 2));
  if (month < 1 || month > 12) return CardExpiryFailure.month;
  return null;
}

bool isValidCardExpiry(String value) => cardExpiryFailure(value) == null;
