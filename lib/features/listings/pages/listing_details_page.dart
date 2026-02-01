import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/utils/helper_methods.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/features/listings/models/listing_model.dart';
import 'package:upnext/features/listings/providers/listing_provider.dart';
import 'package:upnext/features/listings/widgets/item_location_map.dart';

/// Page displaying full details of a listing.
/// 
/// Shows listing info, images, location map, and booking actions.
class ListingDetailsPage extends StatefulWidget {
  final String listingId;
  final bool isFromUserListings;

  const ListingDetailsPage({
    super.key,
    required this.listingId,
    required this.isFromUserListings,
  });

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  String _createdBy = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  /// Load listing details through the provider.
  void _loadListingDetails() async {
    setState(() => _isLoading = true);
    
    // Fetch listing through provider
    final listing = await context.read<ListingProvider>().fetchListingById(widget.listingId);
    
    if (listing != null && mounted) {
      // Fetch creator's username through UserProvider
      final creatorUser = await context.read<UserProvider>().fetchUserById(listing.userId);
      
      if (mounted) {
        setState(() {
          _createdBy = creatorUser?.username ?? 'Unknown User';
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Book the listing through provider.
  void _bookListing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Item'),
        content: const Text('Are you sure you want to book this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Book'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await context.read<ListingProvider>().bookListing(widget.listingId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Unknown error'),
          backgroundColor: result['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.watch<ListingProvider>().selectedListing;

    if (_isLoading || listing == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final location = LatLng(listing.latitude, listing.longitude);
    final formattedDate = formatIsoDate(listing.createdAt);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          listing.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
              // Author section
              _buildAuthorSection(formattedDate),
              const SizedBox(height: 32),

              // Title and status
              _buildTitleSection(listing),
              const SizedBox(height: 24),

              // Description
              _buildDescriptionSection(listing),
              const SizedBox(height: 24),

              // Address
              _buildAddressSection(location),
              const SizedBox(height: 24),

              // Images
              _buildImagesSection(listing),
              const SizedBox(height: 24),

              // Map
              ItemLocationMap(location: location),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(listing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorSection(String formattedDate) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _createdBy,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              Text(
                "Created at: $formattedDate",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(ListingModel listing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Category: ${listing.category}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(listing.status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    
    if (status == Status.active.name) {
      bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
      textColor = Theme.of(context).colorScheme.primary;
    } else if (status == Status.inactive.name) {
      bgColor = Theme.of(context).colorScheme.error.withOpacity(0.18);
      textColor = Theme.of(context).colorScheme.error;
    } else {
      bgColor = Theme.of(context).colorScheme.surface;
      textColor = Theme.of(context).colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ListingModel listing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            listing.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(LatLng location) {
    return FutureBuilder<String>(
      future: getAddressFromLatLng(location.latitude, location.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return Text(
          'Address: ${snapshot.data ?? 'Unknown'}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.6,
          ),
        );
      },
    );
  }

  Widget _buildImagesSection(ListingModel listing) {
    final imageUrls = listing.imageUrls;

    if (imageUrls == null || imageUrls.isEmpty) {
      return Text(
        "No images available for this listing.",
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Images:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrls[index],
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 300,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ListingModel listing) {
    // Show book button if not user's listing and active
    if (!widget.isFromUserListings && listing.isActive) {
      return CustomButton(onPressed: _bookListing, buttonText: "Book Item");
    }

    // Show booked message if already booked
    if (!widget.isFromUserListings && listing.isBooked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'This item has already been booked',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
