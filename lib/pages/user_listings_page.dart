import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/providers/user_provider.dart';

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
    final user = context.read<UserProvider>().user;
    _userId = user?['user_id'];
    if (!mounted) return;
    await context.read<ListingProvider>().getListingsByUserId(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final listings = provider.userListings;
    final isLoading = provider.isUserLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('My Listings', style: TextStyle(color: Theme.of(context).colorScheme.onBackground))),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : listings.isEmpty
              ? Center(child: Text('No listings found.', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)))
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
