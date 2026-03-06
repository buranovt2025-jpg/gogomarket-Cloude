import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String  id;
  final String  sellerId;
  final String? categoryId;
  final String  title;
  final String? description;
  final int     priceTiyin;
  final int?    oldPriceTiyin;
  final int?    originalPriceTiyin; // alias
  final int     stock;
  final String  status;
  final double  avgRating;
  final int     reviewCount;
  final bool    isBoosted;
  final int     viewCount;
  final int     saleCount;
  final List<String> photoUrls;
  final List<String> photos; // alias
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.title,
    this.description,
    required this.priceTiyin,
    this.oldPriceTiyin,
    int? originalPriceTiyin,
    required this.stock,
    required this.status,
    required this.avgRating,
    required this.reviewCount,
    required this.isBoosted,
    required this.viewCount,
    required this.saleCount,
    List<String>? photoUrls,
    List<String>? photos,
    required this.createdAt,
  })  : photoUrls = photoUrls ?? photos ?? [],
        photos = photoUrls ?? photos ?? [],
        originalPriceTiyin = originalPriceTiyin ?? oldPriceTiyin;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id:            json['id'] as String,
    sellerId:      json['sellerId'] as String,
    categoryId:    json['categoryId'] as String?,
    title:         json['title'] as String,
    description:   json['description'] as String?,
    priceTiyin:    (json['priceTiyin'] as num?)?.toInt() ?? 0,
    oldPriceTiyin: (json['oldPriceTiyin'] as num?)?.toInt(),
    stock:         (json['stock'] as num?)?.toInt() ?? 0,
    status:        json['status'] as String? ?? 'active',
    avgRating:     (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    reviewCount:   (json['reviewCount'] as num?)?.toInt() ?? 0,
    isBoosted:     json['isBoosted'] as bool? ?? false,
    viewCount:     (json['viewCount'] as num?)?.toInt() ?? 0,
    saleCount:     (json['saleCount'] as num?)?.toInt() ?? 0,
    photoUrls:     (json['photoUrls'] as List?)?.cast<String>() ?? [],
    createdAt:     DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'sellerId': sellerId, 'categoryId': categoryId,
    'title': title, 'description': description,
    'priceTiyin': priceTiyin, 'oldPriceTiyin': oldPriceTiyin,
    'stock': stock, 'status': status,
    'avgRating': avgRating, 'reviewCount': reviewCount,
    'isBoosted': isBoosted, 'viewCount': viewCount, 'saleCount': saleCount,
    'photoUrls': photoUrls,
    'createdAt': createdAt.toIso8601String(),
  };

  double get priceUzs => priceTiyin / 100;
  double? get oldPriceUzs => oldPriceTiyin != null ? oldPriceTiyin! / 100 : null;
  bool get hasDiscount => oldPriceTiyin != null && oldPriceTiyin! > priceTiyin;

  @override
  List<Object?> get props => [id, priceTiyin, status];
}
