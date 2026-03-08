import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../core/network/api_client.dart';

abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}
class AuthCheckEvent  extends AuthEvent {}
class AuthLoginEvent  extends AuthEvent {
  final String phone; final String code;
  AuthLoginEvent({required this.phone, required this.code});
  @override List<Object?> get props => [phone, code];
}
class AuthLogoutEvent extends AuthEvent {}

abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}
class AuthInitial        extends AuthState {}
class AuthLoading        extends AuthState {}
class AuthAuthenticated  extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message; AuthError(this.message);
  @override List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _api;
  AuthBloc(this._api) : super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final box = Hive.box(AppConstants.tokenBox);
      if (box.get(AppConstants.accessTokenKey) == null) return emit(AuthUnauthenticated());
      final user = await _api.getMe();
      emit(AuthAuthenticated(user));
    } catch (_) { emit(AuthUnauthenticated()); }
  }

  Future<void> _onLogin(AuthLoginEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res  = await _api.verifyOtp({'phone': e.phone, 'code': e.code});
      final box  = Hive.box(AppConstants.tokenBox);
      await box.put(AppConstants.accessTokenKey,  res['accessToken']);
      await box.put(AppConstants.refreshTokenKey, res['refreshToken']);
      final user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
      emit(AuthAuthenticated(user));
    } catch (err) { emit(AuthError(err.toString())); }
  }

  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    final box = Hive.box(AppConstants.tokenBox);
    await box.deleteAll([AppConstants.accessTokenKey, AppConstants.refreshTokenKey]);
    emit(AuthUnauthenticated());
  }
}
