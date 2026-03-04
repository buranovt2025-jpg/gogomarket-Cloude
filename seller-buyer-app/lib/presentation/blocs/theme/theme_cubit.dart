import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  void setTheme(ThemeMode mode) => emit(mode);
  void toggle() => emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  ThemeMode fromJson(Map<String, dynamic> json) =>
    ThemeMode.values.firstWhere(
      (e) => e.name == (json['theme'] as String? ?? 'dark'),
      orElse: () => ThemeMode.dark,
    );

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'theme': state.name};
}
