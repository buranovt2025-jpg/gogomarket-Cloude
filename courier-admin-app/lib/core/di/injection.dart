import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../network/dio_module.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/courier/courier_bloc.dart';
import '../../presentation/blocs/admin/admin_bloc.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final dio = DioModule.createDio();
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<ApiClient>(ApiClient(dio));

  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<ApiClient>()));
  getIt.registerFactory<CourierBloc>(() => CourierBloc(getIt<ApiClient>()));
  getIt.registerFactory<AdminBloc>(() => AdminBloc(getIt<ApiClient>()));
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
}
