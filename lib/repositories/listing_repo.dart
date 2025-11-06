import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/api/listing_api_service.dart';
import 'package:upnext/services/firestore_service.dart';

class ListingRepo {
  // final db = DatabaseService();
  final listingApi = ListingApiService();

  Future<List<ListingModel>> getListings() async {
    try {
      print('Fetching listings from FirestoreService using repo');
      final FirestoreService firestoreService = FirestoreService();
      final listings = await firestoreService.fetchListings();
      return listings;
    } catch (error) {
      print('Error in ListingRepo getListings: $error');
      return [];
    }
  }

  Future<List<ListingModel>> getListingsByUserId(String userId) async {
    try {
      final apiListings = await listingApi.fetchListingsByUserId(userId);
      return apiListings;
    } catch (error) {
      print('Error in ListingRepo getListingsByUserId: $error');
      return [];
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      return await listingApi.deleteListing(listingId);
    } catch (error) {
      print('Error in ListingRepo deleteListing: $error');
      return false;
    }
  }
}
