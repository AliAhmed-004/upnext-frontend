class ListingModel {
  final String id;
  final String title;
  final String user_id;
  final String description;

  ListingModel({
    required this.id,
    required this.title,
    required this.user_id,
    required this.description,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'],
      user_id: map['user_id'],
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'user_id': user_id,
      'description': description,
    };
  }
}
