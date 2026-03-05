import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String  id;
  final String  sellerId;
  final String? categoryId;
  final String  title;
  final String? description;
  final int     priceTiyin;
  final int?    oldPriceTiyin;
  final int     stock;
  final String  status;
  final double  avgRating;
  final int     reviewCount;
  final bool    isBoosted;
  final int     viewCount;
  final int     saleCount;
  final List<String> photoUrls;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.title,
    this.description,
    required this.priceTiyin,
    this.oldPriceTiyin,
    required this.stock,
    required this.status,
    required this.avgRating,
    required this.reviewCount,
    required this.isBoosted,
    required this.viewCount,
    required this.saleCount,
    required this.photoUrls,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id:            json['id'] as String,
    sellerId:      json['sellerId'] as String,
    categoryId:    json['categoryId'] as String?,
    title:         json['title'] as String,
    description:   json['description'] as String?,
    priceTiyin:    json['priceTiyin'] as int,
    oldPriceTiyin: json['oldPriceTiyin'] as int?,
    stock:         json['stock'] as int? ?? 0,
    status:        json['status'] as String? ?? 'active',
    avgRating:     (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    reviewCount:   json['reviewCount'] as int? ?? 0,
    isBoosted:     json['isBoosted'] as bool? ?? false,
    viewCount:     json['viewCount'] as int? ?? 0,
    saleCount:     json['saleCount'] as int? ?? 0,
    photoUrls:     (json['photoUrls'] as List<dynamic>?)
                     ?.map((e) => e as String).toList() ?? [],
    createdAt:     DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  // Price in UZS (tiyin / 100)
  double get priceUzs => priceTiyin / 100;
  double? get oldPriceUzs => oldPriceTiyin != null ? oldPriceTiyin! / 100 : null;
  bool get hasDiscount => oldPriceTiyin != null && oldPriceTiyin! > priceTiyin;
  int get discountPercent => hasDiscount
      ? ((oldPriceTiyin! - priceTiyin) / oldPriceTiyin! * 100).round()
      : 0;

  @override
  List<Object?> get props => [id, priceTiyin, status];
}
