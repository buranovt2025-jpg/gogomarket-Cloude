import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderItemModel {
  final String id;
  final String productId;
  final String? variantId;
  final String title;
  final String? photoUrl;
  final int quantity;
  final int priceTiyin;

  const OrderItemModel({
    required this.id, required this.productId, this.variantId,
    required this.title, this.photoUrl,
    required this.quantity, required this.priceTiyin,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
    _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  int get totalTiyin => priceTiyin * quantity;
}

@JsonSerializable()
class OrderModel extends Equatable {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? courierId;
  final String status;
  final int totalTiyin;
  final String deliveryService;
  final String? deliveryAddress;
  final String? trackingId;
  final String? buyerNote;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.courierId,
    required this.status,
    required this.totalTiyin,
    required this.deliveryService,
    this.deliveryAddress,
    this.trackingId,
    this.buyerNote,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
    _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  int get totalSum => totalTiyin ~/ 100;
  bool get isActive => !['done', 'cancelled'].contains(status);
  bool get isDispute => status == 'dispute';
  bool get canReview => status == 'done';

  @override
  List<Object?> get props => [id, status, totalTiyin];
}
