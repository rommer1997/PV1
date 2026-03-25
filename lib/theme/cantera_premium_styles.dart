import 'package:flutter/material.dart';

class CanteraPremiumColors {
  static const Color background = Color(0xFF131314);
  static const Color surface = Color(0xFF1C1B1C);
  static const Color surfaceHigh = Color(0xFF2A2A2B);
  
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonLime = Color(0xFFCCFF00);
  static const Color premiumGold = Color(0xFFF4CA25);
  static const Color premiumGoldDark = Color(0xFFB8860B);
  
  static const Color textMuted = Color(0xFF849495);
  static const Color text = Color(0xFFE5E2E3);
  
  static Gradient neonGas(Color color, {double opacity = 1.0}) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      color.withValues(alpha: opacity),
      color.withValues(alpha: opacity * 0.6),
    ],
  );

  static BoxDecoration glass({double blur = 20, Color? color}) => BoxDecoration(
    color: (color ?? Colors.white).withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: (color ?? Colors.white).withValues(alpha: 0.1),
      width: 0.5,
    ),
  );
}

class CanteraSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Kinetic Spacing Tokens
  static const double k10 = 40.0;
  static const double k12 = 48.0;
}

class CanteraEffects {
  static List<BoxShadow> neonGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: color.withOpacity(0.1),
      blurRadius: 24,
      spreadRadius: 4,
    ),
  ];
}
