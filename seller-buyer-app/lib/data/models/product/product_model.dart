import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductPhotoModel {
  final String id;
  final String url;
  final int order;
  final bool isMain;
  const ProductPhotoModel({
    required this.id, required this.url, required this.order, required this.isMain,
  });
  factory ProductPhotoModel.fromJson(Map<String, dynamic> json) =>
    _$ProductPhotoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductPhotoModelToJson(this);
}

@JsonSerializable()
class ProductVariantModel {
  final String id;
  final String? size;
  final String? color;
  final int stock;
  final int priceDiffTiyin;
  const ProductVariantModel({
    required this.id, this.size, this.color, required this.stock, required this.priceDiffTiyin,
  });
  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
    _$ProductVariantModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantModelToJson(this);
}

@JsonSerializable()
class ProductModel extends Equatable {
  final String id;
  final String sellerId;
  final String? categoryId;
  final String title;
  final String? description;
  final int priceTiyin;
  final int? oldPriceTiyin;
  final int stock;
  final String status;     // draft|active|out_of_stock|pending|rejected
  final String condition;  // new|used
  final List<String>? tags;
  final int viewCount;
  final double avgRating;
  final int reviewCount;
  final bool isBoosted;
  final List<ProductPhotoModel> photos;
  final List<ProductVariantModel> variants;
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
    required this.condition,
    this.tags,
    this.viewCount = 0,
    this.avgRating = 0,
    this.reviewCount = 0,
    this.isBoosted = false,
    this.photos = const [],
    this.variants = const [],
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
    _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // Helpers
  int get priceSum => priceTiyin ~/ 100;
  int? get oldPriceSum => oldPriceTiyin != null ? oldPriceTiyin! ~/ 100 : null;
  String? get mainPhotoUrl => photos.isNotEmpty
    ? photos.firstWhere((p) => p.isMain, orElse: () => photos.first).url
    : null;
  int? get discountPercent {
    if (oldPriceTiyin == null || oldPriceTiyin! <= priceTiyin) return null;
    return (((oldPriceTiyin! - priceTiyin) / oldPriceTiyin!) * 100).round();
  }
  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, title, priceTiyin, status];
}
