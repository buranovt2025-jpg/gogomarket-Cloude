import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'courier_order_model.g.dart';

@JsonSerializable()
class CourierOrderModel extends Equatable {
  final String id;
  final String status;
  final String buyerName;
  final String sellerName;
  final String sellerAddress;
  final String deliveryAddress;
  final double sellerLat;
  final double sellerLng;
  final double deliveryLat;
  final double deliveryLng;
  final int feeTiyin;
  final double distanceKm;
  final int etaMinutes;
  final String productTitle;
  final String? productPhotoUrl;
  final String? buyerPhone;
  final DateTime createdAt;

  const CourierOrderModel({
    required this.id, required this.status,
    required this.buyerName, required this.sellerName,
    required this.sellerAddress, required this.deliveryAddress,
    required this.sellerLat, required this.sellerLng,
    required this.deliveryLat, required this.deliveryLng,
    required this.feeTiyin, required this.distanceKm,
    required this.etaMinutes, required this.productTitle,
    this.productPhotoUrl, this.buyerPhone,
    required this.createdAt,
  });

  factory CourierOrderModel.fromJson(Map<String, dynamic> json) =>
    _\$CourierOrderModelFromJson(json);
  Map<String, dynamic> toJson() => _\$CourierOrderModelToJson(this);

  int get feeSum => feeTiyin ~/ 100;

  @override
  List<Object?> get props => [id, status];
}
