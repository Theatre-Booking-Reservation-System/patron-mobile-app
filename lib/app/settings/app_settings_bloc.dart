import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';

sealed class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();
  @override
  List<Object?> get props => const [];
}

final class AppSettingsStarted extends AppSettingsEvent {
  const AppSettingsStarted();
}

final class AppLocaleSelected extends AppSettingsEvent {
  const AppLocaleSelected(this.locale);
  final Locale locale;
  @override
  List<Object?> get props => [locale];
}

final class AppBrightnessToggled extends AppSettingsEvent {
  const AppBrightnessToggled();
}

final class AppPaletteCycled extends AppSettingsEvent {
  const AppPaletteCycled();
}

final class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.locale = const Locale('en'),
    this.themeMode = ThemeMode.light,
    this.palette = AppPalette.burgundy,
    this.ready = false,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final AppPalette palette;
  final bool ready;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    AppPalette? palette,
    bool? ready,
  }) => AppSettingsState(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    palette: palette ?? this.palette,
    ready: ready ?? this.ready,
  );

  @override
  List<Object?> get props => [locale, themeMode, palette, ready];
}

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc(this._repository) : super(const AppSettingsState()) {
    on<AppSettingsStarted>((event, emit) {
      final value = _repository.load();
      emit(
        AppSettingsState(
          locale: value.locale,
          themeMode: value.themeMode,
          palette: value.palette,
          ready: true,
        ),
      );
    });
    on<AppLocaleSelected>((event, emit) async {
      emit(state.copyWith(locale: event.locale));
      await _repository.saveLocale(event.locale);
    });
    on<AppBrightnessToggled>((event, emit) async {
      final mode = state.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
      emit(state.copyWith(themeMode: mode));
      await _repository.saveThemeMode(mode);
    });
    on<AppPaletteCycled>((event, emit) async {
      final palette = AppPalette
          .values[(state.palette.index + 1) % AppPalette.values.length];
      emit(state.copyWith(palette: palette));
      await _repository.savePalette(palette);
    });
  }

  final AppSettingsRepository _repository;
}
