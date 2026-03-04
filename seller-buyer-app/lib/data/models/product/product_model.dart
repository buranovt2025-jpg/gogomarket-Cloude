import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel extends Equatable {
  final String  id;
  final String  sellerId;
  final String? sellerName;
  final String? sellerAvatarUrl;
  final String  title;
  final String? description;
  final int     priceTiyin;
  final int?    originalPriceTiyin;
  final int?    stock;
  final String  status;    // active | draft | archived
  final String? category;
  final bool    isBoosted;
  final double? avgRating;
  final int     reviewCount;
  final int     soldCount;
  final List<ProductPhoto> photos;
  final List<ProductVariant> variants;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    this.sellerName, this.sellerAvatarUrl,
    required this.title,
    this.description,
    required this.priceTiyin,
    this.originalPriceTiyin,
    this.stock,
    required this.status,
    this.category,
    this.isBoosted = false,
    this.avgRating,
    this.reviewCount = 0,
    this.soldCount   = 0,
    this.photos      = const [],
    this.variants    = const [],
    required this.createdAt,
  });

  int? get discountPercent {
    if (originalPriceTiyin == null || originalPriceTiyin! <= priceTiyin) return null;
    return ((originalPriceTiyin! - priceTiyin) / originalPriceTiyin! * 100).round();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  List<Object?> get props => [id, priceTiyin, status];
}

@JsonSerializable()
class ProductPhoto extends Equatable {
  final String id;
  final String url;
  final bool   isPrimary;
  const ProductPhoto({required this.id, required this.url, this.isPrimary = false});
  factory ProductPhoto.fromJson(Map<String, dynamic> json) => _$ProductPhotoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductPhotoToJson(this);
  @override List<Object?> get props => [id];
}

@JsonSerializable()
class ProductVariant extends Equatable {
  final String  id;
  final String  name;
  final String  value;
  final int?    priceDeltaTiyin;
  final int?    stock;
  const ProductVariant({required this.id, required this.name, required this.value, this.priceDeltaTiyin, this.stock});
  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);
  @override List<Object?> get props => [id];
}
