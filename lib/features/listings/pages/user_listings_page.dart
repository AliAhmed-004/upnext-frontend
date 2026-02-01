import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/features/listings/providers/listing_provider.dart';
import 'package:upnext/features/listings/widgets/listing_tile.dart';

/// Page displaying the current user's own listings.
/// 
/// This is a read-only view of user's listings (unlike ManageListingsPage).
class UserListingsPage extends StatefulWidget {
  const UserListingsPage({super.key});

  @override
  State<UserListingsPage> createState() => _UserListingsPageState();
}

class _UserListingsPageState extends State<UserListingsPage> {
  @override
  void initState() {
    super.initState();
    // Load user listings through provider
    Future.microtask(() {
      context.read<ListingProvider>().fetchUserListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final listings = provider.userListings;
    final isLoading = provider.isUserListingsLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Listings',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : listings.isEmpty
              ? Center(
                  child: Text(
                    'No listings found.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.fetchUserListings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return ListingTile(
                        listingModel: listing,
                        isFromUserListings: true,
                        onRefresh: () => provider.fetchUserListings(),
                      );
                    },
                  ),
                ),
    );
  }
}
