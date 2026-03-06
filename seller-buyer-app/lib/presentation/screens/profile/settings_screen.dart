import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Настройки', style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        _SectionHeader('ИНТЕРФЕЙС'),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (ctx, mode) => _ToggleTile(
            icon: mode == ThemeMode.dark ? '🌙' : '☀️',
            label: mode == ThemeMode.dark ? 'Тёмная тема' : 'Светлая тема',
            value: mode == ThemeMode.dark,
            onChanged: (_) => ctx.read<ThemeCubit>().toggleTheme(),
          ),
        ),
        _SectionHeader('УВЕДОМЛЕНИЯ'),
        _ToggleTile(icon: '📦', label: 'Заказы',          value: true,  onChanged: (_) {}),
        _ToggleTile(icon: '💬', label: 'Сообщения',       value: true,  onChanged: (_) {}),
        _ToggleTile(icon: '🎁', label: 'Акции и скидки',  value: false, onChanged: (_) {}),
        _SectionHeader('АККАУНТ'),
        _NavTile(icon: '🔒', label: 'Изменить номер телефона', onTap: () {}),
        _NavTile(icon: '🌐', label: 'Язык',                    onTap: () {}),
        _NavTile(icon: '📄', label: 'Правила использования',   onTap: () {}),
        _NavTile(icon: '🛡️', label: 'Политика конфиденциальности', onTap: () {}),
        SizedBox(height: 12.h),
        _NavTile(icon: '🗑️', label: 'Удалить аккаунт', onTap: () {}, danger: true),
        SizedBox(height: 4.h),
        Center(child: Text('GogoMarket v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp))),
        SizedBox(height: 40.h),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(4.w, 16.h, 0, 8.h),
    child: Text(text, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
  );
}

class _ToggleTile extends StatefulWidget {
  final String icon, label; final bool value; final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label, required this.value, required this.onChanged});
  @override State<_ToggleTile> createState() => _ToggleTileState();
}
class _ToggleTileState extends State<_ToggleTile> {
  late bool _val;
  @override void initState() { super.initState(); _val = widget.value; }
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: ListTile(
      leading: Text(widget.icon, style: TextStyle(fontSize: 20.sp)),
      title: Text(widget.label, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
      trailing: Switch.adaptive(
        value: _val, onChanged: (v) { setState(() => _val = v); widget.onChanged(v); },
        activeColor: AppColors.accent,
      ),
    ),
  );
}

class _NavTile extends StatelessWidget {
  final String icon, label; final VoidCallback onTap; final bool danger;
  const _NavTile({required this.icon, required this.label, required this.onTap, this.danger = false});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: ListTile(
      onTap: onTap,
      leading: Text(icon, style: TextStyle(fontSize: 20.sp)),
      title: Text(label, style: TextStyle(color: danger ? AppColors.red : AppColors.textPrimary, fontSize: 14.sp)),
      trailing: danger ? null : const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
    ),
  );
}
