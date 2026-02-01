import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/listing_provider.dart';
import 'package:upnext/features/listings/widgets/listing_tile.dart';

/// Page displaying listings booked by the current user.
/// 
/// Allows users to view and cancel their bookings.
class BookedListingsPage extends StatefulWidget {
  const BookedListingsPage({super.key});

  @override
  State<BookedListingsPage> createState() => _BookedListingsPageState();
}

class _BookedListingsPageState extends State<BookedListingsPage> {
  @override
  void initState() {
    super.initState();
    // Load booked listings through provider
    Future.microtask(() {
      context.read<ListingProvider>().fetchBookedListings();
    });
  }

  /// Cancel a booking through the provider.
  Future<void> _cancelBooking(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await context.read<ListingProvider>().cancelBooking(listingId);

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
    final bookedListings = provider.bookedListings;
    final isLoading = provider.isBookedListingsLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('My Booked Items')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookedListings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.fetchBookedListings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookedListings.length,
                    itemBuilder: (context, index) {
                      final listing = bookedListings[index];
                      return ListingTile(
                        listingModel: listing,
                        isFromUserListings: false,
                        onCancel: () => _cancelBooking(listing.id),
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
            Icons.bookmark_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No booked items yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you book will appear here',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
