/// Model class representing a user in the application.
/// 
/// This is the single source of truth for user data structure throughout the app.
class UserModel {
  final String id;
  final String username;
  final String email;
  final double? latitude;
  final double? longitude;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.latitude,
    this.longitude,
  });

  /// Creates a [UserModel] from a map (typically from database response).
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  /// Converts this [UserModel] to a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Returns true if user has location data set.
  bool get hasLocation => latitude != null && longitude != null;

  /// Returns the user's initials (for avatar display).
  String get initials {
    if (username.trim().isEmpty) return '?';
    final parts = username.trim().split(RegExp(r"\s+|[_\-.]"));
    final letters = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
    return letters.join().toUpperCase();
  }

  /// Creates a copy of this user with optional new values.
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, '
        'latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
