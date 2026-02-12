/// Enum representing the possible statuses of a listing.
enum Status { active, booked, inactive }

/// Model class representing a listing in the application.
/// 
/// This is the single source of truth for listing data structure throughout the app.
class ListingModel {
  final String id;
  final String title;
  final String userId;
  final String description;
  final String createdAt;
  final String status;
  final String category;
  final double latitude;
  final double longitude;
  final String? bookedBy;
  final String? bookedAt;
  final List<String>? imageUrls;

  const ListingModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.bookedBy,
    this.bookedAt,
    this.imageUrls,
  });

  /// Creates a [ListingModel] from a map (typically from database response).
  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'],
      title: map['title'],
      userId: map['user_id'],
      description: map['description'],
      createdAt: map['created_at'],
      status: map['status'],
      category: map['category'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      bookedBy: map['booked_by'],
      bookedAt: map['booked_at'],
      imageUrls: map['image_urls'] != null 
          ? List<String>.from(map['image_urls']) 
          : null,
    );
  }

  /// Converts this [ListingModel] to a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'description': description,
      'created_at': createdAt,
      'status': status,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'booked_by': bookedBy,
      'booked_at': bookedAt,
      'image_urls': imageUrls,
    };
  }

  /// Returns true if this listing is active (available for booking).
  bool get isActive => status == Status.active.name;

  /// Returns true if this listing is booked.
  bool get isBooked => status == Status.booked.name;

  /// Returns true if this listing is inactive.
  bool get isInactive => status == Status.inactive.name;

  /// Creates a copy of this listing with optional new values.
  ListingModel copyWith({
    String? id,
    String? title,
    String? userId,
    String? description,
    String? createdAt,
    String? status,
    String? category,
    double? latitude,
    double? longitude,
    String? bookedBy,
    String? bookedAt,
    List<String>? imageUrls,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bookedBy: bookedBy ?? this.bookedBy,
      bookedAt: bookedAt ?? this.bookedAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  @override
  String toString() {
    return 'ListingModel(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
