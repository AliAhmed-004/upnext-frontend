import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/api/listing_api_service.dart';
import 'package:upnext/services/database_service.dart';

class ListingRepo {
  final db = DatabaseService();
  final listingApi = ListingApiService();

  Future<List<ListingModel>> getListings({bool forceRefresh = false}) async {
    try {
      // First, try to fetch from the local database
      final localListings = await db.getListings();

      if (localListings.isNotEmpty && !forceRefresh) {
        return localListings.map((e) => ListingModel.fromMap(e)).toList();
      }

      final apiListings = await listingApi.fetchListings();

      // Save fetched listings to the local database for future use
      if (apiListings.isNotEmpty) {
        final listingsMap = apiListings.map((e) => e.toMap()).toList();
        await db.insertListings(listingsMap);
      }

      return apiListings;
    } catch (error) {
      print('Error in ListingRepo getListings: $error');
      return [];
    }
  }
}
