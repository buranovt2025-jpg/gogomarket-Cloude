class SellerPendingModel {
  final String id;
  final String shopName;
  final String? inn;
  final String? passportUrl;
  final DateTime createdAt;

  const SellerPendingModel({
    required this.id, required this.shopName,
    this.inn, this.passportUrl, required this.createdAt,
  });

  factory SellerPendingModel.fromJson(Map<String, dynamic> j) => SellerPendingModel(
    id:          j['id'] as String,
    shopName:    j['shopName'] as String? ?? '',
    inn:         j['inn'] as String?,
    passportUrl: j['passportUrl'] as String?,
    createdAt:   DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
