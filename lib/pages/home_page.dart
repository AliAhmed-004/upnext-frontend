import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/components/listing_tile.dart';
import 'package:upnext/providers/user_provider.dart';
import '../providers/listing_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _categories = [];
  String? _selectedCategory;
  bool _filtersExpanded = false;

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
          _extractCategories();
        });
      }
    });
  }

  void _extractCategories() {
    final provider = context.read<ListingProvider>();
    final allListings = [...provider.listings, ...provider.userListings];
    
    final categorySet = allListings
        .map((listing) => listing.category)
        .where((category) => category.isNotEmpty)
        .toSet();
    
    _categories = categorySet.toList()..sort();
  }

  Future<void> _filterEntriesByCategory(String category) async {
    if (_selectedCategory == category) {
      // Deselect and fetch all listings
      setState(() {
        _selectedCategory = null;
      });
      _getListings();
    } else {
      // Select category and fetch filtered listings
      setState(() {
        _selectedCategory = category;
      });
      
      final provider = context.read<ListingProvider>();
      await provider.getListingsByCategory(category);
    }
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
    final hasListings = provider.listings.isNotEmpty || provider.userListings.isNotEmpty;

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
            // Filter section with category chips
            if (hasListings) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Filters',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      if (_selectedCategory != null) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      Spacer(),
                      AnimatedRotation(
                        turns: _filtersExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    if (_categories.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length + 1, // +1 for "ALL" chip
                          itemBuilder: (BuildContext context, int index) {
                            // First chip is "ALL"
                            if (index == 0) {
                              bool isSelected = _selectedCategory == null;
                              return Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.3),
                                      width: 1.2,
                                    ),
                                    backgroundColor: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08)
                                        : Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    minimumSize: Size(0, 28),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_selectedCategory != null) {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                      _getListings();
                                    }
                                  },
                                  child: Text(
                                    'ALL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.8),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            // Category chips (index - 1 because first is "ALL")
                            String currentCategory = _categories[index - 1];
                            bool isSelected =
                                currentCategory == _selectedCategory;
                            return Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.3),
                                    width: 1.2,
                                  ),
                                  backgroundColor: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.08)
                                      : Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  minimumSize: Size(0, 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () =>
                                    _filterEntriesByCategory(currentCategory),
                                child: Text(
                                  currentCategory.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ],
                ),
                crossFadeState: _filtersExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 200),
              ),
            ],

            // Listview of listings
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _selectedCategory = null;
                  });
                  await provider.getListings(forceRefresh: true);
                  if (mounted) {
                    setState(() {
                      _extractCategories();
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
                Text(
                  _selectedCategory != null 
                      ? 'No listings in $_selectedCategory'
                      : 'No listings found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory != null
                      ? 'Try selecting a different category'
                      : 'Other users have not created any listings yet.',
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
          },
        );
      },
    );
  }
}
