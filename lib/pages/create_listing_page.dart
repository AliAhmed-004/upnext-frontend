import 'package:flutter/material.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/custom_textfield.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/api/listing_api_service.dart';
import 'package:upnext/services/database_service.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final ListingApiService listingApi = ListingApiService();

  final dbHelper = DatabaseService();
  late final user;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fetched_user = await dbHelper.getUsers();
    final currentUser = fetched_user.first;

    setState(() {
      user = currentUser;
    });
  }

  // create listing button call
  void createListing() async {
    debugPrint("Creating Listing...");
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    debugPrint("Title: $title");
    debugPrint("Description: $description");
    debugPrint("User ID: ${user['user_id']}");

    final listing = ListingModel(
      title: title,
      user_id: user['user_id'],
      description: description,
    );

    debugPrint("Created Listing: $listing");

    final response = await listingApi.createListing(listing);

    if (response['status'] == 200) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: Column(
        children: [
          CustomTextfield(hintText: "Title", controller: titleController),

          CustomTextfield(
            hintText: "Description",
            controller: descriptionController,
          ),

          // Create button
          CustomButton(
            onPressed: () => createListing(),
            buttonText: "Create Listing",
          ),
        ],
      ),
    );
  }
}
