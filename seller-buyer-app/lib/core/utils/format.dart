import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static final _numberFormat = NumberFormat('#,###', 'ru_RU');

  static String price(int sumValue) {
    return '${_numberFormat.format(sumValue)} сум';
  }

  static String priceTiyin(int tiyinValue) {
    return price(tiyinValue ~/ 100);
  }

  static String phone(String raw) {
    // +998 XX XXX XX XX
    if (raw.length >= 12) {
      return '${raw.substring(0, 4)} ${raw.substring(4, 6)} ${raw.substring(6, 9)} ${raw.substring(9, 11)} ${raw.substring(11)}';
    }
    return raw;
  }

  static String shortDate(DateTime dt) =>
    DateFormat('d MMM', 'ru').format(dt);

  static String fullDate(DateTime dt) =>
    DateFormat('d MMMM yyyy', 'ru').format(dt);

  static String shortId(String id) =>
    id.split('-').last.toUpperCase().substring(0, 6);
}
