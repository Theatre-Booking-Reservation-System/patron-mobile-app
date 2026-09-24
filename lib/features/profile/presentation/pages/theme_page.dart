import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsBloc>().state;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.theme)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      settings.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    title: Text(context.l10n.themeMode),
                    subtitle: Text(
                      settings.themeMode == ThemeMode.dark
                          ? context.l10n.dark
                          : context.l10n.light,
                    ),
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (_) => context.read<AppSettingsBloc>().add(
                      const AppBrightnessToggled(),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.seedFor(settings.palette),
                    ),
                    title: Text(context.l10n.colourPalette),
                    subtitle: Text(_paletteName(context, settings.palette)),
                    trailing: const Icon(Icons.palette_outlined),
                    onTap: () => context.read<AppSettingsBloc>().add(
                      const AppPaletteCycled(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paletteName(BuildContext context, AppPalette palette) =>
      switch (palette) {
        AppPalette.burgundy => context.l10n.burgundy,
        AppPalette.midnight => context.l10n.midnight,
        AppPalette.emerald => context.l10n.emerald,
      };
}
