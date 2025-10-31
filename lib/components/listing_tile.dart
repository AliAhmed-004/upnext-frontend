import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/env.dart';

import '../models/listing_model.dart';
import '../pages/listing_details_page.dart';

class ListingTile extends StatefulWidget {
  final ListingModel listingModel;
  final bool isFromUserListings;
  final Future<void> Function()? onRefresh;

  const ListingTile({
    super.key,
    required this.listingModel,
    required this.isFromUserListings,
    this.onRefresh,
  });

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
        Get.to(
          () => ListingDetailsPage(
            listingId: listing.id,
            isFromUserListings: widget.isFromUserListings,
          ),
        )?.then((result) async {
          if (result == true && widget.onRefresh != null) {
            await widget.onRefresh!();
          }
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Card(
          color: Theme.of(context).cardColor,
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
                        color: Theme.of(context).colorScheme.secondary,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            // TODO: Replace with actual posting time
                            'Posted recently',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  listing.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
