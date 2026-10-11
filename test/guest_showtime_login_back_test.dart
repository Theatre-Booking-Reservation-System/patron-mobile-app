import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await getIt.reset();
    await configureDependencies(useMockData: true);
  });

  tearDown(() => getIt.reset());

  testWidgets('guest seat tap opens the guest profile screen', (
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

    await tester.tap(find.text('Browse shows'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sanda Katha').first);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -650),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('09/10/2026').first);
    await tester.pumpAndSettle();

    expect(find.text('Select Seats'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('seat_guest-stalls-A-2')));
    await tester.pumpAndSettle();

    expect(find.text('You are browsing as a guest'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Select Seats'), findsNothing);
  });
}
