import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized font definition for the entire app.
/// Font family: Poppins.
class AppFont {
  AppFont._();

  static const String _fontFamily = 'Poppins';

  /// Returns a Poppins [TextStyle].
  static TextStyle style({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle? fontStyle,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static TextStyle get normal =>
      GoogleFonts.poppins(fontWeight: FontWeight.normal);

  static TextStyle get medium =>
      GoogleFonts.poppins(fontWeight: FontWeight.w500);

  static TextStyle get semiBold =>
      GoogleFonts.poppins(fontWeight: FontWeight.w600);

  static TextStyle get bold =>
      GoogleFonts.poppins(fontWeight: FontWeight.bold);

  /// The raw font family string — used in ThemeData.fontFamily.
  static String get family => GoogleFonts.poppins().fontFamily ?? _fontFamily;
}

// ── Size extension (unchanged) ─────────────────────────────────────────────────
extension AppFontSize on TextStyle {
  TextStyle get s12 => copyWith(fontSize: 12.sp);
  TextStyle get s14 => copyWith(fontSize: 14.sp);
  TextStyle get s16 => copyWith(fontSize: 16.sp);
  TextStyle get s17 => copyWith(fontSize: 17.sp);
  TextStyle get s18 => copyWith(fontSize: 18.sp);
  TextStyle get s20 => copyWith(fontSize: 20.sp);
  TextStyle get s22 => copyWith(fontSize: 22.sp);
  TextStyle get s25 => copyWith(fontSize: 25.sp);
  TextStyle get s30 => copyWith(fontSize: 30.sp);
}
