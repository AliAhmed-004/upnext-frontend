import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/env.dart';

import '../models/listing_model.dart';

class ListingTile extends StatefulWidget {
  final ListingModel listingModel;

  const ListingTile({super.key, required this.listingModel});

  @override
  State<ListingTile> createState() => _ListingTileState();
}

class _ListingTileState extends State<ListingTile> {
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _getListingDetails();
  }

  // Fetch details like who made the listing
  void _getListingDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${Env.baseUrl}${Env.getListingById}/${widget.listingModel.id}",
        ),
      );

      if (response.statusCode == 200) {
        // extract the user name from response and set _userName
        final responseBody = jsonDecode(response.body);

        debugPrint("Listing Details Response: $responseBody");

        final username = responseBody['user_name'];

        setState(() {
          _userName = username;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO: Add the ontap functionality
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Name
                Text(_userName),

                // Listing Name
                Text(widget.listingModel.title),

                // Listing Description shortened
                Text(widget.listingModel.description),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
