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

    String convertToBanglaDigits(int number) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

      return number.toString().split('').map((e) {
        final index = english.indexOf(e);
        return index != -1 ? bangla[index] : e;
      }).join('');
    }

    if (difference.inSeconds < 60) {
      return '${convertToBanglaDigits(difference.inSeconds)} সেকেন্ড আগে';
    } else if (difference.inMinutes < 60) {
      return '${convertToBanglaDigits(difference.inMinutes)} মিনিট আগে';
    } else if (difference.inHours < 24) {
      return '${convertToBanglaDigits(difference.inHours)} ঘণ্টা আগে';
    } else if (difference.inDays < 30) {
      return '${convertToBanglaDigits(difference.inDays)} দিন আগে';
    } else if (difference.inDays < 365) {
      return '${convertToBanglaDigits((difference.inDays / 30).floor())} মাস আগে';
    } else {
      return '${convertToBanglaDigits((difference.inDays / 365).floor())} বছর আগে';
    }
  }

  /// Converts English digits to Bangla digits
  static String _toBanglaDigits(String input) {
    const eng = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bang = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    for (int i = 0; i < eng.length; i++) {
      input = input.replaceAll(eng[i], bang[i]);
    }
    return input;
  }

  /// Format DateTime to Bangla date like: ৫, জান ২০২৫
  static String formatDateToBangla(DateTime dateTime) {
    const banglaMonths = [
      'জান', // Jan
      'ফেব', // Feb
      'মার', // Mar
      'এপ্র', // Apr
      'মে', // May
      'জুন', // Jun
      'জুল', // Jul
      'আগ', // Aug
      'সেপ্ট', // Sep
      'অক্ট', // Oct
      'নভে', // Nov
      'ডিসে' // Dec
    ];

    final dayBangla = _toBanglaDigits(dateTime.day.toString());
    final monthBangla = banglaMonths[dateTime.month - 1];
    final yearBangla = _toBanglaDigits(dateTime.year.toString());

    return '$dayBangla, $monthBangla $yearBangla';
  }
}
