import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String role;
  final int tier; // 1=buyer, 2=private_seller, 3=business
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    required this.role,
    this.tier = 1,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:         json['id'] as String,
    phone:      json['phone'] as String,
    name:       json['name'] as String?,
    avatarUrl:  json['avatarUrl'] as String?,
    role:       json['role'] as String? ?? 'buyer',
    tier:       json['tier'] as int? ?? 1,
    isVerified: json['isVerified'] as bool? ?? false,
    createdAt:  DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'phone': phone, 'name': name,
    'avatarUrl': avatarUrl, 'role': role, 'tier': tier,
    'isVerified': isVerified, 'createdAt': createdAt.toIso8601String(),
  };

  UserModel copyWith({int? tier, String? name, String? avatarUrl}) => UserModel(
    id: id, phone: phone, role: role, isVerified: isVerified, createdAt: createdAt,
    name: name ?? this.name,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    tier: tier ?? this.tier,
  );

  bool get isBuyer         => tier == 1;
  bool get isPrivateSeller => tier == 2;
  bool get isBusiness      => tier == 3;
  bool get isSeller        => tier >= 2;
  bool get isAdmin         => role == 'admin' || role == 'superadmin';

  String get tierLabel {
    switch (tier) {
      case 2: return 'Частный продавец';
      case 3: return 'Бизнес';
      default: return 'Покупатель';
    }
  }

  String get tierEmoji {
    switch (tier) {
      case 2: return '🛍️';
      case 3: return '🏪';
      default: return '👤';
    }
  }

  @override
  List<Object?> get props => [id, role, tier, isVerified];
}
