import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/production_details/presentation/pages/production_details_page.dart';
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
        isLoyaltyMember: false,
      ),
    );
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'poster Hero completes smoothly when opening and closing a show',
    (tester) async {
      tester.view
        ..physicalSize = const Size(430, 932)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SapumalApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shows').last);
      await tester.pumpAndSettle();

      final sourceHero = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'poster-sanda-katha',
      );
      expect(sourceHero, findsOneWidget);
      final sandaPosters = find.byWidgetPredicate(
        (widget) => widget is ProductionPoster && widget.title == 'Sanda Katha',
      );
      final sourceRect = tester.getRect(sandaPosters);

      await tester.tap(find.text('Sanda Katha').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final flightRect = tester.getRect(sandaPosters);
      expect(find.byType(ProductionDetailsPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      final destinationRect = tester.getRect(sandaPosters);
      final headerTitle = tester.widget<Text>(
        find.descendant(
          of: find.byType(FlexibleSpaceBar),
          matching: find.text('Sanda Katha'),
        ),
      );
      expect(headerTitle.style?.color, Colors.white);
      expect(flightRect.width, greaterThan(sourceRect.width));
      expect(flightRect.width, lessThan(destinationRect.width));
      expect(flightRect.top, lessThan(sourceRect.top));
      expect(flightRect.top, greaterThan(destinationRect.top));
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final reverseRect = tester.getRect(sandaPosters);
      expect(reverseRect.width, lessThan(destinationRect.width));
      expect(reverseRect.width, greaterThan(sourceRect.width));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byType(ProductionDetailsPage), findsNothing);
      expect(find.text('Sanda Katha'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('upcoming dashboard poster also flies into show details', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(430, 932)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SapumalApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sanda Katha').first);
    await tester.pumpAndSettle();

    final poster = find.byWidgetPredicate(
      (widget) => widget is ProductionPoster && widget.title == 'Sanda Katha',
    );
    final sourceRect = tester.getRect(poster);

    await tester.tap(find.text('Sanda Katha').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final flightRect = tester.getRect(poster);
    await tester.pumpAndSettle();
    final destinationRect = tester.getRect(poster);

    expect(flightRect.width, greaterThan(sourceRect.width));
    expect(flightRect.width, lessThan(destinationRect.width));
    expect(find.byType(ProductionDetailsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
