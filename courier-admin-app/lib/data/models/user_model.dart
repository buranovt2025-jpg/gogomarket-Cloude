class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String role;
  final String? avatarUrl;

  const UserModel({
    required this.id, required this.phone,
    this.name, required this.role, this.avatarUrl,
  });

  bool get isCourier => role == 'courier';
  bool get isAdmin   => role == 'admin';
  bool get isSeller  => role == 'seller';
  bool get isBuyer   => role == 'buyer';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:        j['id'] as String,
    phone:     j['phone'] as String,
    name:      j['name'] as String?,
    role:      j['role'] as String? ?? 'courier',
    avatarUrl: j['avatarUrl'] as String?,
  );
}
