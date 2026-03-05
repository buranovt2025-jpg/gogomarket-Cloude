import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel extends Equatable {
  final String   id;
  final String   buyerId;
  final String   sellerId;
  final String   status;
  final int      totalTiyin;
  final String?  deliveryAddress;
  final double?  deliveryLat;
  final double?  deliveryLng;
  final String   deliveryService;
  final String?  buyerNote;
  final String?  trackingCode;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.totalTiyin,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.deliveryService,
    this.buyerNote,
    this.trackingCode,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _\$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _\$OrderModelToJson(this);

  @override
  List<Object?> get props => [id, status];
}

@JsonSerializable()
class OrderItemModel extends Equatable {
  final String  id;
  final String  productId;
  final String? variantId;
  final int     quantity;
  final int     priceTiyin;
  final String  title;

  const OrderItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.priceTiyin,
    required this.title,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _\$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _\$OrderItemModelToJson(this);

  @override
  List<Object?> get props => [id];
}
