import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._internal();

  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() => _instance;

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  bool get isLightMode => themeMode.value == ThemeMode.light;

  void toggleBrightness(bool useLightMode) {
    themeMode.value = useLightMode ? ThemeMode.light : ThemeMode.dark;
  }
}
