import 'package:flutter/material.dart';
import 'package:upnext/features/listings/presentation/widgets/listing_tile.dart';
import 'package:upnext/features/listings/domain/entities/listing_model.dart';
import 'package:upnext/features/listings/data/datasources/supabase_service.dart';

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  bool isLoading = true;
  List<ListingModel> listings = [];
  final SupabaseService _supabaseService = SupabaseService();

  // Fetch Listings
  void fetchListings() async {
    final fetchedListings = await _supabaseService.fetchCurrentUserListings();

    setState(() {
      listings = fetchedListings;
      isLoading = false;
    });
  }

  // Delete Listing
  Future<void> _deleteListing(String listingId) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    final result = await _supabaseService.deleteListing(listingId);

    if (result['status'] == 'success') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Refresh the listings
      fetchListings();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete listing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => isLoading = false);
    }
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
                  onDelete: () => _deleteListing(listing.id),
                );
              },
            ),
    );
  }
}
