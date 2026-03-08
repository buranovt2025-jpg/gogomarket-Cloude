class CourierOrderModel {
  final String id;
  final String buyerName;
  final String buyerPhone;
  final String address;
  final double? lat;
  final double? lng;
  final int totalTiyin;
  final String status;
  final DateTime createdAt;

  const CourierOrderModel({
    required this.id, required this.buyerName, required this.buyerPhone,
    required this.address, this.lat, this.lng,
    required this.totalTiyin, required this.status, required this.createdAt,
  });

  factory CourierOrderModel.fromJson(Map<String, dynamic> j) => CourierOrderModel(
    id:         j['id'] as String,
    buyerName:  j['buyerName'] as String? ?? '',
    buyerPhone: j['buyerPhone'] as String? ?? '',
    address:    j['address'] as String? ?? '',
    lat:        (j['lat'] as num?)?.toDouble(),
    lng:        (j['lng'] as num?)?.toDouble(),
    totalTiyin: (j['totalAmount'] as num?)?.toInt() ?? 0,
    status:     j['status'] as String? ?? '',
    createdAt:  DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  int get totalSum => totalTiyin ~/ 100;
}
