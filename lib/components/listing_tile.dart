import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/env.dart';

import '../models/listing_model.dart';
import '../pages/listing_details_page.dart';

class ListingTile extends StatefulWidget {
  final ListingModel listingModel;

  const ListingTile({super.key, required this.listingModel});

  @override
  State<ListingTile> createState() => _ListingTileState();
}

class _ListingTileState extends State<ListingTile> {
  late final ListingModel listing;
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    listing = widget.listingModel;
    _getListingDetails();
  }

  void _getListingDetails() async {
    try {
      final response = await http.get(
        Uri.parse("${Env.baseUrl}${Env.getListingById}/${listing.id}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Listing Details Response: $data");

        setState(() => _userName = data['user_name']);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ListingDetailsPage(listingId: listing.id));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Posted recently',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
