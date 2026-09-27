import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';
import 'package:patron_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<AuthenticatedPatron> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!_isValidEmail(email) || password.isEmpty) {
      throw const ApiException(ApiFailureType.unauthenticated);
    }
    final patron = Patron(
      id: 'mock-patron-id',
      name: _nameFromEmail(email),
      email: email.trim(),
      role: 'PATRON',
    );
    return AuthenticatedPatron(
      patron: patron,
      accessToken: 'mock-access-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<Patron> getPatron(String patronId) async =>
      Patron(id: patronId, name: '', email: '');

  @override
  Future<Patron> register({
    required String name,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String identityNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (name.trim().isEmpty ||
        !_isValidEmail(email) ||
        identityNumber.trim().isEmpty ||
        password.length < 8) {
      throw const ApiException(ApiFailureType.validation);
    }
    return Patron(
      id: 'mock-patron-id',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
      identityNumber: identityNumber.trim(),
    );
  }
}

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

String _nameFromEmail(String email) {
  final localPart = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
  return localPart
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
