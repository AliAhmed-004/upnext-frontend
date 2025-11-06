import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/services/firestore_service.dart';

import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/custom_textfield.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/api/listing_api_service.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final ListingApiService listingApi = ListingApiService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;

  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
  }

  // create listing button call
  void createListing() async {
    final User? user = FirebaseAuth.instance.currentUser;

    debugPrint("Creating Listing...");
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    debugPrint("Title: $title");
    debugPrint("Description: $description");
    debugPrint("User ID: ${user!.uid}");

    final createdAt = DateTime.now().toIso8601String();
    final status = Status.active.name;

    if (selectedLocation == null) {
      Get.snackbar(
        'Location Required',
        'Please pick a location for the listing.',
        backgroundColor: Colors.red[200],
      );
      return;
    }

    if (title.isEmpty || description.isEmpty || selectedCategory == null) {
      Get.snackbar(
        'Missing Information',
        'Please fill in all required fields.',
        backgroundColor: Colors.red[200],
      );
      return;
    }

    // Create the listing data
    final listingData = {
      'user_id': user.uid,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'category': selectedCategory ?? 'Other',
      'status': status,
      'latitude': selectedLocation!.latitude,
      'longitude': selectedLocation!.longitude,
    };

    final FirestoreService firestoreService = FirestoreService();
    await firestoreService.addListing(listingData);

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Listing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
              Text(
                'Share something with the community',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextfield(
                hintText: "What are you offering?",
                controller: titleController,
              ),
              const SizedBox(height: 24),

              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              CustomTextfield(
                hintText: "Tell us more about it...",
                controller: descriptionController,
              ),
              const SizedBox(height: 40),

              // category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    <String>[
                      'Electronics',
                      'Furniture',
                      'Clothing',
                      'Books',
                      'Other',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  // Handle category selection
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 40),

              // pick location button
              CustomButton(
                onPressed: () async {
                  final result = await Get.toNamed('/pick_location');
                  if (result != null) {
                    debugPrint("Selected Location: $result");
                    setState(() {
                      selectedLocation = result as LatLng;
                    });
                  }
                },
                buttonText: "Pick Location",
              ),
              const SizedBox(height: 16),
              Text(
                selectedLocation != null
                    ? "Location: (${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)})"
                    : "No location selected",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () => createListing(),
                  buttonText: "Create Listing",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
