class ConverterService {
  static int parseInt(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return int.tryParse(text.trim()) ?? 0;
  }

  static double parseDouble(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return double.tryParse(text.trim()) ?? 0;
  }

  static String getCurrentMonthKey() {
    final now = DateTime.now();
    const monthKeys = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec'
    ];
    return monthKeys[now.month - 1];
  }

  static String getRelativeTime({required DateTime dateTime}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  /// Format DateTime to a readable date like: 5, Jan 2025
  static String formatDateToBangla(DateTime dateTime) {
    const englishMonths = [
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
      'Dec'
    ];

    final day = dateTime.day.toString();
    final month = englishMonths[dateTime.month - 1];
    final year = dateTime.year.toString();

    return '$day, $month $year';
  }
}
