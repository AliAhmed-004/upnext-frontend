import 'package:flutter/material.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/database_service.dart';

import '../services/api/listing_api_service.dart';

class UserListingsPage extends StatefulWidget {
  const UserListingsPage({super.key});

  @override
  State<UserListingsPage> createState() => _UserListingsPageState();
}

class _UserListingsPageState extends State<UserListingsPage> {
  List<ListingModel>? userListings;

  @override
  void initState() {
    super.initState();
    fetchUserListings();
  }

  // Fetch user listings from API and update state
  Future<void> fetchUserListings() async {
    // Fetch the user from database
    final dbHelper = DatabaseService();
    final fetchedUsers = await dbHelper.getUsers();
    final user = fetchedUsers[0];
    final userId = user['user_id'];

    final listingApi = ListingApiService();
    final listings = await listingApi.fetchListingsByUserId(userId);

    setState(() {
      userListings = listings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: userListings == null
          ? const Center(child: CircularProgressIndicator())
          : userListings!.isEmpty
          ? const Center(child: Text('No listings found.'))
          : ListView.builder(
              itemCount: userListings!.length,
              itemBuilder: (context, index) {
                final listing = userListings![index];
                return ListingTile(
                  listingModel: listing,
                  isFromUserListings: true,
                  onRefresh: fetchUserListings,
                );
              },
            ),
    );
  }
}
