import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// UI/UX COLOR SYSTEM (The 70 - 20 - 10 Rule)
/// ─────────────────────────────────────────────────────────────────────────────
/// • 70% DOMINANT / NEUTRALS: Backgrounds, cards, surface, dividers (Clean & Airy)
/// • 20% STRUCTURAL / BRAND: Typography hierarchy, icons, structural elements
/// • 10% ACCENT / CTA: Primary actions, buttons, active highlights, key prices
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // ─── 70% DOMINANT NEUTRALS ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);      // Slate 50 (Soft Canvas)
  static const Color surface = Color(0xFFFFFFFF);         // Pure Card Surface
  static const Color surfaceSubtle = Color(0xFFF1F5F9);   // Slate 100 (Inputs & Pills)
  static const Color border = Color(0xFFE2E8F0);          // Slate 200 (Subtle dividers)

  // ─── 20% STRUCTURAL TYPOGRAPHY & BRAND ELEMENTS ─────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900 (High contrast)
  static const Color textSecondary = Color(0xFF475569);   // Slate 600 (Readable body)
  static const Color textTertiary = Color(0xFF94A3B8);    // Slate 400 (Hints/Captions)
  static const Color brandDark = Color(0xFF134E4A);       // Dark Teal Brand Slate

  // ─── 10% VIBRANT ACCENT (CTAs, Key Badges & Active States) ──────────────────
  static const Color primary = Color(0xFF0D9488);         // Vibrant Teal (Primary CTA)
  static const Color secondary = Color(0xFF14B8A6);       // Secondary Teal Accent
  static const Color primaryLight = Color(0xFFCCFBF1);    // 10% Teal Tint for badges
  static const Color primaryDark = Color(0xFF0F766E);     // Pressed/Hover CTA State

  // ─── STATE ACCENTS (Used strictly for contextual alerts) ────────────────────
  static const Color error = Color(0xFFEF4444);           // Red
  static const Color errorLight = Color(0xFFFEE2E2);      // Red Tint
  static const Color success = Color(0xFF16A34A);         // Green
  static const Color successLight = Color(0xFFDCFCE7);    // Green Tint
  static const Color warning = Color(0xFFD97706);         // Amber
  static const Color warningLight = Color(0xFFFEF3C7);    // Amber Tint
}
