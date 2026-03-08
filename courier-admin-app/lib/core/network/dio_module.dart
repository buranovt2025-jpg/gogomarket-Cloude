import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class DioModule {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) {
        try {
          final box   = Hive.box(AppConstants.tokenBox);
          final token = box.get(AppConstants.accessTokenKey);
          if (token != null) opts.headers['Authorization'] = 'Bearer $token';
        } catch (_) {}
        handler.next(opts);
      },
    ));

    return dio;
  }
}
