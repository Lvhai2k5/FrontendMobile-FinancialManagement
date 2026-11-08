import 'package:flutter/material.dart';

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

  /// Theo các màn `screen0`…`screen8`, nút CTA/chip chọn/nav đang chọn đều
  /// dùng nâu đỏ đậm (cùng tông `primary`) chứ không phải san hô nhạt.
  static const Color primaryContainer = Color(0xFF95473B);
  static const Color primaryDark = Color(0xFF7A3329);
  static const Color secondary = Color(0xFF55615B);
  static const Color secondaryContainer = Color(0xFFD8E6DD);

  static const Color pastelPeach = Color(0xFFF8A99B);
  static const Color pastelBlush = Color(0xFFFBD1C6);
  static const Color pastelLavender = Color(0xFFE8E2F5);
  static const Color pastelSage = Color(0xFFE1EBE5);

  /// Nút CTA "hero" riêng cho màn hình Welcome (đậm hơn `primaryContainer`
  /// theo đúng override thật trong `code.html` của màn đó).
  static const Color ctaPrimary = Color(0xFF95473B);
  static const Color ctaSecondaryBorder = Color(0xFFF3D7D0);
}

/// Một họ chữ có đầy đủ dấu tiếng Việt, đóng gói cùng app để dùng cả offline.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'BeVietnamPro';

  /// Chữ hiệu thương hiệu riêng cho hero Welcome (kích thước literal 30px
  /// theo `text-3xl` trong `code.html`, không thuộc thang typography chuẩn).
  static TextStyle get brandTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.3,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 34 / 26,
        letterSpacing: -0.26,
        color: AppColors.onSurface,
      );

  /// Tiêu đề các tab chính.
  static TextStyle get pageTitle =>
      brandTitle.copyWith(fontSize: 24, height: 1.4);

  static TextStyle get headlineSm => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
      );

  static TextStyle get titleSm => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
      );

  static TextStyle get amountMd => titleSm.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get bodyMd => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
      );

  static TextStyle get bodySm => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        letterSpacing: 0.12,
      );

  static TextStyle get labelMd => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.26,
      );

  static TextStyle get labelSm => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 16 / 11,
        letterSpacing: 0.44,
      );
}

/// Kiểu chữ riêng cho màn chào và nội dung chính sách trước đăng nhập.
class IntroTypography {
  IntroTypography._();

  static const String fontFamily = AppTypography.fontFamily;

  static final headline = AppTypography.brandTitle.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  static final heading = AppTypography.headlineSm.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static final title = AppTypography.titleSm;

  static final body = AppTypography.bodyMd.copyWith(height: 1.65);

  static final small = AppTypography.bodySm.copyWith(height: 1.6);

  static final label = AppTypography.labelMd.copyWith(height: 1.5);

  static final caption = AppTypography.labelSm.copyWith(
    fontWeight: FontWeight.w400,
    height: 1.6,
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
      fontFamily: AppTypography.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTypography.brandTitle,
        displayMedium: AppTypography.headlineLgMobile,
        displaySmall: AppTypography.pageTitle,
        headlineLarge: AppTypography.headlineLgMobile,
        headlineMedium: AppTypography.pageTitle,
        headlineSmall: AppTypography.headlineSm,
        titleLarge: AppTypography.headlineSm,
        titleMedium: AppTypography.titleSm,
        titleSmall: AppTypography.labelMd,
        bodyLarge: AppTypography.bodyMd,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelMd,
        labelMedium: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle:
            AppTypography.headlineSm.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}
