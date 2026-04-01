const List<String> _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdaysShort = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String _formatTime12(DateTime t) {
  var hour = t.hour % 12;
  if (hour == 0) hour = 12;
  final min = t.minute.toString().padLeft(2, '0');
  final period = t.hour < 12 ? 'AM' : 'PM';
  return '$hour:$min $period';
}

String formatFeedTimestamp(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diffDays = today.difference(day).inDays;

  if (diffDays == 0) {
    return _formatTime12(local);
  }
  if (diffDays == 1) {
    return 'Yesterday';
  }
  if (diffDays < 7) {
    return _weekdaysShort[local.weekday - 1];
  }
  if (local.year == now.year) {
    return '${_monthsShort[local.month - 1]} ${local.day}';
  }
  return '${_monthsShort[local.month - 1]} ${local.day}, ${local.year}';
}

String formatStoryDate(DateTime dateTime) {
  final t = dateTime.toLocal();
  final now = DateTime.now();
  final mon = _monthsShort[t.month - 1];
  final time = _formatTime12(t);
  if (t.year == now.year) {
    return '${t.day} $mon · $time';
  }
  return '${t.day} $mon ${t.year} · $time';
}
