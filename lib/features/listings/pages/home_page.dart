import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/features/listings/providers/listing_provider.dart';
import 'package:upnext/features/listings/widgets/listing_tile.dart';

/// Home page displaying all available listings.
/// 
/// Shows listings from other users (excludes current user's listings).
/// Provides navigation to create listings and profile.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch listings when page loads
    _loadListings();
  }

  /// Loads listings through the provider.
  void _loadListings() {
    Future.microtask(() {
      context.read<ListingProvider>().fetchListings(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      // Floating action button to create new listing
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/create_listing')?.then((_) => _loadListings());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      
      appBar: AppBar(
        title: const Text(
          'Up Next',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          onPressed: () {
            Get.toNamed('/profile')?.then((_) => _loadListings());
          },
          icon: const Icon(Icons.person_outline_rounded),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await listingProvider.fetchListings(forceRefresh: true);
          },
          child: _buildContent(listingProvider),
        ),
      ),
    );
  }

  Widget _buildContent(ListingProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading listings...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // Empty state
    if (provider.listings.isEmpty) {
      return _buildEmptyState();
    }

    // Listings list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.listings.length,
      itemBuilder: (context, index) {
        final listing = provider.listings[index];
        return ListingTile(
          listingModel: listing,
          isFromUserListings: false,
          onRefresh: () => provider.fetchListings(forceRefresh: true),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No listings yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share something!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: () {
                  Get.toNamed('/create_listing')?.then((_) => _loadListings());
                },
                buttonText: 'Create Listing',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
