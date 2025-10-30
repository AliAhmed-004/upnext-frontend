import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/item_location_map.dart';

import '../env.dart';
import '../models/listing_model.dart';
import '../providers/listing_provider.dart';

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
    setState(() {
      listingId = widget.listingId;
    });
    _getListingDetails();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
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
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF6366F1),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            fontSize: 16,
                          ),
                        ),

                        // Created At, formatted
                        Text(
                          "Created at: $_formattedDate",
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
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
                          ? const Color(0xFFD1FAE5)
                          : _status == Status.pickedUp.name
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _status.toUpperCase(),
                      style: TextStyle(
                        color: _status == Status.booked.name
                            ? const Color(0xFF065F46)
                            : _status == Status.pickedUp.name
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF6B7280),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  _description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // category
              Text(
                "Category: $_category",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
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
            ],
          ),
        ),
      ),
    );
  }
}
