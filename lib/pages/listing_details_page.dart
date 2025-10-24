import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../env.dart';

class ListingDetailsPage extends StatefulWidget {
  final String listingId;
  const ListingDetailsPage({super.key, required this.listingId});

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  late final String listingId;

  String _userName = "Loading...";
  String _title = "Loading...";
  String _description = "Loading...";

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
          _userName = data['user_name'];
          _title = listing['title'];
          _description = listing['description'];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Posted by: $_userName",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(_description, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
