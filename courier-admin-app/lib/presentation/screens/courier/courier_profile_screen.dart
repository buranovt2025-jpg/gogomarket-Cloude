import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';

class CourierProfileScreen extends StatelessWidget {
  const CourierProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Мой профиль'), backgroundColor: AppColors.bgDark),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Column(children: [
            Container(width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF00C896)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text((user?.name ?? 'К').substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 10),
            Text(user?.name ?? 'Курьер', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            Text(user?.phone ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: const [
              _Badge('✓ Верифицирован', AppColors.green),
              _Badge('⭐ 4.9 рейтинг', AppColors.gold),
              _Badge('1 240 доставок', AppColors.blue),
            ]),
          ])),
          const SizedBox(height: 24),
          const _InfoRow('🏍️', 'Транспорт', 'Мотоцикл'),
          const _InfoRow('📍', 'Зона работы', 'Юнусабад, Мирабад'),
          const _InfoRow('💳', 'Способ выплаты', 'Uzcard ****1234'),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutEvent()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Выйти из аккаунта'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

class _InfoRow extends StatelessWidget {
  final String icon, label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    ]),
  );
}
