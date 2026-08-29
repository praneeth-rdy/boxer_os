import 'package:flutter/material.dart';

/// Every colour, spacing, radius and text style in Boxer OS.
class AppTheme {
  AppTheme._();

  static const String appVersion = '0.1.0';

  static const Color ink = Color(0xFF0A0A0B);
  static const Color surface = Color(0xFF141416);
  static const Color surfaceRaised = Color(0xFF1C1C1F);
  static const Color line = Color(0xFF2A2A2E);
  static const Color chalk = Color(0xFFF4F2EE);
  static const Color chalkMuted = Color(0xFF9A9A9F);
  static const Color chalkFaint = Color(0xFF5C5C62);
  static const Color accent = Color(0xFFFF3D2E);
  static const Color accentDeep = Color(0xFFB8261C);
  static const Color rest = Color(0xFF2ED3A5);
  static const Color warning = Color(0xFFFFB020);
  static const Color onAccent = Color(0xFF0A0A0B);

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 22;
  static const double radiusPill = 999;

  static const double minTapTarget = 48;
  static const double sessionTapTarget = 72;
  static const double hairline = 1;

  static const String _displayFamily = 'BebasNeue';
  static const String _textFamily = 'Inter';

  static const TextStyle displayHero = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 168,
    height: 0.9,
    color: chalk,
  );
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 64,
    height: 0.9,
    letterSpacing: 1,
    color: chalk,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 40,
    height: 0.9,
    letterSpacing: 1,
    color: chalk,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 28,
    height: 0.9,
    letterSpacing: 1,
    color: chalk,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _textFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: chalk,
  );
  static const TextStyle title = TextStyle(
    fontFamily: _textFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: chalk,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _textFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: chalk,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _textFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: chalk,
  );
  static const TextStyle bodyMuted = TextStyle(
    fontFamily: _textFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: chalkMuted,
  );

  /// Uppercase eyebrow, as in "ROUND 3 OF 6".
  static const TextStyle label = TextStyle(
    fontFamily: _textFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: chalkMuted,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _textFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: chalkMuted,
  );

  static const double _navBarHeight = 72;
  static const double _navIndicatorAlpha = 0.18;
  static const double _chipSelectedAlpha = 0.18;

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ink,
    fontFamily: _textFamily,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      onPrimary: onAccent,
      secondary: rest,
      onSecondary: onAccent,
      surface: surface,
      onSurface: chalk,
      outline: line,
      error: accent,
      onError: onAccent,
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: displaySmall,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceRaised,
      indicatorColor: accent.withValues(alpha: _navIndicatorAlpha),
      height: _navBarHeight,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? accent : chalkMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? label.copyWith(color: chalk)
            : label,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: accent.withValues(alpha: _chipSelectedAlpha),
      labelStyle: label,
      secondaryLabelStyle: label.copyWith(color: chalk),
      side: const BorderSide(color: line, width: hairline),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusPill)),
      ),
      showCheckmark: false,
    ),
    dividerTheme: const DividerThemeData(color: line, thickness: hairline),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        minimumSize: const Size(0, minTapTarget),
        textStyle: bodyStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusPill)),
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? onAccent : chalkMuted,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: line, width: hairline),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusPill)),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(bodyStrong),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: spaceXs),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, minTapTarget)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(chalk),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? accent : line,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surface,
      hintStyle: bodyMuted.copyWith(color: chalkFaint),
      contentPadding: const EdgeInsets.all(spaceMd),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        borderSide: BorderSide.none,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surfaceRaised,
      contentTextStyle: body,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
