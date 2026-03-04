import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GogoBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final double fontSize;

  const GogoBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.fontSize = 11,
  });

  // Order status badge factory
  factory GogoBadge.orderStatus(String status) {
    final (label, color) = switch (status) {
      'new'       => ('Новый', AppColors.blue),
      'confirmed' => ('Подтверждён', AppColors.blue),
      'packed'    => ('Упакован', AppColors.accent2),
      'delivery'  => ('В пути', AppColors.accent2),
      'delivered' => ('Доставлен', AppColors.green),
      'done'      => ('Завершён', AppColors.green),
      'cancelled' => ('Отменён', AppColors.textMuted),
      'dispute'   => ('Спор', AppColors.gold),
      _           => (status, AppColors.textMuted),
    };
    return GogoBadge(text: label, color: color);
  }

  factory GogoBadge.plan(String plan) {
    final (label, color) = switch (plan) {
      'start'    => ('Старт 🚀',  AppColors.blue),
      'business' => ('Бизнес 💼', AppColors.accent),
      'shop'     => ('Магазин 🏬', AppColors.gold),
      _          => ('Базовый',   AppColors.textMuted),
    };
    return GogoBadge(text: label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color ?? AppColors.accent).withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? (color ?? AppColors.accent),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
