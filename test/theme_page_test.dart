import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/core/widgets/language_selector.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/language_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await getIt.reset();
    const store = SecureAuthSessionStore(FlutterSecureStorage());
    await store.save(
      const AuthSessionData(
        name: 'Nimal Perera',
        email: 'nimal.perera@example.com',
        isLoyaltyMember: true,
      ),
    );
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets('Theme opens below Loyalty Card and keeps settings off Profile', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 932)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SapumalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Loyalty Card'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.byType(LanguageSelector), findsNothing);
    expect(
      tester.getTopLeft(find.text('Language')).dy,
      greaterThan(tester.getTopLeft(find.text('Theme')).dy),
    );
    expect(find.text('Brightness'), findsNothing);
    expect(find.text('Brand colour palette'), findsNothing);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('Brand colour palette'), findsOneWidget);
    expect(find.text('Language'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Brand colour palette'));
    await tester.pumpAndSettle();
    expect(find.text('Midnight'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Brightness'), findsNothing);
  });

  testWidgets('Language opens from Profile and changes the locale', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 932)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SapumalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelector), findsOneWidget);
    expect(find.text('Brightness'), findsNothing);

    await tester.tap(find.text('සිං'));
    await tester.pumpAndSettle();
    expect(find.text('භාෂාව'), findsNWidgets(2));
    expect(
      (await SharedPreferences.getInstance()).getString('app_locale'),
      'si',
    );
    expect(find.byType(LanguagePage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelector), findsNothing);
    expect(find.text('තේමාව'), findsOneWidget);
  });
}
