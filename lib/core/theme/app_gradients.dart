import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

final class AppGradients extends ThemeExtension<AppGradients> {
  const AppGradients({required this.brand, required this.surface});

  final LinearGradient brand;
  final LinearGradient surface;

  static const AppGradients light = AppGradients(
    brand: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[AppPalette.gradientStart, AppPalette.gradientEnd],
    ),
    surface: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[AppPalette.background, AppPalette.surface],
    ),
  );

  static const AppGradients dark = AppGradients(
    brand: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[AppPalette.secondary, AppPalette.primary],
    ),
    surface: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[AppPalette.darkBackground, AppPalette.darkElevated],
    ),
  );

  @override
  AppGradients copyWith({LinearGradient? brand, LinearGradient? surface}) {
    return AppGradients(
      brand: brand ?? this.brand,
      surface: surface ?? this.surface,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) {
      return this;
    }
    return AppGradients(
      brand: LinearGradient.lerp(brand, other.brand, t) ?? brand,
      surface: LinearGradient.lerp(surface, other.surface, t) ?? surface,
    );
  }
}
