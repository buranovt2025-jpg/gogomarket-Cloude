import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

class GogoMarketApp extends StatelessWidget {
  const GogoMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckEvent())),
        BlocProvider(create: (_) => getIt<CartBloc>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp.router(
            title: 'GogoMarket',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
