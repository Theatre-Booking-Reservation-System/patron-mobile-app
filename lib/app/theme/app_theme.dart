import 'package:flutter/material.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';

@immutable
class SeatStatusTheme extends ThemeExtension<SeatStatusTheme> {
  const SeatStatusTheme({
    required this.available,
    required this.selected,
    required this.booked,
    required this.held,
    required this.unavailable,
  });

  final Color available;
  final Color selected;
  final Color booked;
  final Color held;
  final Color unavailable;

  @override
  SeatStatusTheme copyWith({
    Color? available,
    Color? selected,
    Color? booked,
    Color? held,
    Color? unavailable,
  }) => SeatStatusTheme(
    available: available ?? this.available,
    selected: selected ?? this.selected,
    booked: booked ?? this.booked,
    held: held ?? this.held,
    unavailable: unavailable ?? this.unavailable,
  );

  @override
  SeatStatusTheme lerp(SeatStatusTheme? other, double t) {
    if (other == null) return this;
    return SeatStatusTheme(
      available: Color.lerp(available, other.available, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      booked: Color.lerp(booked, other.booked, t)!,
      held: Color.lerp(held, other.held, t)!,
      unavailable: Color.lerp(unavailable, other.unavailable, t)!,
    );
  }
}

abstract final class AppTheme {
  static const gold = Color(0xFFD9A62E);
  static const ivory = Color(0xFFFFFBF5);

  static Color seedFor(AppPalette palette) => switch (palette) {
    AppPalette.burgundy => const Color(0xFF6B0D12),
    AppPalette.midnight => const Color(0xFF162447),
    AppPalette.emerald => const Color(0xFF145A4A),
  };

  static ThemeData build(AppPalette palette, Brightness brightness) {
    final seed = seedFor(palette);
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: seed,
      secondary: gold,
      surface: dark ? const Color(0xFF171312) : ivory,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: seed,
      ),
      cardTheme: CardThemeData(
        elevation: dark ? 0 : 2,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: gold.withValues(alpha: .18),
      ),
      extensions: const [
        SeatStatusTheme(
          available: Color(0xFF7BC391),
          selected: Color(0xFFD9A62E),
          booked: Color(0xFFA8171C),
          held: Color(0xFFDB8B3A),
          unavailable: Color(0xFFB8B8B8),
        ),
      ],
    );
  }
}
