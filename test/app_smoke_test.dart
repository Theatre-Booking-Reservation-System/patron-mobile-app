import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() => getIt.reset());

  testWidgets('launches the branded home screen', (tester) async {
    await tester.pumpWidget(const SapumalApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('SAPUMAL THEATRE'), findsOneWidget);
    expect(find.text('Experience the Art of Performance'), findsOneWidget);
    expect(find.text('Book Tickets'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
