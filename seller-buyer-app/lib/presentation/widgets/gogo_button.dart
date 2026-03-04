import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum GogoButtonVariant { primary, outline, ghost, green, gold, red }

class GogoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final GogoButtonVariant variant;
  final bool loading;
  final bool expanded;
  final IconData? icon;
  final double height;

  const GogoButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = GogoButtonVariant.primary,
    this.loading = false,
    this.expanded = true,
    this.icon,
    this.height = 52,
  });

  Color get _bg => switch (variant) {
    GogoButtonVariant.primary => AppColors.accent,
    GogoButtonVariant.green   => AppColors.green,
    GogoButtonVariant.gold    => AppColors.gold,
    GogoButtonVariant.red     => AppColors.red,
    _                         => Colors.transparent,
  };

  Color get _fg => switch (variant) {
    GogoButtonVariant.outline => AppColors.accent,
    GogoButtonVariant.ghost   => AppColors.textSecondary,
    _                         => Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    final child = loading
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: _fg), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: _fg, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'DM Sans')),
          ],
        );

    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: variant == GogoButtonVariant.outline
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _bg,
              foregroundColor: _fg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: child,
          ),
    );
  }
}
