import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/api/listing_api_service.dart';
import 'package:upnext/services/database_service.dart';

class ListingRepo {
  final db = DatabaseService();
  final listingApi = ListingApiService();

  Future<List<ListingModel>> getListings({bool forceRefresh = false}) async {
    try {
      final apiListings = await listingApi.fetchListings();

      return apiListings;
    } catch (error) {
      print('Error in ListingRepo getListings: $error');
      return [];
    }
  }
}
