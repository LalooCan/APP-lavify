import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._internal();

  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() => _instance;

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  bool get isLightMode => themeMode.value == ThemeMode.light;

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void toggleBrightness(bool useLightMode) {
    themeMode.value = useLightMode ? ThemeMode.light : ThemeMode.dark;
  }
}
