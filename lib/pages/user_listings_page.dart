import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/services/database_service.dart';

import '../providers/listing_provider.dart';

class UserListingsPage extends StatefulWidget {
  const UserListingsPage({super.key});

  @override
  State<UserListingsPage> createState() => _UserListingsPageState();
}

class _UserListingsPageState extends State<UserListingsPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dbHelper = DatabaseService();
    final fetchedUsers = await dbHelper.getUsers();
    final user = fetchedUsers[0];
    _userId = user['user_id'];
    if (!mounted) return;
    await context.read<ListingProvider>().getListingsByUserId(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final listings = provider.userListings;
    final isLoading = provider.isUserLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
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
                      onRefresh: () async {
                        if (_userId != null) {
                          await context
                              .read<ListingProvider>()
                              .getListingsByUserId(_userId!);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
