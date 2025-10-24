import 'dart:convert';

import 'package:flutter/material.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(listingId: listing.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_userName),
            Text(listing.title),
            Text(listing.description),
          ],
        ),
      ),
    );
  }
}
