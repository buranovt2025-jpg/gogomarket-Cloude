import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:         json['id'] as String,
    phone:      json['phone'] as String,
    name:       json['name'] as String?,
    avatarUrl:  json['avatarUrl'] as String?,
    role:       json['role'] as String? ?? 'buyer',
    isVerified: json['isVerified'] as bool? ?? false,
    createdAt:  DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'phone': phone, 'name': name,
    'avatarUrl': avatarUrl, 'role': role,
    'isVerified': isVerified, 'createdAt': createdAt.toIso8601String(),
  };

  bool get isSeller => role == 'seller';
  bool get isBuyer  => role == 'buyer';
  bool get isAdmin  => role == 'admin' || role == 'superadmin';

  @override
  List<Object?> get props => [id, role, isVerified];
}
