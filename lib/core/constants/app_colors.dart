import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// KODISHA COLOR SYSTEM (3-Color Palette: Blue, White, Amber)
/// ─────────────────────────────────────────────────────────────────────────────
/// • Blue: brand, structure, primary actions, trust
/// • White: surfaces, canvas, clarity, breathing space
/// • Amber: accent, highlights, emphasis, attention cues
/// All UI colors are derived from these three hues (including states/tints).
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // ─── Core palette ───────────────────────────────────────────────────────────
  static const Color blue = Color(0xFF1D4ED8); // Primary brand blue
  static const Color blueDark = Color(0xFF1E3A8A); // Deep structural blue
  static const Color blueSoft = Color(0xFF2563EB); // Interactive/hover blue
  static const Color blueTint = Color(0xFFDBEAFE); // Light blue tint
  static const Color blueTintSoft = Color(
    0xFFEFF6FF,
  ); // Very soft blue background

  static const Color white = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF7FAFF); // White with subtle blue cast
  static const Color surfaceSubtle = Color(
    0xFFF1F5FF,
  ); // Subtle input/pill surface

  static const Color amber = Color(0xFFF59E0B); // Third color accent
  static const Color amberDark = Color(0xFFD97706); // Strong amber emphasis
  static const Color amberTint = Color(0xFFFEF3C7); // Soft amber highlight

  // ─── Semantic aliases (used across app) ─────────────────────────────────────
  static const Color background = canvas; // 70% dominant neutral
  static const Color surface = white; // Cards/surfaces
  static const Color border = Color(0xFFD6E4FF); // Soft blue border (tint)

  static const Color textPrimary = blueDark; // High-contrast headings
  static const Color textSecondary = Color(
    0xFF3357A6,
  ); // Readable body (blue tone)
  static const Color textTertiary = Color(0xFF6B8CC6); // Hints/captions
  static const Color brandDark = blueDark;

  static const Color primary = blue; // Primary CTA
  static const Color secondary = amber; // Accent/secondary emphasis
  static const Color primaryLight = blueTint; // Selected/badge tint
  static const Color primaryDark = Color(0xFF1E40AF); // Pressed state

  // ─── Feedback states (derived from 3-color palette) ─────────────────────────
  static const Color error = amberDark; // Attention/error emphasis
  static const Color errorLight = amberTint; // Soft attention background
  static const Color success = blue; // Positive/trust confirmation
  static const Color successLight = blueTint; // Positive background
  static const Color warning = amber; // Warning/highlight
  static const Color warningLight = amberTint; // Warning background
}
