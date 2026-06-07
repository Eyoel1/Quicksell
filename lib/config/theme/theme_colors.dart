import 'package:flutter/material.dart';

/// Resolves the correct color for the current brightness in one call.
/// Usage: TC.bg(context), TC.surface(context), etc.
abstract class TC {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static Color bg(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF0D1117)
      : const Color(0xFFF2F5FB);

  static Color surface(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF161B22)
      : Colors.white;

  static Color card(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF1C2333)
      : Colors.white;

  // ── Inputs ─────────────────────────────────────────────────────────────────
  static Color inputFill(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF1C2333)
      : const Color(0xFFEAF1FF);

  // ── Borders ────────────────────────────────────────────────────────────────
  static Color border(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF30363D)
      : const Color(0xFFE4EAF3);

  // ── Text ───────────────────────────────────────────────────────────────────
  static Color textPrimary(BuildContext ctx) => _d(ctx)
      ? const Color(0xFFE6EDF3)
      : const Color(0xFF101828);

  static Color textSecondary(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF8B949E)
      : const Color(0xFF667085);

  static Color textHint(BuildContext ctx) => _d(ctx)
      ? const Color(0xFF6E7681)
      : const Color(0xFF9CA3AF);

  // ── Brand (same in both modes) ─────────────────────────────────────────────
  static const Color primary     = Color(0xFF2979FF);
  static const Color primaryDark = Color(0xFF1A5FCC);
  static const Color success     = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error       = Color(0xFFDC2626);
  static const Color errorLight  = Color(0xFFFEE2E2);
  static const Color warning     = Color(0xFFD97706);
  static const Color cardShadow  = Color(0x0A101828);

  static bool _d(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static bool isDark(BuildContext ctx) => _d(ctx);
}
