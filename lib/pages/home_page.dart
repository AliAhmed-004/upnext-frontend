import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/services/database_service.dart';

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
              // Remove user from database
              final dbHelper = DatabaseService();
              dbHelper.logout();

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
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/create_listing')!.then((_) => _getListings());
        },
        backgroundColor: const Color(0xFF6366F1),
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
            color: Color(0xFF1F2937),
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
                                Color(0xFF6366F1),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading listings...',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                              ),
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
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Icon(
                                Icons.inbox_outlined,
                                size: 60,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),

                            const SizedBox(height: 24),
                            const Text(
                              'No listings yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to create a listing!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
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
