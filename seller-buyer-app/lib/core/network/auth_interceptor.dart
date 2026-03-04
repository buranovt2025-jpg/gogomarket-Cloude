import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
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
      // Attempt token refresh
      try {
        final box          = Hive.box(AppConstants.tokenBox);
        final refreshToken = box.get(AppConstants.refreshTokenKey) as String?;

        if (refreshToken != null) {
          final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
          final res = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
          final newToken = res.data['accessToken'];
          await box.put(AppConstants.accessTokenKey, newToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final cloned = await dio.fetch(err.requestOptions);
          return handler.resolve(cloned);
        }
      } catch (_) {
        // Refresh failed — user must re-login
        final box = Hive.box(AppConstants.tokenBox);
        await box.delete(AppConstants.accessTokenKey);
        await box.delete(AppConstants.refreshTokenKey);
      }
    }

    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        await Future.delayed(const Duration(seconds: 2));
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) =>
    err.type == DioExceptionType.connectionError ||
    err.type == DioExceptionType.receiveTimeout;
}
