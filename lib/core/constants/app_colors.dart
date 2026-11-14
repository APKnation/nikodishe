import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// KODISHA COLOR SYSTEM (Orange, White, Amber)
/// ─────────────────────────────────────────────────────────────────────────────
/// • Orange: brand, structure, primary actions, trust
/// • White: surfaces, canvas, clarity, breathing space
/// • Amber: secondary accent, highlights, emphasis, attention cues
/// All UI colors are derived from these warm hues (including states/tints).
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // ─── Core palette ───────────────────────────────────────────────────────────
  static const Color orange = Color(0xFFF97316); // Primary brand orange
  static const Color orangeDark = Color(0xFFC2410C); // Deep structural orange
  static const Color orangeSoft = Color(0xFFEA580C); // Interactive/hover orange
  static const Color orangeTint = Color(0xFFFFEDD5); // Light orange tint
  static const Color orangeTintSoft = Color(
    0xFFFFF7ED,
  ); // Very soft orange background

  static const Color white = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFFFFBF5); // White with a subtle warm cast
  static const Color surfaceSubtle = Color(
    0xFFFFF5EC,
  ); // Subtle input/pill surface

  static const Color amber = Color(0xFFF59E0B); // Secondary warm accent
  static const Color amberDark = Color(0xFFD97706); // Strong amber emphasis
  static const Color amberTint = Color(0xFFFEF3C7); // Soft amber highlight

  // ─── Semantic aliases (used across app) ─────────────────────────────────────
  static const Color background = canvas; // 70% dominant neutral
  static const Color surface = white; // Cards/surfaces
  static const Color border = Color(0xFFFFE0C7); // Soft warm border (tint)

  static const Color textPrimary = Color(0xFF7C2D12); // High-contrast headings
  static const Color textSecondary = Color(
    0xFF9A3412,
  ); // Readable body (warm tone)
  static const Color textTertiary = Color(0xFFB45309); // Hints/captions
  static const Color brandDark = orangeDark;

  static const Color primary = orange; // Primary CTA
  static const Color secondary = amber; // Accent/secondary emphasis
  static const Color primaryLight = orangeTint; // Selected/badge tint
  static const Color primaryDark = Color(0xFFC2410C); // Pressed state

  // ─── Feedback states ────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626); // Clear destructive feedback
  static const Color errorLight = Color(0xFFFEE2E2); // Soft error background
  static const Color success = Color(0xFF15803D); // Confirmation
  static const Color successLight = Color(0xFFDCFCE7); // Confirmation background
  static const Color warning = amber; // Warning/highlight
  static const Color warningLight = amberTint; // Warning background
}
