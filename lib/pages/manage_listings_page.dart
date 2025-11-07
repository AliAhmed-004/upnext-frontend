import 'package:flutter/material.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/firestore_service.dart';

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  bool isLoading = true;
  List<ListingModel> listings = [];

  // Fetch Listings
  void fetchListings() async {
    final FirestoreService firestoreService = FirestoreService();

    final fetchedListings = await firestoreService.fetchCurrentUserListings();

    setState(() {
      listings = fetchedListings;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Your Listings')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listings.isEmpty
          ? const Center(child: Text('No listings found.'))
          : ListView.builder(
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingTile(
                  listingModel: listing,
                  isFromUserListings: true,
                );
              },
            ),
    );
  }
}
