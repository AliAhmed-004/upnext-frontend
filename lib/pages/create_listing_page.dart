import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
  }

  // Pick images
  Future<void> pickImages() async {
    final imagePicker = ImagePicker();
    try {
      final images = await imagePicker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.map((img) => File(img.path)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.show(
            title: 'Error',
            message: 'Failed to pick images.',
            type: SnackbarType.error,
          ),
        );
      }
    }
  }

  // Remove image from selection
  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // create listing button call
  void createListing() async {
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

      await supabaseService.addListing(listingData, selectedImages);

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

              // Image picker section
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Pick Images Button
              OutlinedButton.icon(
                onPressed: pickImages,
                icon: Icon(Icons.add_photo_alternate_outlined),
                label: Text('Pick Images'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 16),

              // Image Preview Grid
              if (selectedImages.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedImages.length} image(s) selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImages[index],
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  cacheHeight: 300,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => removeImage(index),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  'No images selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

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
