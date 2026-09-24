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
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets('patron completes the mock booking flow', (tester) async {
    tester.view
      ..physicalSize = const Size(430, 932)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SapumalApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'welcome');

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'nimal.perera@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('loginPasswordField')),
      'SapumalDemo#1',
    );
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'authenticated home');
    expect(find.byKey(const Key('loyaltyMemberBadge')), findsNothing);
    expect(find.text('Unlock early access'), findsNothing);

    await tester.tap(find.text('Book Tickets'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'programme');
    await tester.tap(find.text('Sanda Katha').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'details');
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -650),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('09/10/2026').first);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'seats');

    await tester.tap(find.byKey(const ValueKey('seat_sk-01-stalls-AA-2')));
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'selected seat');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'passenger details');

    await tester.tap(find.text('Continue to Summary'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'summary');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'payment');
    await tester.tap(find.text('Pay Now'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Booking Confirmed!'), findsOneWidget);
    expect(find.textContaining('ST-2026-'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
