import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String  id;
  final String  phone;
  final String? name;
  final String? avatarUrl;
  final String  role;       // buyer | seller | courier | admin
  final bool    isVerified;
  final String? sellerPlan; // null | start | business | store

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    this.sellerPlan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isBuyer   => role == 'buyer';
  bool get isSeller  => role == 'seller';
  bool get isCourier => role == 'courier';
  bool get isAdmin   => role == 'admin' || role == 'superadmin';
  bool get isPro     => sellerPlan != null;

  @override
  List<Object?> get props => [id, role, sellerPlan];
}
