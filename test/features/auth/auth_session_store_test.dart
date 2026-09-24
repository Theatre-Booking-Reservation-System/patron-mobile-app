import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';

void main() {
  const storage = FlutterSecureStorage();
  const store = SecureAuthSessionStore(storage);

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('securely round-trips and clears an authenticated session', () async {
    final original = AuthSessionData(
      name: 'Nimal Perera',
      email: 'nimal.perera@example.com',
      phone: '+94 77 123 4567',
      dateOfBirth: DateTime(1997, 8, 14),
      identityNumber: '199712345678',
      isLoyaltyMember: true,
    );

    await store.save(original);
    final restored = await store.read();

    expect(restored?.name, original.name);
    expect(restored?.email, original.email);
    expect(restored?.phone, original.phone);
    expect(restored?.dateOfBirth, original.dateOfBirth);
    expect(restored?.identityNumber, original.identityNumber);
    expect(restored?.isLoyaltyMember, isTrue);

    await store.clear();
    expect(await store.read(), isNull);
  });
}
