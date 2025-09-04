import 'package:intl/intl.dart';

/// Provides commonly used date formatting utilities for the app.
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _date = DateFormat('d, MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d, MMM yyyy, hh:mm a');

  /// Formats [date] as `4, Sep 2025`.
  static String date(DateTime date) => _date.format(date);

  /// Formats [date] as `4, Sep 2025, 05:30 PM`.
  static String dateTime(DateTime date) => _dateTime.format(date);
}

extension AppDateFormatting on DateTime {
  /// Formats this [DateTime] as `4, Sep 2025`.
  String get formattedDate => AppDateFormatter.date(this);

  /// Formats this [DateTime] as `4, Sep 2025, 05:30 PM`.
  String get formattedDateTime => AppDateFormatter.dateTime(this);
}

