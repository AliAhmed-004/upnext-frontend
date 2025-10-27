enum Status { active, inactive, sold }

class ListingModel {
  final String id;
  final String title;
  final String user_id;
  final String description;
  final String created_at;
  final String status;
  final String category;
  final String location;

  ListingModel({
    required this.id,
    required this.title,
    required this.user_id,
    required this.description,
    required this.created_at,
    required this.status,
    required this.category,
    required this.location,
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
      location: map['location'],
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
      'location': location,
    };
  }
}
