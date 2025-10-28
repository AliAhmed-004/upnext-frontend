import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

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

  String? selectedCategory;

  // TODO: default location to be user's current location
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fetchedUser = await dbHelper.getUsers();
    final currentUser = fetchedUser.first;

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

    final createdAt = DateTime.now().toIso8601String();
    final status = Status.active.name;

    if (selectedLocation == null) {
      Get.snackbar(
        'Location Required',
        'Please pick a location for the listing.',
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

    final listing = ListingModel(
      id: const Uuid().v1(),
      user_id: user['user_id'],
      title: title,
      description: description,
      created_at: createdAt,
      status: status,
      category: selectedCategory ?? 'Other',
      latitude: selectedLocation!.latitude,
      longitude: selectedLocation!.longitude,
    );

    debugPrint("Created Listing: $listing");

    final response = await listingApi.createListing(listing);

    if (response['status'] == 200) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Create Listing',
          style: TextStyle(
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
              const Text(
                'Share something with the community',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              CustomTextfield(
                hintText: "What are you offering?",
                controller: titleController,
              ),
              const SizedBox(height: 24),

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
