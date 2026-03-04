import 'package:json_annotation/json_annotation.dart';
part 'admin_order_model.g.dart';

@JsonSerializable()
class AdminOrderModel {
  final String id;
  final String buyerName;
  final String sellerName;
  final String productTitle;
  final int totalTiyin;
  final String status;
  final DateTime createdAt;

  const AdminOrderModel({
    required this.id, required this.buyerName, required this.sellerName,
    required this.productTitle, required this.totalTiyin,
    required this.status, required this.createdAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) =>
    _\$AdminOrderModelFromJson(json);
  Map<String, dynamic> toJson() => _\$AdminOrderModelToJson(this);

  int get totalSum => totalTiyin ~/ 100;
}
