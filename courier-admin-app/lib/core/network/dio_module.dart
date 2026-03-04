import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

@module
abstract class DioModule {
  @singleton
  Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (opts, handler) {
          final box   = Hive.box(AppConstants.tokenBox);
          final token = box.get(AppConstants.accessTokenKey);
          if (token != null) opts.headers['Authorization'] = 'Bearer \$token';
          handler.next(opts);
        },
      ),
      PrettyDioLogger(requestBody: true, responseBody: true, compact: true),
    ]);
    return dio;
  }
}
