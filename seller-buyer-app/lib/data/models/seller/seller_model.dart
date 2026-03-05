import 'package:equatable/equatable.dart';

class SellerModel extends Equatable {
  final String  id;
  final String  userId;
  final String  shopName;
  final String? description;
  final String? logoUrl;
  final String? inn;
  final String  plan;
  final bool    isVerified;
  final double  avgRating;
  final int     reviewCount;
  final int     followerCount;
  final DateTime createdAt;

  const SellerModel({
    required this.id, required this.userId, required this.shopName,
    this.description, this.logoUrl, this.inn,
    required this.plan, required this.isVerified,
    required this.avgRating, required this.reviewCount,
    required this.followerCount, required this.createdAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> j) => SellerModel(
    id: j['id'], userId: j['userId'], shopName: j['shopName'],
    description: j['description'], logoUrl: j['logoUrl'], inn: j['inn'],
    plan: j['plan'] ?? 'basic', isVerified: j['isVerified'] ?? false,
    avgRating: (j['avgRating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: j['reviewCount'] ?? 0, followerCount: j['followerCount'] ?? 0,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  bool get isPro => plan != 'basic';
  @override List<Object?> get props => [id, plan, isVerified];
}
