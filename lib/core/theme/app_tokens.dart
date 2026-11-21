import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color primary = Color(0xFF2E3A83);
  static const Color primaryDisabled = Color(0xFFABB0CD);
  static const Color secondary = Color(0xFF58619C);
  static const Color error = Color(0xFFDF1C41);
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color hint = Color(0xFF818898);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkElevated = Color(0xFF2C2C2C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color gradientStart = Color(0xFF2E3A83);
  static const Color gradientEnd = Color(0xFF58619C);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}
