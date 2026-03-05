import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../network/socket_service.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/feed/feed_bloc.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Hive
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(AppConstants.tokenBox),
    Hive.openBox(AppConstants.userBox),
    Hive.openBox(AppConstants.settingsBox),
  ]);

  // Network
  final dioClient = DioClient();
  getIt.registerSingleton<DioClient>(dioClient);
  getIt.registerSingleton<ApiClient>(ApiClient(dioClient.dio));
  getIt.registerSingleton<SocketService>(SocketService());

  // BLoCs / Cubits
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<ApiClient>()));
  getIt.registerFactory<FeedBloc>(() => FeedBloc(getIt<ApiClient>()));
  getIt.registerFactory<CartBloc>(() => CartBloc());
  getIt.registerFactory<ProductBloc>(() => ProductBloc(getIt<ApiClient>()));
}
