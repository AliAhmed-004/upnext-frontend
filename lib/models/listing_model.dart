enum Status { active, booked, inactive }

class ListingModel {
  final String id;
  final String title;
  final String user_id;
  final String description;
  final String created_at;
  final String status;
  final String category;
  final double latitude;
  final double longitude;

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
    };
  }
}
