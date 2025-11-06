import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

String formatIsoDate(String isoDate) {
  final dateTime = DateTime.parse(
    isoDate,
  ).toLocal(); // convert from UTC if needed
  return DateFormat('MMM d, y – h:mm a').format(dateTime);
}

Future<String> getAddressFromLatLng(double? lat, double? long) async {
  try {
    if (lat == null || long == null) {
      return '?';
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address =
          '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
      return address;
    } else {
      return 'No address available';
    }
  } catch (e) {
    return 'Error retrieving address: $e';
  }
}
