import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

enum ButtonVariant { primary, outline, ghost, green, gold, red }

class GogoButton extends StatelessWidget {
  final String label;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double? height;

  const GogoButton({
    super.key,
    required this.label,
    this.variant  = ButtonVariant.primary,
    this.onPressed,
    this.icon,
    this.loading  = false,
    this.height,
  });

  Color get _bg => switch (variant) {
    ButtonVariant.primary => AppColors.accent,
    ButtonVariant.green   => AppColors.green,
    ButtonVariant.gold    => AppColors.gold,
    ButtonVariant.red     => AppColors.red,
    _                     => Colors.transparent,
  };

  Color get _fg => switch (variant) {
    ButtonVariant.outline => AppColors.accent,
    ButtonVariant.ghost   => AppColors.textSecondary,
    _                     => Colors.white,
  };

  Border? get _border => switch (variant) {
    ButtonVariant.outline => Border.all(color: AppColors.accent, width: 1.5),
    ButtonVariant.ghost   => Border.all(color: AppColors.border),
    _                     => null,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed != null && !loading ? onPressed : null,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: height ?? 48.h,
          decoration: BoxDecoration(
            color: onPressed == null ? AppColors.bgCard : _bg,
            borderRadius: BorderRadius.circular(14),
            border: _border,
          ),
          child: Center(
            child: loading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _fg))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    Icon(icon, color: _fg, size: 16.sp),
                    SizedBox(width: 6.w),
                  ],
                  Text(label, style: TextStyle(color: _fg, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ]),
          ),
        ),
      ),
    );
  }
}
