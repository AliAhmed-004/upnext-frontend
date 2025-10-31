import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/item_location_map.dart';
import 'package:upnext/services/api/listing_api_service.dart';
import 'package:upnext/providers/listing_provider.dart';
import 'package:upnext/providers/user_provider.dart';

import '../env.dart';
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
    _getListingDetails();
    _loadUserId();
  }

  void _loadUserId() {
    final userProvider = context.read<UserProvider>();
    _currentUserId = userProvider.userId;
  }

  // Get the listing details from the API
  void _getListingDetails() async {
    try {
      final response = await http.get(
        Uri.parse("${Env.baseUrl}${Env.getListingById}/${listingId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Listing Details Response: $data");

        final listing = data['listings'][0];

        debugPrint("Listing Details: $listing");

        setState(() {
          _createdBy = data['user_name'];
          _title = listing['title'];
          _description = listing['description'];
          _category = listing['category'];
          _formattedDate = formatIsoDate(listing['created_at']);
          _status = listing['status'];
          _location = LatLng(
            double.parse(listing['latitude'].toString()),
            double.parse(listing['longitude'].toString()),
          );
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String formatIsoDate(String isoDate) {
    final dateTime = DateTime.parse(
      isoDate,
    ).toLocal(); // convert from UTC if needed
    return DateFormat('MMM d, y – h:mm a').format(dateTime);
  }

  // Delete listing function
  void _deleteListing() async {
    final ok = await context.read<ListingProvider>().deleteListing(listingId);
    if (ok && context.mounted) {
      Get.back(result: true);
    }
  }

  // Book listing function
  void _bookListing() async {
    if (_currentUserId == null) {
      // try to load user from provider storage first
      await context.read<UserProvider>().loadUser();
      _currentUserId = context.read<UserProvider>().userId;
      if (_currentUserId == null) {
        Get.snackbar(
          'Not Logged In',
          'Please log in to book this item.',
          backgroundColor: Colors.red[200],
        );
        return;
      }
    }
    final ok = await ListingApiService().bookListing(listingId, _currentUserId!);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _status = Status.booked.name;
      });
      // refresh provider feeds so badges update
      await context.read<ListingProvider>().getListings(forceRefresh: true);
      Get.snackbar(
        'Item Booked',
        'You have successfully booked this item.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[200],
      );
    } else {
      Get.snackbar(
        'Booking Failed',
        'Failed to book this item. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[200],
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
            color: Theme.of(context).colorScheme.onBackground,
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
                            color: Theme.of(context).colorScheme.onBackground,
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
                      color: Theme.of(context).colorScheme.onBackground,
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

              // Button to delete the listing if it's from user listings
              if (widget.isFromUserListings)
                CustomButton(
                  onPressed: _deleteListing,
                  buttonText: "Delete Listing",
                ),

              const SizedBox(height: 16),

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
