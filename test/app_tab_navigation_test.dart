import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/app/router/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets('primary destinations switch as tabs and support swiping', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 932)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SapumalApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guestButton')));
    await tester.pumpAndSettle();

    LiquidGlassNavigationBar navigationBar() =>
        tester.widget(find.byType(LiquidGlassNavigationBar));
    expect(navigationBar().selectedIndex, 0);

    await tester.drag(
      find.byKey(const Key('primaryTabPageView')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();
    expect(navigationBar().selectedIndex, 1);

    final bar = find.byType(LiquidGlassNavigationBar);
    await tester.tap(find.descendant(of: bar, matching: find.text('Profile')));
    await tester.pump();
    expect(navigationBar().selectedIndex, 3);

    var pageView = tester.widget<PageView>(
      find.byKey(const Key('primaryTabPageView')),
    );
    expect(pageView.controller?.page, 1);
    await tester.pump(const Duration(milliseconds: 120));
    expect(pageView.controller!.page, greaterThan(1));
    expect(pageView.controller!.page, lessThan(3));
    await tester.pumpAndSettle();
    expect(pageView.controller?.page, 3);

    await tester.tap(find.descendant(of: bar, matching: find.text('Home')));
    await tester.pump();
    expect(navigationBar().selectedIndex, 0);
    await tester.pumpAndSettle();

    pageView = tester.widget<PageView>(
      find.byKey(const Key('primaryTabPageView')),
    );
    expect(pageView.controller?.page, 0);
    expect(tester.takeException(), isNull);
  });
}
