import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';

abstract interface class AuthRepository {
  Future<AuthenticatedPatron> login({
    required String email,
    required String password,
  });

  Future<Patron> getPatron(String patronId);

  Future<Patron> register({
    required String name,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String identityNumber,
    required String password,
  });
}
