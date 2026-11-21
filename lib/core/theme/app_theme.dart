import 'package:enterprise_mvvm/core/theme/app_gradients.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppGradients.light);

  static ThemeData dark() => _build(Brightness.dark, AppGradients.dark);

  static ThemeData _build(Brightness brightness, AppGradients gradients) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppPalette.primary,
          onPrimary: AppPalette.white,
          secondary: AppPalette.secondary,
          onSecondary: AppPalette.white,
          error: AppPalette.error,
          surface: brightness == Brightness.light
              ? AppPalette.surface
              : AppPalette.darkSurface,
          onSurface: brightness == Brightness.light
              ? AppPalette.onSurface
              : AppPalette.white,
        );
    final radius = BorderRadius.circular(AppRadii.md);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: FontFamily.inter,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? AppPalette.background
          : AppPalette.darkBackground,
      extensions: <ThemeExtension<dynamic>>[gradients],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppPalette.transparent,
        foregroundColor: scheme.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
