import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/app/app.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await getIt.reset();
  });

  tearDown(() => getIt.reset());

  testWidgets('restored login opens the dashboard instead of Welcome', (
    tester,
  ) async {
    const store = SecureAuthSessionStore(FlutterSecureStorage());
    await store.save(
      const AuthSessionData(
        name: 'Nimal Perera',
        email: 'nimal.perera@example.com',
      ),
    );
    await configureDependencies();

    await tester.pumpWidget(const SapumalApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, Nimal'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
  });
}
