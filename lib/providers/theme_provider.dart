import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark; // Negro por defecto

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);

class AppColors {
  static Color bg(bool isDark) =>
      isDark ? Colors.black : const Color(0xFFFFFFFF);
  static Color surface(bool isDark) =>
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7);
  static Color text(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1C1C1E);
  static Color textMuted(bool isDark) =>
      isDark ? Colors.white38 : const Color(0xFF8E8E93);
  static Color border(bool isDark) =>
      isDark ? Colors.white10 : const Color(0xFFE5E5EA);
  static Color accent = const Color(0xFF007AFF); // Azul cobalto fijo
  static Color buttonFg(bool isDark) => isDark ? Colors.black : Colors.white;
  static Color buttonBg(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1C1C1E);
}
