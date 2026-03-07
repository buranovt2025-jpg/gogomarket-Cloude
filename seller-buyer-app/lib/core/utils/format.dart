class FormatUtils {
  FormatUtils._();

  /// 18500000 tiyins → "185 000 сум"
  static String priceTiyin(int tiyin) {
    final uzs = tiyin ~/ 100;
    final formatted = uzs.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted сум';
  }

  /// 18500000 tiyins → "185 000"
  static String priceNumber(int tiyin) {
    final uzs = tiyin ~/ 100;
    return uzs.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }

  /// DateTime → "14:35"  or  "14 мар"
  static String timeShort(DateTime dt) {
    final now = DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (dt.day == now.day && dt.month == now.month) return '$h:$m';
    return dateShort(dt);
  }

  /// DateTime → "14 мар"
  static String dateShort(DateTime dt) {
    const months = ['янв','фев','мар','апр','май','июн',
                    'июл','авг','сен','окт','ноя','дек'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  /// DateTime → "14.03.2025"
  static String dateFull(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d.$mo.${dt.year}';
  }

  /// Phone format: +998 90 123-45-67
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12) {
      return '+${digits.substring(0,3)} ${digits.substring(3,5)} '
             '${digits.substring(5,8)}-${digits.substring(8,10)}-${digits.substring(10)}';
    }
    return raw;
  }
}
