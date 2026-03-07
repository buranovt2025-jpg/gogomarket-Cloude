import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/user/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _api;

  AuthBloc(this._api) : super(AuthInitial()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthUpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onCheck(AuthCheckEvent e, Emitter<AuthState> emit) async {
    final box   = Hive.box(AppConstants.tokenBox);
    final token = box.get(AppConstants.accessTokenKey);
    if (token == null) { emit(AuthUnauthenticated()); return; }
    try {
      final user = await _api.getMe();
      emit(AuthAuthenticated(user: user));
    } catch (_) {
      await box.deleteAll([AppConstants.accessTokenKey, AppConstants.refreshTokenKey]);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(AuthSendOtpEvent e, Emitter<AuthState> emit) async {
    emit(AuthOtpSending());
    try {
      await _api.sendOtp(e.phone);
      emit(AuthOtpSent(phone: e.phone));
    } catch (err) {
      emit(AuthError(message: _parseError(err)));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpEvent e, Emitter<AuthState> emit) async {
    emit(AuthVerifying());
    try {
      final res = await _api.verifyOtp(
        phone: e.phone, code: e.code,
        role: e.role, name: e.name,
      );
      final box = Hive.box(AppConstants.tokenBox);
      await box.put(AppConstants.accessTokenKey,  res['accessToken']);
      await box.put(AppConstants.refreshTokenKey, res['refreshToken']);

      final userBox = Hive.box(AppConstants.userBox);
      await userBox.put(AppConstants.userKey, res['user']);

      final user = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      // Connect socket on login
      final accessToken = res['accessToken'] as String;
      SocketService.instance.connect(accessToken);
      emit(AuthAuthenticated(user: user));
    } catch (err) {
      emit(AuthError(message: _parseError(err)));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent e, Emitter<AuthState> emit) async {
    final tokenBox = Hive.box(AppConstants.tokenBox);
    final userBox  = Hive.box(AppConstants.userBox);
    SocketService.instance.disconnect();
    await tokenBox.clear();
    await userBox.clear();
    emit(AuthUnauthenticated());
  }

  void _onUpdateUser(AuthUpdateUserEvent e, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(user: e.user));
    }
  }

  String _parseError(dynamic err) {
    try {
      final msg = err.toString();
      if (msg.contains('Invalid or expired OTP')) return 'Неверный код';
      if (msg.contains('Too many')) return 'Слишком много попыток, подождите';
      if (msg.contains('SocketException')) return 'Нет подключения к интернету';
      return 'Ошибка. Попробуйте ещё раз';
    } catch (_) { return 'Неизвестная ошибка'; }
  }
}
