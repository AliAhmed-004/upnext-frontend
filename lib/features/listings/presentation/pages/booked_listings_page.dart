import 'package:flutter/material.dart';
import 'package:upnext/features/listings/presentation/widgets/listing_tile.dart';
import 'package:upnext/features/listings/domain/entities/listing_model.dart';
import 'package:upnext/features/listings/data/datasources/supabase_service.dart';

class BookedListingsPage extends StatefulWidget {
  const BookedListingsPage({super.key});

  @override
  State<BookedListingsPage> createState() => _BookedListingsPageState();
}

class _BookedListingsPageState extends State<BookedListingsPage> {
  final _supabaseService = SupabaseService();
  List<ListingModel> _bookedListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookedListings();
  }

  Future<void> _loadBookedListings() async {
    setState(() => _isLoading = true);
    final listings = await _supabaseService.fetchBookedListings();
    if (mounted) {
      setState(() {
        _bookedListings = listings;
        _isLoading = false;
      });
    }
  }

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

    setState(() => _isLoading = true);

    final result = await _supabaseService.cancelBooking(listingId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'An error occurred'),
          backgroundColor: result['status'] == 'success'
              ? Colors.green
              : Colors.red,
        ),
      );
      if (result['status'] == 'success') {
        _loadBookedListings();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Booked Items')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookedListings.isEmpty
          ? Center(
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
            )
          : RefreshIndicator(
              onRefresh: _loadBookedListings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookedListings.length,
                itemBuilder: (context, index) {
                  final listing = _bookedListings[index];
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
}
