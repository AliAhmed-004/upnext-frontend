import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final Timestamp? createdAt;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.username,
    required this.email,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp)
          : null,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
