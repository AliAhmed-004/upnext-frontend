import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class handling all Supabase storage operations.
/// This includes uploading, downloading, and managing files in Supabase Storage.
class SupabaseStorageService {
  final _supabase = Supabase.instance.client;

  /// The bucket name for listing images.
  static const String _listingImagesBucket = 'listing-images';

  /// Upload images for a listing.
  /// 
  /// [listingId] - The ID of the listing to upload images for.
  /// [images] - List of image files to upload.
  /// 
  /// Returns a list of storage paths for the uploaded images.
  Future<List<String>> uploadListingImages(
    String listingId,
    List<File> images,
  ) async {
    final uploadedPaths = <String>[];

    for (var image in images) {
      // Extract file extension
      final extension = image.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'listings/$listingId/$fileName';

      debugPrint('Uploading image to $storagePath');

      await _supabase.storage
          .from(_listingImagesBucket)
          .upload(storagePath, image);

      uploadedPaths.add(storagePath);
    }

    return uploadedPaths;
  }

  /// Fetch all image URLs for a listing.
  /// 
  /// [listingId] - The ID of the listing to fetch images for.
  /// 
  /// Returns a list of public URLs for the listing's images.
  Future<List<String>> fetchListingImageUrls(String listingId) async {
    try {
      final List<FileObject> imageResponse = await _supabase.storage
          .from(_listingImagesBucket)
          .list(path: 'listings/$listingId');

      debugPrint('Images fetched from storage: ${imageResponse.length}');

      final imageUrls = <String>[];
      for (var item in imageResponse) {
        final publicUrl = _supabase.storage
            .from(_listingImagesBucket)
            .getPublicUrl('listings/$listingId/${item.name}');
        imageUrls.add(publicUrl);
      }

      return imageUrls;
    } catch (e) {
      debugPrint('Error fetching listing images: $e');
      return [];
    }
  }

  /// Delete all images for a listing.
  /// 
  /// [listingId] - The ID of the listing to delete images for.
  Future<void> deleteListingImages(String listingId) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(_listingImagesBucket)
          .list(path: 'listings/$listingId');

      if (files.isNotEmpty) {
        final paths = files
            .map((file) => 'listings/$listingId/${file.name}')
            .toList();
        await _supabase.storage.from(_listingImagesBucket).remove(paths);
      }
    } catch (e) {
      debugPrint('Error deleting listing images: $e');
    }
  }
}
