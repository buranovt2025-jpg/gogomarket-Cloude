import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'seller_model.g.dart';

@JsonSerializable()
class SellerModel extends Equatable {
  final String id;
  final String userId;
  final String shopName;
  final String? description;
  final String? logoUrl;
  final String? inn;
  final String plan; // basic|start|business|shop
  final bool isVerified;
  final double avgRating;
  final int reviewCount;
  final int followerCount;
  final DateTime createdAt;

  const SellerModel({
    required this.id,
    required this.userId,
    required this.shopName,
    this.description,
    this.logoUrl,
    this.inn,
    required this.plan,
    required this.isVerified,
    this.avgRating = 0,
    this.reviewCount = 0,
    this.followerCount = 0,
    required this.createdAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) =>
    _$SellerModelFromJson(json);
  Map<String, dynamic> toJson() => _$SellerModelToJson(this);

  bool get isPro => plan != 'basic';
  bool get isBusiness => plan == 'business' || plan == 'shop';
  bool get isShop => plan == 'shop';

  @override
  List<Object?> get props => [id, shopName, plan, isVerified];
}
