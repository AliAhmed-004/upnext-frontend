import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/item_location_map.dart';
import 'package:upnext/services/supabase_service.dart';

import '../helper/helper_methods.dart';
import '../models/listing_model.dart';

class ListingDetailsPage extends StatefulWidget {
  final String listingId;
  final bool isFromUserListings;

  const ListingDetailsPage({
    super.key,
    required this.listingId,
    required this.isFromUserListings,
  });

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  late final String listingId;

  String _createdBy = "Loading...";
  String _title = "Loading...";
  String _description = "Loading...";
  String _category = "Loading...";
  String _formattedDate = "Loading...";
  String _status = "Loading...";
  LatLng? _location;

  @override
  void initState() {
    super.initState();
    listingId = widget.listingId;
    getListingDetails();
  }

  void getListingDetails() async {
    final supabaseService = SupabaseService();
    final listing = await supabaseService.fetchListingById(listingId);

    if (listing != null) {
      // Fetch user data
      final userData = await supabaseService.fetchUserDataById(listing.user_id);
      debugPrint('User Data: $userData');
      setState(() {
        _createdBy = userData?['username'] ?? 'Unknown User';
        _title = listing.title;
        _description = listing.description;
        _category = listing.category;
        _formattedDate = listing.created_at;
        _status = listing.status;
        _location = LatLng(listing.latitude, listing.longitude);
      });
    }
  }

  // Book listing function
  void _bookListing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Item'),
        content: const Text('Are you sure you want to book this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Book'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // FIREBASE - COMMENTED OUT
    final supabaseService = SupabaseService();
    final result = await supabaseService.bookListing(listingId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unknown error'),
          backgroundColor: result['status'] == 'success'
              ? Colors.green
              : Colors.red,
        ),
      );
      if (result['status'] == 'success') {
        // Refresh the listing details to show updated status
        getListingDetails();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author section
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _createdBy,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),

                        // Created At, formatted
                        Text(
                          "Created at: $_formattedDate",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Current Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _status == Status.active.name
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                          : _status == Status.inactive.name
                          ? Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.18)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _status.toUpperCase(),
                      style: TextStyle(
                        color: _status == Status.booked.name
                            ? Theme.of(context).colorScheme.primary
                            : _status == Status.inactive.name
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  _description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Address of the listing
              FutureBuilder<String>(
                future: getAddressFromLatLng(
                  _location?.latitude,
                  _location?.longitude,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error fetching address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.6,
                      ),
                    );
                  } else {
                    return Text(
                      'Address: ${snapshot.data}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.6,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // category
              Text(
                "Category: $_category",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),

              // Map to show where the listing is located
              if (_location != null) ItemLocationMap(location: _location!),
              const SizedBox(height: 24),

              // Button to book the listing if it's not from user listings and status is active
              if (!widget.isFromUserListings && _status == Status.active.name)
                CustomButton(onPressed: _bookListing, buttonText: "Book Item"),

              // Show message if listing is already booked
              if (!widget.isFromUserListings && _status == Status.booked.name)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'This item has already been booked',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
