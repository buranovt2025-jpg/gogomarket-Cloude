class FlaggedContentModel {
  final String id;
  final String type;
  final String title;
  final String reason;
  final String sellerId;
  final String? sellerName;
  final DateTime createdAt;

  const FlaggedContentModel({
    required this.id, required this.type, required this.title,
    required this.reason, required this.sellerId,
    this.sellerName, required this.createdAt,
  });

  factory FlaggedContentModel.fromJson(Map<String, dynamic> j) => FlaggedContentModel(
    id:         j['id'] as String,
    type:       j['type'] as String? ?? 'product',
    title:      j['title'] as String? ?? '',
    reason:     j['reason'] as String? ?? '',
    sellerId:   j['sellerId'] as String? ?? '',
    sellerName: j['sellerName'] as String?,
    createdAt:  DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'title': title, 'reason': reason,
    'sellerId': sellerId, 'sellerName': sellerName,
    'createdAt': createdAt.toIso8601String(),
  };
}
