// lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // GSN Branding
  static const Color gsnRed = Color(0xFFF52002); // Rojo Principal
  static const Color gsnBlue = Color(0xFF01A1DF); // Azul Principal
  static const Color gsnDarkBlue = Color(0xFF0B1F38); // Premium dark touch

  // Neutral Colors (Matching GSN style)
  static const Color background = Color(0xFFF4F7FB); // Modern soft background
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500

  // UI Specifics
  static const Color sidebarBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0); // Slate-200

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gsnRed, Color(0xFFD61800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [gsnBlue, Color(0xFF0089C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0B1F38), Color(0xFF01A1DF), Color(0xFF0B1F38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Floating Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF64748B).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: const Color(0xFF64748B).withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];
}
