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

  factory AdminOrderModel.fromJson(Map<String, dynamic> j) => AdminOrderModel(
    id:           j['id'] as String,
    buyerName:    j['buyerName'] as String? ?? '',
    sellerName:   j['sellerName'] as String? ?? '',
    productTitle: j['productTitle'] as String? ?? '',
    totalTiyin:   (j['totalAmount'] as num?)?.toInt() ?? 0,
    status:       j['status'] as String? ?? '',
    createdAt:    DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'buyerName': buyerName, 'sellerName': sellerName,
    'productTitle': productTitle, 'totalTiyin': totalTiyin,
    'status': status, 'createdAt': createdAt.toIso8601String(),
  };

  int get totalSum => totalTiyin ~/ 100;
}
