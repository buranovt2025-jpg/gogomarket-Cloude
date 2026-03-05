import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';

@singleton
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl:        AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody:  false,
        responseBody: false,
        error:        true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final box   = Hive.box(AppConstants.tokenBox);
    final token = box.get(AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try refresh
      try {
        final box          = Hive.box(AppConstants.tokenBox);
        final refreshToken = box.get(AppConstants.refreshTokenKey);
        if (refreshToken != null) {
          final res = await Dio().post(
            '\${AppConstants.baseUrl}/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          final newToken = res.data['accessToken'] as String;
          await box.put(AppConstants.accessTokenKey, newToken);
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer \$newToken';
          final retryRes = await Dio().fetch(err.requestOptions);
          return handler.resolve(retryRes);
        }
      } catch (_) {}
      // Clear tokens
      final box = Hive.box(AppConstants.tokenBox);
      await box.deleteAll([AppConstants.accessTokenKey, AppConstants.refreshTokenKey]);
    }
    handler.next(err);
  }
}
