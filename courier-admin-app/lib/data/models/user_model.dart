import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String role;
  final bool isVerified;

  const UserModel({
    required this.id, required this.phone,
    this.name, this.avatarUrl,
    required this.role, required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _\$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _\$UserModelToJson(this);

  bool get isCourier => role == 'courier';
  bool get isAdmin   => role == 'admin' || role == 'superadmin';

  @override
  List<Object?> get props => [id, role];
}
