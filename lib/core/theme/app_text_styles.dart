import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Inter';
  static const TextStyle displayPrice = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36, 
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, 
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal, 
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, 
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
