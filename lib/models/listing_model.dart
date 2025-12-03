enum Status { active, booked, inactive }

class ListingModel {
  final String id; // Firestore ID
  final String title;
  final String user_id;
  final String description;
  final String created_at;
  final String status;
  final String category;
  final double latitude;
  final double longitude;
  final String? booked_by; // User ID of who booked it
  final String? booked_at; // Timestamp when booked

  ListingModel({
    required this.id,
    required this.title,
    required this.user_id,
    required this.description,
    required this.created_at,
    required this.status,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.booked_by,
    this.booked_at,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'],
      title: map['title'],
      user_id: map['user_id'],
      description: map['description'],
      created_at: map['created_at'],
      status: map['status'],
      category: map['category'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      booked_by: map['booked_by'],
      booked_at: map['booked_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'user_id': user_id,
      'description': description,
      'created_at': created_at,
      'status': status,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'booked_by': booked_by,
      'booked_at': booked_at,
    };
  }
}
