import 'package:intl/intl.dart';

/// Utility class for date formatting
class DateHelpers {
  /// Formats a date string to 'YYYY-MM-DD'.
  /// Returns '-' if the input is null or an invalid date string.
  static String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return 'Invalid date'; // Handle parsing errors
    }
  }
}
