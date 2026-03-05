part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial        extends AuthState {}
class AuthOtpSending     extends AuthState {}
class AuthVerifying      extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent({required this.phone});
  @override List<Object?> get props => [phone];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});
  @override List<Object?> get props => [user.id];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override List<Object?> get props => [message];
}
