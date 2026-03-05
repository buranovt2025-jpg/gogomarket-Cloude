import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String   id;
  final String   buyerId;
  final String   sellerId;
  final String   status;
  final int      totalTiyin;
  final String?  deliveryAddress;
  final String   deliveryService;
  final String?  trackingCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id, required this.buyerId, required this.sellerId,
    required this.status, required this.totalTiyin,
    this.deliveryAddress, required this.deliveryService,
    this.trackingCode, required this.createdAt, required this.updatedAt,
  });

  double get totalUzs => totalTiyin / 100;

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id'], buyerId: j['buyerId'], sellerId: j['sellerId'],
    status: j['status'] ?? 'new', totalTiyin: j['totalTiyin'] ?? 0,
    deliveryAddress: j['deliveryAddress'],
    deliveryService: j['deliveryService'] ?? 'self',
    trackingCode: j['trackingCode'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
  );

  @override List<Object?> get props => [id, status];
}
