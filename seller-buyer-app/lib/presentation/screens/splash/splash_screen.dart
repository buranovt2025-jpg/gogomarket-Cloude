import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  Timer? _fallbackTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _ctrl.forward();

    // Fallback: если AuthBloc завис — навигируем через 3 сек
    _fallbackTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _navigated) return;
      _doNavigate(context.read<AuthBloc>().state);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl.dispose();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _doNavigate(AuthState state) {
    if (_navigated || !mounted) return;
    _navigated = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Небольшая задержка чтобы анимация успела
    final delay = _ctrl.isAnimating ? 400 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (state is AuthAuthenticated) {
        context.go(Routes.feed);
      } else {
        context.go(Routes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _doNavigate(state);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.accent,
        body: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                // Используем белый логотип на прозрачном фоне
                // — никакого прямоугольника не будет
                child: Image.asset(
                  'assets/images/logo_horizontal_light.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
