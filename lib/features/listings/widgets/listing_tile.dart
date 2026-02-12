import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/utils/helper_methods.dart';
import 'package:upnext/core/models/listing_model.dart';
import 'package:upnext/features/listings/pages/listing_details_page.dart';

/// A tile widget displaying a summary of a listing.
/// 
/// Used in list views to show listing info with actions like delete/cancel.
class ListingTile extends StatefulWidget {
  final ListingModel listingModel;
  final bool isFromUserListings;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  const ListingTile({
    super.key,
    required this.listingModel,
    required this.isFromUserListings,
    this.onRefresh,
    this.onDelete,
    this.onCancel,
  });

  @override
  State<ListingTile> createState() => _ListingTileState();
}

class _ListingTileState extends State<ListingTile> {
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  /// Loads the username of the listing creator through UserProvider.
  void _loadUserName() async {
    final userProvider = context.read<UserProvider>();
    final user = await userProvider.fetchUserById(widget.listingModel.userId);
    
    if (!mounted) return;
    setState(() {
      _userName = user?.username ?? "Unknown User";
    });
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listingModel;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsPage(
              isFromUserListings: widget.isFromUserListings,
              listingId: listing.id,
            ),
          ),
        ).then((_) {
          // Refresh if callback provided
          widget.onRefresh?.call();
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Posted on ${formatIsoDate(listing.createdAt)}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  listing.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  listing.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Delete button for user's own listings
                if (widget.isFromUserListings && widget.onDelete != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
                
                // Cancel button for booked listings
                if (widget.onCancel != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancel Booking'),
                        style: TextButton.styleFrom(foregroundColor: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
