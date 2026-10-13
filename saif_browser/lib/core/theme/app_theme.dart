import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Theme extension with browser chrome colors that Material does not model.
@immutable
class BrowserPalette extends ThemeExtension<BrowserPalette> {
  const BrowserPalette({
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.textSecondary,
    required this.danger,
  });

  final Color accent;
  final Color onAccent;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color textSecondary;
  final Color danger;

  @override
  BrowserPalette copyWith({
    Color? accent,
    Color? onAccent,
    Color? surface,
    Color? surfaceStrong,
    Color? border,
    Color? textSecondary,
    Color? danger,
  }) {
    return BrowserPalette(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      danger: danger ?? this.danger,
    );
  }

  @override
  BrowserPalette lerp(BrowserPalette? other, double t) {
    if (other == null) return this;
    return BrowserPalette(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension BrowserPaletteX on BuildContext {
  BrowserPalette get palette => Theme.of(this).extension<BrowserPalette>()!;
}

abstract final class AppTheme {
  static ThemeData light({Color accent = AppColors.accent}) => _build(
    brightness: Brightness.light,
    accent: accent,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceStrong: AppColors.surfaceStrong,
    border: AppColors.border,
    text: AppColors.text,
    textSecondary: AppColors.textSecondary,
  );

  static ThemeData dark({Color accent = AppColors.accent}) => _build(
    brightness: Brightness.dark,
    accent: accent,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceStrong: AppColors.darkSurfaceStrong,
    border: AppColors.darkBorder,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color background,
    required Color surface,
    required Color surfaceStrong,
    required Color border,
    required Color text,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? accent : AppColors.text,
      onPrimary: isDark ? AppColors.onAccent : AppColors.background,
      primaryContainer: accent,
      onPrimaryContainer: AppColors.onAccent,
      secondary: accent,
      onSecondary: AppColors.onAccent,
      secondaryContainer: accent,
      onSecondaryContainer: AppColors.onAccent,
      tertiary: accent,
      onTertiary: AppColors.onAccent,
      error: AppColors.danger,
      onError: Colors.white,
      surface: background,
      onSurface: text,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceStrong,
      surfaceContainerHighest: surfaceStrong,
      outline: border,
      outlineVariant: border,
      inverseSurface: text,
      onInverseSurface: background,
      shadow: Colors.black,
      scrim: Colors.black,
    );
    final radius = BorderRadius.circular(14);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      extensions: [
        BrowserPalette(
          accent: accent,
          onAccent: AppColors.onAccent,
          surface: surface,
          surfaceStrong: surfaceStrong,
          border: border,
          textSecondary: textSecondary,
          danger: AppColors.danger,
        ),
      ],
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      iconTheme: IconThemeData(color: text, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: background)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: background),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          iconColor: AppColors.onAccent,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(48, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: AppColors.onAccent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: text, width: 1.4),
        ),
        hintStyle: TextStyle(color: textSecondary),
        labelStyle: TextStyle(color: textSecondary),
        floatingLabelStyle: TextStyle(color: text),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.onAccent : textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : surfaceStrong,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : border,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onAccent),
        side: BorderSide(color: textSecondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? text : textSecondary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: text,
        inactiveTrackColor: surfaceStrong,
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.25),
        valueIndicatorColor: text,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? accent : AppColors.text,
        linearTrackColor: surfaceStrong,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: text,
        textColor: text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minVerticalPadding: 10,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceStrong : const Color(0xFF17181A),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14.5),
        actionTextColor: accent,
        elevation: 8,
        insetPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent,
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: text),
        secondaryLabelStyle: const TextStyle(color: AppColors.onAccent),
        checkmarkColor: AppColors.onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? accent : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? AppColors.onAccent : text,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
      ),
    );
  }
}
