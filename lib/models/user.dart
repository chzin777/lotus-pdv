import 'package:intl/intl.dart';

class User {
  final String id;
  final String username;
  final String password; // In production, use hashed passwords
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.role = UserRole.seller,
    this.isActive = true,
    DateTime? createdAt,
    this.profileImage,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'profileImage': profileImage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      fullName: json['fullName'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.seller,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      profileImage: json['profileImage'],
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? fullName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

enum UserRole {
  admin,
  seller,
  manager,
}
