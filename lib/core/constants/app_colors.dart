import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// KODISHA COLOR SYSTEM (3-Color Palette: Blue, White, Amber)
/// ─────────────────────────────────────────────────────────────────────────────
/// • Blue: brand, structure, primary actions, trust
/// • White: surfaces, canvas, clarity, breathing space
/// • Amber: accent, highlights, emphasis, attention cues
///
/// Rangi za surfaces/text zinabadilika kulingana na Light/Dark mode.
/// [AppColors.setDark] huitwa na [MyApp] kila theme inapobadilika.
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static bool _dark = false;
  static bool get isDark => _dark;
  static void setDark(bool value) => _dark = value;

  /// Rangi nyeupe ya maandishi/icon juu ya rangi ya brand — haibadiliki.
  static const Color onColor = Color(0xFFFFFFFF);

  // ─── Core brand palette (hazibadiliki) ─────────────────────────────────────
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blueDark = Color(0xFF1E3A8A);
  static const Color blueSoft = Color(0xFF2563EB);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);

  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondary = amber;
  static Color get primary =>
      _dark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8);

  // ─── Dynamic surfaces ──────────────────────────────────────────────────────
  static Color get white =>
      _dark ? const Color(0xFF131C2E) : const Color(0xFFFFFFFF);
  static Color get canvas =>
      _dark ? const Color(0xFF0B1220) : const Color(0xFFF7FAFF);
  static Color get background => canvas;
  static Color get surface => white;
  static Color get surfaceSubtle =>
      _dark ? const Color(0xFF1A2438) : const Color(0xFFF1F5FF);
  static Color get border =>
      _dark ? const Color(0xFF27354F) : const Color(0xFFD6E4FF);

  // ─── Dynamic tints ─────────────────────────────────────────────────────────
  static Color get blueTint =>
      _dark ? const Color(0xFF1C2B4A) : const Color(0xFFDBEAFE);
  static Color get blueTintSoft =>
      _dark ? const Color(0xFF16223A) : const Color(0xFFEFF6FF);
  static Color get primaryLight => blueTint;
  static Color get amberTint =>
      _dark ? const Color(0xFF3A2E12) : const Color(0xFFFEF3C7);

  // ─── Dynamic typography ────────────────────────────────────────────────────
  static Color get textPrimary =>
      _dark ? const Color(0xFFEAF1FF) : const Color(0xFF1E3A8A);
  static Color get textSecondary =>
      _dark ? const Color(0xFFAFC3E6) : const Color(0xFF3357A6);
  static Color get textTertiary =>
      _dark ? const Color(0xFF7F95B8) : const Color(0xFF6B8CC6);
  static Color get brandDark => textPrimary;

  // ─── Feedback states (derived from 3-color palette) ────────────────────────
  static const Color error = amberDark; // Attention/error emphasis
  static Color get errorLight => amberTint; // Soft attention background
  static const Color success = blue; // Positive/trust confirmation
  static Color get successLight => blueTint; // Positive background
  static const Color warning = amber; // Warning/highlight
  static Color get warningLight => amberTint; // Warning background
}
