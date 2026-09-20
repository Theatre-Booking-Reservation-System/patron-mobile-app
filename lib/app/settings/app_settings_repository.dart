import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPalette { burgundy, midnight, emerald }

class AppSettings {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.palette,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final AppPalette palette;
}

class AppSettingsRepository {
  AppSettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  AppSettings load() => AppSettings(
    locale: Locale(_preferences.getString('app_locale') ?? 'en'),
    themeMode: ThemeMode.values.firstWhere(
      (value) => value.name == _preferences.getString('app_theme_mode'),
      orElse: () => ThemeMode.light,
    ),
    palette: AppPalette.values.firstWhere(
      (value) => value.name == _preferences.getString('app_palette'),
      orElse: () => AppPalette.burgundy,
    ),
  );

  Future<void> saveLocale(Locale locale) =>
      _preferences.setString('app_locale', locale.languageCode);

  Future<void> saveThemeMode(ThemeMode mode) =>
      _preferences.setString('app_theme_mode', mode.name);

  Future<void> savePalette(AppPalette palette) =>
      _preferences.setString('app_palette', palette.name);
}
