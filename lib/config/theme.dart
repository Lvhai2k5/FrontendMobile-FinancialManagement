import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bảng màu "Pastel Family Finance" — theo `colors:` trong `DESIGN.md` của
/// bản thiết kế Stitch (dùng chung cho mọi màn hình để đồng bộ toàn app).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFFF8F5);
  static const Color surface = Color(0xFFFFF8F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFDF1EC);
  static const Color surfaceContainer = Color(0xFFF7ECE7);

  static const Color onSurface = Color(0xFF201B18);
  static const Color onSurfaceVariant = Color(0xFF544340);
  static const Color outline = Color(0xFF87726F);
  static const Color error = Color(0xFFBA1A1A);

  static const Color primary = Color(0xFF95473B);
  static const Color primaryContainer = Color(0xFFE08374);
  static const Color secondary = Color(0xFF55615B);
  static const Color secondaryContainer = Color(0xFFD8E6DD);

  static const Color pastelPeach = Color(0xFFF8A99B);
  static const Color pastelBlush = Color(0xFFFBD1C6);
  static const Color pastelLavender = Color(0xFFE8E2F5);
  static const Color pastelSage = Color(0xFFE1EBE5);

  /// Nút CTA "hero" riêng cho màn hình Welcome (đậm hơn `primaryContainer`
  /// theo đúng override thật trong `code.html` của màn đó).
  static const Color ctaPrimary = Color(0xFFE5897A);
  static const Color ctaSecondaryBorder = Color(0xFFF3D7D0);
}

/// Kiểu chữ theo `typography` trong `DESIGN.md`: Outfit cho headline/số dư,
/// Plus Jakarta Sans cho phần còn lại.
class AppTypography {
  AppTypography._();

  /// Chữ hiệu thương hiệu riêng cho hero Welcome (kích thước literal 30px
  /// theo `text-3xl` trong `code.html`, không thuộc thang typography chuẩn).
  static TextStyle get brandTitle => GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 34 / 26,
        letterSpacing: -0.26,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
      );

  static TextStyle get titleSm => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
      );

  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        letterSpacing: 0.12,
      );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.26,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 16 / 11,
        letterSpacing: 0.44,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
  }
}
