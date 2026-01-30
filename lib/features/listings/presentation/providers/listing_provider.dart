import 'package:flutter/widgets.dart';
import 'package:upnext/features/listings/domain/entities/listing_model.dart';
import 'package:upnext/features/listings/data/repositories/listing_repo.dart';

class ListingProvider extends ChangeNotifier {
  final _repo = ListingRepo();
  List<ListingModel> _listings = [];
  List<ListingModel> _userListings = [];
  bool _isLoading = false;
  bool _isUserLoading = false;

  List<ListingModel> get listings => _listings;
  bool get isLoading => _isLoading;
  List<ListingModel> get userListings => _userListings;
  bool get isUserLoading => _isUserLoading;

  Future<void> getListings({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _listings = await _repo.getListings();

      debugPrint('Listings fetched: ${_listings.length}');
    } catch (e) {
      debugPrint('Error in ListingProvider getListings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getListingsByUserId(String userId) async {
    _isUserLoading = true;
    notifyListeners();
    try {
      _userListings = await _repo.getListingsByUserId(userId);
    } catch (e) {
      debugPrint('Error in ListingProvider getListingsByUserId: $e');
    } finally {
      _isUserLoading = false;
      notifyListeners();
    }
  }
}
