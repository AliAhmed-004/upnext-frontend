import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/components/custom_snackbar.dart';
import 'package:upnext/helper/helper_methods.dart';

import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/custom_textfield.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/models/user_model.dart';
import 'package:upnext/services/auth_service.dart';
import 'package:upnext/services/supabase_service.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;

  LatLng? selectedLocation;
  String? selectedAddress;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
  }

  // create listing button call
  void createListing() async {
    // FIREBASE - COMMENTED OUT
    // final User? user = FirebaseAuth.instance.currentUser;

    // TEMPORARY - Show construction message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   CustomSnackbar.show(
    //     title: 'App Under Construction',
    //     message:
    //         'We are migrating to Supabase. Cannot create listings at this time.',
    //     type: SnackbarType.error,
    //   ),
    // );
    // return;

    final authService = AuthService();
    final supabaseService = SupabaseService();

    final userEmail = authService.getUserEmail();
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'User Not Logged In',
          message: 'Please log in to create a listing.',
          type: SnackbarType.error,
        ),
      );
      return;
    }
    final supabaseUser = await supabaseService.fetchUserData(userEmail);

    final UserModel user = UserModel.fromMap(supabaseUser!);

    debugPrint("Creating Listing...");
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    debugPrint("Title: $title");
    debugPrint("Description: $description");
    debugPrint("User ID: ${user.id}");

    final createdAt = DateTime.now().toIso8601String();
    final status = Status.active.name;

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'Location Required',
          message: 'Please pick a location for the listing.',
          type: SnackbarType.error,
        ),
      );
      return;
    }

    if (title.isEmpty || description.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'Missing Information',
          message: 'Please fill in all required fields.',
          type: SnackbarType.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Create the listing data
      final listingData = {
        'user_id': user.id,
        'title': title,
        'description': description,
        'created_at': createdAt,
        'category': selectedCategory ?? 'Other',
        'status': status,
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
      };

      await supabaseService.addListing(listingData);

      if (mounted) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
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
                    final location = result as LatLng;
                    final address = await getAddressFromLatLng(
                      location.latitude,
                      location.longitude,
                    );
                    if (mounted) {
                      setState(() {
                        selectedLocation = location;
                        selectedAddress = address;
                      });
                    }
                  }
                },
                buttonText: "Pick Location",
              ),
              const SizedBox(height: 16),
              Text(
                selectedLocation != null
                    ? "Location: $selectedAddress"
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
                  isLoading: _isCreating,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
