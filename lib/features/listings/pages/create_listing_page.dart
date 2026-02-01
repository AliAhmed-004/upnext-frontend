import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/utils/helper_methods.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/core/widgets/custom_snackbar.dart';
import 'package:upnext/core/widgets/custom_textfield.dart';
import 'package:upnext/features/listings/models/listing_model.dart';
import 'package:upnext/features/listings/providers/listing_provider.dart';

/// Page for creating a new listing.
/// 
/// Uses providers for user data and listing creation.
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
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Pick images from gallery.
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
        _showError('Error', 'Failed to pick images.');
      }
    }
  }

  /// Remove image from selection.
  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  /// Create listing using provider.
  void createListing() async {
    // Get user from provider
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      _showError('User Not Logged In', 'Please log in to create a listing.');
      return;
    }

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    // Validate input
    if (selectedLocation == null) {
      _showError('Location Required', 'Please pick a location for the listing.');
      return;
    }

    if (title.isEmpty || description.isEmpty || selectedCategory == null) {
      _showError('Missing Information', 'Please fill in all required fields.');
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Create listing data
      final listingData = {
        'user_id': user.id,
        'title': title,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'category': selectedCategory ?? 'Other',
        'status': Status.active.name,
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
      };

      // Create through provider
      final success = await context.read<ListingProvider>().createListing(
        listingData,
        selectedImages,
      );

      if (mounted && success) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar.show(
        title: title,
        message: message,
        type: SnackbarType.error,
      ),
    );
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

              // Title field
              _buildLabel('Title'),
              const SizedBox(height: 8),
              CustomTextfield(
                hintText: "What are you offering?",
                controller: titleController,
              ),
              const SizedBox(height: 24),

              // Description field
              _buildLabel('Description'),
              const SizedBox(height: 8),
              CustomTextfield(
                hintText: "Tell us more about it...",
                controller: descriptionController,
              ),
              const SizedBox(height: 40),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: <String>[
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
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Location picker
              CustomButton(
                onPressed: () async {
                  final result = await Get.toNamed('/pick_location');
                  if (result != null) {
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
              _buildLabel('Images'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Pick Images'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),

              // Image preview
              if (selectedImages.isNotEmpty) ...[
                _buildImagePreview(),
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

              // Create button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: createListing,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: const Icon(Icons.broken_image),
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
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
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
    );
  }
}
