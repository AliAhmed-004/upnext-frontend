class ListingModel {
  final int id;
  final String title;
  final String description;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'description': description};
  }
}
