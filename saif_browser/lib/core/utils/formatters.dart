/// Human readable sizes, speeds and dates.
abstract final class Formatters {
  static String bytes(int? value) {
    if (value == null || value < 0) return 'Unknown size';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = value.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final digits = unit == 0 || size >= 100 ? 0 : 1;
    return '${size.toStringAsFixed(digits)} ${units[unit]}';
  }

  static String speed(double bytesPerSecond) => '${bytes(bytesPerSecond.round())}/s';

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String time(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String dayHeading(DateTime day, DateTime now) {
    final d = DateTime(day.year, day.month, day.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    final base = '${_months[d.month - 1]} ${d.day}';
    return d.year == now.year ? base : '$base, ${d.year}';
  }

  static String dateTime(DateTime t, DateTime now) => '${dayHeading(t, now)}, ${time(t)}';
}
