import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut));
    _anim.forward();
    _navigate();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      if (authState.user.isSeller) {
        context.go(Routes.feed);
      } else {
        context.go(Routes.feed);
      }
      return;
    }

    // Check onboarding
    final prefs = await SharedPreferences.getInstance();
    final done  = prefs.getBool('onboarding_done') ?? false;
    if (mounted) context.go(done ? Routes.phone : Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          // Navigation handled in _navigate()
        },
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                Container(
                  width: 96.w, height: 96.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accent2],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  child: Center(child: Text('G', style: TextStyle(
                    color: Colors.white, fontSize: 48.sp,
                    fontWeight: FontWeight.w700, fontFamily: 'Playfair',
                  ))),
                ),
                SizedBox(height: 20.h),
                Text('GogoMarket', style: TextStyle(
                  fontFamily: 'Playfair', fontSize: 32.sp,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                )),
                SizedBox(height: 6.h),
                Text('Социальная торговля', style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14.sp,
                )),
                SizedBox(height: 48.h),
                SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent.withOpacity(0.6),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
