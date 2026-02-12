import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/listing_provider.dart';
import 'package:upnext/features/listings/widgets/listing_tile.dart';

/// Page for managing the current user's listings.
/// 
/// Shows all listings created by the user with delete options.
class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  @override
  void initState() {
    super.initState();
    // Load user listings through provider
    Future.microtask(() {
      context.read<ListingProvider>().fetchUserListings();
    });
  }

  /// Delete a listing through the provider.
  Future<void> _deleteListing(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await context.read<ListingProvider>().deleteListing(listingId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'An error occurred'),
          backgroundColor: result['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final listings = provider.userListings;
    final isLoading = provider.isUserListingsLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Your Listings')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listings.isEmpty
              ? _buildEmptyState()
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
                        onDelete: () => _deleteListing(listing.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first listing to share with others',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
