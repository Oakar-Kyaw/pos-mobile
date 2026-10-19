// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // ── Brand Colors ──────────────────────────────
// const kPrimary = Color.fromARGB(255, 35, 145, 248);
// const kSecondary = Color.fromARGB(255, 22, 136, 178);
// // const kPrimary = Color(0xFF6366F1);
// // const kSecondary = Color(0xFF8B5CF6);
// // const kGreen = Color.fromARGB(255, 35, 145, 248);
// // const kGreenSecondary = Color.fromARGB(255, 22, 136, 178);

// const kGreen = Color.fromARGB(255, 4, 179, 121);
// const kGreenSecondary = Color.fromARGB(255, 33, 192, 134);

// const kBlue = Color.fromARGB(255, 35, 145, 248);
// const kBlueSecondary = Color.fromARGB(255, 22, 136, 178);

// const kAmber = Color(0xFFF59E0B);
// const kRed = Color.fromARGB(255, 234, 0, 0);

// // ── Backgrounds ───────────────────────────────
// const kBgDark = Color(0xFF1A1A2E);
// //const kBgLight = Color(0xFFF5F6FA);
// const kBgLight = Color(0xFF1F2937);
// // ── Surfaces ──────────────────────────────────
// const kSurfaceDark = Color(0xFF16213E);
// const kSurfaceLight = Color(0xFFFFFFFF);

// // ── Text ──────────────────────────────────────
// const kTextDark = Color(0xFFFFFFFF);
// const kTextLight = Color(0xFF111827);
// const kTextSubDark = Color(0x80FFFFFF);
// const kTextSubLight = Color(0xFF9CA3AF);

// // ── Notifier ──────────────────────────────────
// class ThemeModeNotifier extends Notifier<ThemeMode> {
//   @override
//   ThemeMode build() => ThemeMode.light;

//   void toggleTheme() {
//     state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//   }

//   void setTheme(ThemeMode themeMode) {
//     state = themeMode;
//   }
// }

// final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
//   ThemeModeNotifier.new,
// );

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Brand Colors (Pure Grey & White/Silver) ───
const kPrimary = Color(0xFF3F3F46); // Dark Grey
const kSecondary = Color(0xFF71717A); // Medium Grey

const kGreen = Color(0xFF16A34A);
const kGreenSecondary = Color(0xFF22C55E);

const kBlue = Color(0xFF3B82F6);
const kBlueSecondary = Color(0xFF06B6D4);

const kAmber = Color(0xFFF59E0B);
const kRed = Color(0xFFEF4444); // debt / unpaid အတွက်ပဲ သုံးမယ်

// ── Backgrounds ───────────────────────────────
const kBgLight = Color(0xFFF4F4F5); // Light Grey Background
const kBgDark = Color(0xFF18181B); // Dark Grey Background

// ── Surfaces ──────────────────────────────────
const kSurfaceLight = Color(0xFFFFFFFF); // အဖြူစစ်စစ် (Pure White)
const kSurfaceDark = Color(0xFF27272A); // Grey Dark Surface

// ── Accents ───────────────────────────────────
const kSilver = Color(0xFFE4E4E7); // Silver border / divider

// ── Gradients ─────────────────────────────────
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF52525B), Color(0xFF27272A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// AppBar အတွက် (မီးခိုးရင့်ကနေ မီးခိုးလတ်)
const kHeaderGradient = LinearGradient(
  colors: [Color(0xFF27272A), Color(0xFF3F3F46)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ခလုတ်၊ chip ထိပ်မှာ ထပ်ခံမယ့် အလင်းတန်း
const kShineGradient = LinearGradient(
  colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ── Shadows ───────────────────────────────────
// Card shadow: မီးခိုးအရိပ်နူးနူး + ထိပ်မှာ အဖြူအလင်း
final kPremiumShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
  BoxShadow(
    color: Colors.white.withOpacity(0.9),
    blurRadius: 6,
    offset: const Offset(0, -2),
  ),
];

// ── Text ──────────────────────────────────────
const kTextDark = Color(0xFFFFFFFF);
const kTextLight = Color(0xFF18181B);
const kTextSubDark = Color(0x99FFFFFF);
const kTextSubLight = Color(0xFF71717A);

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
