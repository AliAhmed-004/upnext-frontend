import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

              // Navigate back to login page
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamed('/create_listing').then((_) => _getListings());
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(onPressed: logoutConfirmation, icon: Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.getListings(forceRefresh: true);
          },
          child: provider.isLoading
              ? ListView(
                  // trick to make RefreshIndicator work even when loading
                  children: const [
                    SizedBox(height: 300),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
              : provider.listings.isEmpty
              ? ListView(
                  // trick: make it scrollable even when empty
                  children: const [
                    SizedBox(height: 300),
                    Center(child: Text('No listings available.')),
                  ],
                )
              : ListView.builder(
                  itemCount: provider.listings.length,
                  itemBuilder: (context, index) {
                    final listing = provider.listings[index];
                    return ListTile(
                      title: Text(listing.title),
                      subtitle: Text(listing.description),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
