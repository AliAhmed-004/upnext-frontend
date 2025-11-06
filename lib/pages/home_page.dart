import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/providers/user_provider.dart';

import '../components/custom_button.dart';
import '../providers/listing_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Trigger data fetch once when the widget is ready
    _getListings();
  }

  void _getListings() {
    Future.microtask(
      () => context.read<ListingProvider>().getListings(forceRefresh: true),
    );
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: null, // inherit
          ),
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
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.getListings(forceRefresh: true);
          },
          child: provider.isLoading
              ? RefreshIndicator(
                  onRefresh: () async {
                    await provider.getListings(forceRefresh: true);
                  },
                  child: ListView(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.transparent,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading listings...',
                              style: TextStyle(color: null, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : provider.listings.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await provider.getListings(forceRefresh: true);
                  },
                  child: ListView(
                    children: [
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
                              child: const Icon(
                                Icons.search_off_outlined,
                                size: 60,
                                color: null,
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Text(
                              'No listings found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Other users have not created any listings yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),

                            // If the user has created listings, allow them to manage them
                            if (provider.userListings.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                '... but you have ${provider.userListings.length} listing(s)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
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
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: provider.listings.length,
                  itemBuilder: (context, index) {
                    final listing = provider.listings[index];

                    return ListingTile(
                      listingModel: listing,
                      isFromUserListings: false,
                      onRefresh: () async {
                        await provider.getListings(forceRefresh: true);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
