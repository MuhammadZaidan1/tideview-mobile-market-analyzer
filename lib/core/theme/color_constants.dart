import 'package:flutter/material.dart';

class AppColors {
  // --- BACKGROUND & SURFACE COLORS (Light/Dark Adaptive) ---
  static const Color backgroundLight = Color(0xFFF8F9FA); // Soft Greyish White
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212); // Deep Charcoal
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // --- SEMANTIC COLORS (Market Indicators) ---
  static const Color bullish = Color(0xFF00C853); // Emerald Green (Naik)
  static const Color bearish = Color(0xFFFF1744); // Crimson Red (Turun)
  static const Color warning = Color(0xFFFFB300); // Amber (Neutral)

  // --- TEXT COLORS ---
  static const Color textHighEmphasisLight = Color(0xFF111111);
  static const Color textMediumEmphasisLight = Color(0xFF8D8D8D);
  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0xFF8D8D8D);

  // --- TIDE THEMES (DYNAMIC BRAND ACCENT) ---

  // Theme 1: Purple (Default)
  static const Color royalPurplePrimary = Color(0xFF6366F1); // Indigo Neon yang Fresh
  static const Color royalPurpleSecondary = Color(0xFF818CF8);

  // Theme 2: Green 
  static const Color cyberGreenPrimary = Color(0xFF22C55E); 
  static const Color cyberGreenSecondary = Color(0xFF4ADE80);

  // Theme 3: Orange 
  static const Color sunsetOrangePrimary = Color(0xFFF97316);
  static const Color sunsetOrangeSecondary = Color(0xFFFB923C);

  // Theme 4: Cyan
  static const Color electricCyanPrimary = Color(0xFF06B6D4);
  static const Color electricCyanSecondary = Color(0xFF22D3EE);

  // Theme 5: Magenta
  static const Color hotMagentaPrimary = Color(0xFFD946EF);
  static const Color hotMagentaSecondary = Color(0xFFE879F9);
}
