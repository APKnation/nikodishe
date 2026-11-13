import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Bottom navigation index
// ---------------------------------------------------------------------------
/// Tracks the currently selected tab in the bottom navigation bar.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Theme mode
// ---------------------------------------------------------------------------
/// Controls the app-wide theme mode (light / dark).
/// Defaults to [ThemeMode.light]; can be toggled for future dark-mode support.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
