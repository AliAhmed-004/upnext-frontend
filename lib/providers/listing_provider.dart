import 'package:flutter/widgets.dart';

class ListingProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _listings = [];

  List<Map<String, dynamic>> get listings => _listings;

  void getListings() {
    // TODO: Fetch Data from database
    Future.delayed(const Duration(seconds: 2), () {
      _listings = [
        {'id': 1, 'title': 'Listing 1', 'description': 'Description 1'},
        {'id': 2, 'title': 'Listing 2', 'description': 'Description 2'},
        {'id': 3, 'title': 'Listing 3', 'description': 'Description 3'},
      ];
      notifyListeners();
    });
  }
}
