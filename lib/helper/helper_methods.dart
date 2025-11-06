import 'package:intl/intl.dart';

String formatIsoDate(String isoDate) {
  final dateTime = DateTime.parse(
    isoDate,
  ).toLocal(); // convert from UTC if needed
  return DateFormat('MMM d, y – h:mm a').format(dateTime);
}
