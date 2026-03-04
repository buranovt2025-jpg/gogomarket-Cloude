import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();
  static final _fmt = NumberFormat('#,###', 'ru_RU');
  static String price(int sumValue)    => '${_fmt.format(sumValue)} сум';
  static String priceTiyin(int tiyin)  => price(tiyin ~/ 100);
  static String shortDate(DateTime dt) => DateFormat('d MMM', 'ru').format(dt);
}
