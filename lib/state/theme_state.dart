import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ThemeState {
  final themeMode = signal<ThemeMode>(ThemeMode.light);

  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      //we don't care about system in this app
      return;
    }
    themeMode.value = mode;
  }

  /// Check if dark mode is active
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void dispose() {
    themeMode.dispose();
  }
}
