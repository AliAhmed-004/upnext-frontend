import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/providers/user_provider.dart';
import '../providers/listing_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ListingModel> _currentListings = [];

  @override
  void initState() {
    super.initState();
    // Trigger data fetch once when the widget is ready
    _getListings();
  }

  void _getListings() {
    Future.microtask(() async {
      await context.read<ListingProvider>().getListings(forceRefresh: true);
      if (mounted) {
        setState(() {
          _currentListings = context.read<ListingProvider>().listings;
        });
      }
    });
  }

  // Logout confirmation dialog
  void logoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to logout"),
        actions: [
          TextButton(
            onPressed: () {
              // Remove user from storage
              context.read<UserProvider>().clearUser();

              // Navigate back to login page and clear all previous routes
              Get.offAllNamed('/login');
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/create_listing')!.then((_) => _getListings());
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
            Get.toNamed('/profile')!.then((_) => _getListings());
          },
          icon: const Icon(Icons.person_outline_rounded),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // New listings available banner
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.getListings(forceRefresh: true);
                  if (mounted) {
                    setState(() {
                      _currentListings = provider.listings;
                    });
                  }
                },
                child: _buildListContent(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(ListingProvider provider) {
    if (provider.isLoading) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading listings...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    if (provider.listings.isEmpty) {
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(Icons.search_off_outlined, size: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No listings found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Other users have not created any listings yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (provider.userListings.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    '... but you have ${provider.userListings.length} listing(s)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  CustomButton(
                    onPressed: () {
                      Get.toNamed('/user_listings');
                    },
                    buttonText: 'Manage my listings',
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.listings.length,
      itemBuilder: (context, index) {
        final listing = provider.listings[index];
        return ListingTile(
          listingModel: listing,
          isFromUserListings: false,
          onRefresh: () async {
            await provider.getListings(forceRefresh: true);
            if (mounted) {
              setState(() {
                _currentListings = provider.listings;
              });
            }
          },
        );
      },
    );
  }
}
