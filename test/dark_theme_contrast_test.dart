import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';

void main() {
  test('dark palette icons and text maintain readable contrast', () {
    for (final palette in AppPalette.values) {
      final scheme = AppTheme.build(palette, Brightness.dark).colorScheme;

      expect(
        _contrast(scheme.primary, scheme.surface),
        greaterThanOrEqualTo(4.5),
        reason: '$palette primary against the dark surface',
      );
      expect(
        _contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
        reason: '$palette text against the dark surface',
      );
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
        reason: '$palette selected navigation content',
      );
    }
  });
}

double _contrast(Color first, Color second) {
  final light = first.computeLuminance();
  final dark = second.computeLuminance();
  return (light > dark ? light + .05 : dark + .05) /
      (light > dark ? dark + .05 : light + .05);
}
