import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String role; // buyer | seller | courier | admin
  final bool isVerified;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
    _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isSeller  => role == 'seller';
  bool get isBuyer   => role == 'buyer';
  bool get isCourier => role == 'courier';
  bool get isAdmin   => role == 'admin' || role == 'superadmin';

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    String? fcmToken,
  }) => UserModel(
    id: id, phone: phone, role: role, isVerified: isVerified,
    createdAt: createdAt,
    name:      name      ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    fcmToken:  fcmToken  ?? this.fcmToken,
  );

  @override
  List<Object?> get props => [id, phone, role, name, isVerified];
}
