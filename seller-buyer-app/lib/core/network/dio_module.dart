import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';

class DioModule {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }
}
