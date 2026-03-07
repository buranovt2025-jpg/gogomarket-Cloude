import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static final _fmt = NumberFormat('#,###', 'ru_RU');

  static String price(int sumValue)      => '${_fmt.format(sumValue)} сум';
  static String priceTiyin(int tiyin)    => price(tiyin ~/ 100);
  static String priceShort(int sumValue) {
    if (sumValue >= 1000000) return '${(sumValue / 1000000).toStringAsFixed(1)} млн';
    if (sumValue >= 1000)    return '${(sumValue / 1000).round()} К';
    return '$sumValue';
  }
  static String phone(String p) {
    final d = p.replaceAll(RegExp(r'\D'), '');
    if (d.length >= 12) return '+${d.substring(0,3)} ${d.substring(3,5)} ${d.substring(5,8)} ${d.substring(8,10)} ${d.substring(10,12)}';
    return p;
  }
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours   < 24) return '${diff.inHours} ч назад';
    if (diff.inDays    < 7)  return '${diff.inDays} д назад';
    return DateFormat('d MMM', 'ru').format(dt);
  }

  static String timeShort(DateTime dt) {
    final now = DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (dt.day == now.day) return '$h:$m';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}';
  }
}
