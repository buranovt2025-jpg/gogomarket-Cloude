import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';


import '../../../core/constants/app_constants.dart';


class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_load());

  static ThemeMode _load() {
    final box = Hive.box(AppConstants.settingsBox);
    final v   = box.get(AppConstants.themeKey, defaultValue: 'dark') as String;
    return v == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box  = Hive.box(AppConstants.settingsBox);
    box.put(AppConstants.themeKey, next == ThemeMode.dark ? 'dark' : 'light');
    emit(next);
  }
}
