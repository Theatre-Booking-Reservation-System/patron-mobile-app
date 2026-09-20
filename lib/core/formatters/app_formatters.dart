import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static String money(int amount) =>
      NumberFormat.currency(symbol: 'LKR ', decimalDigits: 0).format(amount);

  static String date(DateTime value, String locale) =>
      DateFormat('dd/MM/yyyy', locale).format(value);

  static String time(DateTime value, String locale) =>
      DateFormat.jm(locale).format(value);
}
