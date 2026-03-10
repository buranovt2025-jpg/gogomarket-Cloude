part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

class AuthCheckEvent      extends AuthEvent {}
class AuthLogoutEvent     extends AuthEvent {}

class AuthSendOtpEvent extends AuthEvent {
  final String phone;
  const AuthSendOtpEvent(this.phone);
  @override List<Object?> get props => [phone];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String phone, code;
  final String? role, name;
  const AuthVerifyOtpEvent({required this.phone, required this.code, this.role, this.name});
  @override List<Object?> get props => [phone, code, role];
}

class AuthUpdateUserEvent extends AuthEvent {
  final UserModel user;
  const AuthUpdateUserEvent(this.user);
  @override List<Object?> get props => [user];
}

class AuthUpgradeTierEvent extends AuthEvent {
  final int tier;
  final String? shopName;
  const AuthUpgradeTierEvent({required this.tier, this.shopName});
  @override List<Object?> get props => [tier, shopName];
}
