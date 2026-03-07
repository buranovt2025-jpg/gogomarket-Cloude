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
  final String?  coverPhoto;
  final DateTime createdAt;
  // Enriched seller fields
  final String? sellerName;
  final String? sellerAvatarUrl;
  final double? sellerRating;
  final List<String> variants;

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
    this.coverPhoto,
    required this.createdAt,
    this.sellerName,
    this.sellerAvatarUrl,
    this.sellerRating,
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Build photoUrls from multiple possible sources
    List<String> photos = [];
    if (json['photos'] is List) {
      photos = (json['photos'] as List).map((p) {
        if (p is String) return p;
        if (p is Map) return (p['url'] ?? '') as String;
        return '';
      }).where((s) => s.isNotEmpty).toList();
    } else if (json['photoUrls'] is List) {
      photos = (json['photoUrls'] as List).cast<String>();
    }
    if (json['coverPhoto'] is String && !photos.contains(json['coverPhoto'])) {
      photos.insert(0, json['coverPhoto'] as String);
    }

    return ProductModel(
      id:             json['id'] as String,
      sellerId:       (json['sellerId'] ?? json['seller_id'] ?? '') as String,
      categoryId:     (json['categoryId'] ?? json['category_id']) as String?,
      title:          json['title'] as String,
      description:    json['description'] as String?,
      priceTiyin:     (json['priceTiyin'] ?? json['price_tiyin'] as num?)?.toInt() ?? 0,
      oldPriceTiyin:  (json['oldPriceTiyin'] ?? json['old_price_tiyin'] as num?)?.toInt(),
      stock:          (json['stock'] as num?)?.toInt() ?? 0,
      status:         json['status'] as String? ?? 'active',
      avgRating:      (json['avgRating'] ?? json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:    (json['reviewCount'] ?? json['review_count'] as num?)?.toInt() ?? 0,
      isBoosted:      json['isBoosted'] as bool? ?? json['is_boosted'] as bool? ?? false,
      viewCount:      (json['viewCount'] ?? json['view_count'] as num?)?.toInt() ?? 0,
      saleCount:      (json['saleCount'] ?? json['sale_count'] as num?)?.toInt() ?? 0,
      photoUrls:      photos,
      coverPhoto:     json['coverPhoto'] as String?,
      createdAt:      DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      sellerName:     (json['sellerName'] ?? json['seller_name']) as String?,
      sellerAvatarUrl:(json['sellerAvatar'] ?? json['sellerAvatarUrl'] ?? json['seller_avatar_url']) as String?,
      sellerRating:   (json['sellerRating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'sellerId': sellerId, 'title': title,
    'priceTiyin': priceTiyin, 'oldPriceTiyin': oldPriceTiyin,
    'stock': stock, 'status': status, 'avgRating': avgRating,
    'reviewCount': reviewCount, 'isBoosted': isBoosted,
    'viewCount': viewCount, 'saleCount': saleCount,
    'photoUrls': photoUrls, 'createdAt': createdAt.toIso8601String(),
    'sellerName': sellerName, 'sellerAvatarUrl': sellerAvatarUrl,
  };

  // Computed
  bool get hasDiscount => oldPriceTiyin != null && oldPriceTiyin! > priceTiyin;
  int  get discountPercent => hasDiscount
      ? ((oldPriceTiyin! - priceTiyin) / oldPriceTiyin! * 100).round() : 0;
  String? get firstPhoto => photoUrls.isNotEmpty ? photoUrls.first : coverPhoto;

  // Backward compat aliases
  int  get soldCount => saleCount;
  int? get originalPriceTiyin => oldPriceTiyin;
  List<String> get photos => photoUrls;
  double get priceUzs => priceTiyin / 100;

  @override
  List<Object?> get props => [id, priceTiyin, status, photoUrls];
}
