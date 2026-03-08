import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);
  void toggle() => emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  @override ThemeMode fromJson(Map<String, dynamic> json) =>
    ThemeMode.values.firstWhere((e) => e.name == (json['theme'] ?? 'dark'), orElse: () => ThemeMode.dark);
  @override Map<String, dynamic>? toJson(ThemeMode s) => {'theme': s.name};
}
