import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/item_location_map.dart';
import 'package:upnext/providers/user_provider.dart';
import 'package:upnext/services/firestore_service.dart';

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
  String? _currentUserId;

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
    setState(() {
      listingId = widget.listingId;
    });
    _loadUserId();

    getListingDetails();
  }

  void getListingDetails() async {
    final FirestoreService firestoreService = FirestoreService();
    final result = await firestoreService.fetchListingById(listingId);

    final createdBy = result!.user_id;
    final userData = await firestoreService.fetchUserById(createdBy);
    final username = userData['username'];

    setState(() {
      _title = result.title;
      _description = result.description;
      _category = result.category;
      _formattedDate = formatIsoDate(result.created_at);
      _status = result.status;
      _location = LatLng(result.latitude, result.longitude);
      _createdBy = username;
    });
  }

  void _loadUserId() {
    final userProvider = context.read<UserProvider>();
    _currentUserId = userProvider.userId;
  }

  // Book listing function
  void _bookListing() async {
    // TODO: Implement booking functionality with Firebase
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking functionality is coming soon.'),
          backgroundColor: Colors.orange,
        ),
      );
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

              // Button to book the listing if it's not from user listings
              if (!widget.isFromUserListings)
                CustomButton(
                  onPressed: _bookListing,
                  buttonText: "Book Listing",
                ),
            ],
          ),
        ),
      ),
    );
  }
}
