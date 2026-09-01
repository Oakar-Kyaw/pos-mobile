import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Brand Colors ──────────────────────────────
const kPrimary = Color.fromARGB(255, 35, 145, 248);
const kSecondary = Color.fromARGB(255, 22, 136, 178);
// const kPrimary = Color(0xFF6366F1);
// const kSecondary = Color(0xFF8B5CF6);
const kGreen = Color.fromARGB(255, 35, 145, 248);
const kGreenSecondary = Color.fromARGB(255, 22, 136, 178);
// const kGreen = Color.fromARGB(255, 58, 151, 190);
// const kGreenSecondary = Color.fromARGB(255, 84, 173, 229);
// const kGreen = Color.fromARGB(255, 4, 179, 121);
// const kGreenSecondary = Color.fromARGB(255, 33, 192, 134);
const kAmber = Color(0xFFF59E0B);
const kRed = Color.fromARGB(255, 234, 0, 0);

// ── Backgrounds ───────────────────────────────
const kBgDark = Color(0xFF1A1A2E);
const kBgLight = Color(0xFFF5F6FA);

// ── Surfaces ──────────────────────────────────
const kSurfaceDark = Color(0xFF16213E);
const kSurfaceLight = Color(0xFFFFFFFF);

// ── Text ──────────────────────────────────────
const kTextDark = Color(0xFFFFFFFF);
const kTextLight = Color(0xFF111827);
const kTextSubDark = Color(0x80FFFFFF);
const kTextSubLight = Color(0xFF9CA3AF);

// ── Notifier ──────────────────────────────────
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
