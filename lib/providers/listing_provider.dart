import 'package:flutter/widgets.dart';
import 'package:upnext/models/listing_model.dart';

import '../repositories/listing_repo.dart';

class ListingProvider extends ChangeNotifier {
  final _repo = ListingRepo();
  List<ListingModel> _listings = [];
  bool _isLoading = false;

  List<ListingModel> get listings => _listings;
  bool get isLoading => _isLoading;

  Future<void> getListings({bool forceRefresh = false}) async {
    // Fetch Data from repository
    try {
      _listings = await _repo.getListings(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint('Error in ListingProvider getListings: $e');
    }

    notifyListeners();
  }
}
