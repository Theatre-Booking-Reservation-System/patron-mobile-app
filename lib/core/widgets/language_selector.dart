import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selected = context.select(
      (AppSettingsBloc bloc) => bloc.state.locale.languageCode,
    );
    const choices = [('EN', 'en'), ('සිං', 'si'), ('த', 'ta')];
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: compact
          ? const ButtonStyle(visualDensity: VisualDensity.compact)
          : null,
      segments: [
        for (final choice in choices)
          ButtonSegment(value: choice.$2, label: Text(choice.$1)),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        context.read<AppSettingsBloc>().add(
          AppLocaleSelected(Locale(selection.single)),
        );
      },
    );
  }
}
