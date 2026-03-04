import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../blocs/admin/admin_bloc.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadUsers()),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Пользователи'), backgroundColor: AppColors.bgDark,
          actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})]),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (_, state) {
            final d = state.usersData;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  Expanded(child: _StatBox('Покупатели', '${d['buyers'] ?? '—'}', AppColors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox('Продавцы', '${d['sellers'] ?? '—'}', AppColors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox('Курьеры', '${d['couriers'] ?? '—'}', AppColors.orange)),
                ]),
                const SizedBox(height: 20),
                const Text('ПОСЛЕДНИЕ РЕГИСТРАЦИИ', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ..._mockUsers.map(_UserRow.new),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _mockUsers = [
    {'name': 'Камола Юсупова',  'phone': '+998901234567', 'role': 'buyer',  'dt': 'Сегодня 10:22'},
    {'name': 'Малика Расулова',  'phone': '+998909876543', 'role': 'seller', 'dt': 'Сегодня 09:15'},
    {'name': 'Санжар Каримов',  'phone': '+998917654321', 'role': 'courier', 'dt': 'Вчера 18:44'},
    {'name': 'Дилноза Алимова', 'phone': '+998991122334', 'role': 'buyer',  'dt': 'Вчера 14:30'},
  ];
}

class _StatBox extends StatelessWidget {
  final String label, value; final Color color;
  const _StatBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}

class _UserRow extends StatelessWidget {
  final Map<String, String> u;
  const _UserRow(this.u);
  Color get _roleColor => switch (u['role']) {
    'seller' => AppColors.green, 'courier' => AppColors.orange, _ => AppColors.blue,
  };
  String get _roleLabel => switch (u['role']) {
    'seller' => 'Продавец', 'courier' => 'Курьер', _ => 'Покупатель',
  };
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.bgSurface, shape: BoxShape.circle),
        child: Center(child: Text(u['name']![0], style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(u['name']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(u['phone']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(_roleLabel, style: TextStyle(color: _roleColor, fontSize: 10, fontWeight: FontWeight.w600))),
        const SizedBox(height: 2),
        Text(u['dt']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ]),
  );
}
