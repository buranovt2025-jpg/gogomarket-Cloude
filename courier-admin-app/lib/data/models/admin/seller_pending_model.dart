import 'package:json_annotation/json_annotation.dart';
part 'seller_pending_model.g.dart';

@JsonSerializable()
class SellerPendingModel {
  final String id;
  final String shopName;
  final String? inn;
  final String? passportUrl;
  final String userId;
  final DateTime createdAt;

  const SellerPendingModel({
    required this.id, required this.shopName,
    this.inn, this.passportUrl,
    required this.userId, required this.createdAt,
  });

  factory SellerPendingModel.fromJson(Map<String, dynamic> json) =>
    _\$SellerPendingModelFromJson(json);
  Map<String, dynamic> toJson() => _\$SellerPendingModelToJson(this);
}
