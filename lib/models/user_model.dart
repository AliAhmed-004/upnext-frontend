class UserModel {
  final String id;
  final String username;
  final String email;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
