import 'package:cooking_master/domain/entities/user.dart';

/// Data model for User with JSON serialization support
class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.createdAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
}
