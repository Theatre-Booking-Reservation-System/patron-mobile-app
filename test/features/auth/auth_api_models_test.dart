import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/auth/data/models/auth_api_models.dart';

void main() {
  test('maps the current identity login response', () {
    final now = DateTime(2026, 9, 26, 12);
    final result = LoginResponseDto.fromJson({
      'accessToken': 'jwt',
      'tokenType': 'Bearer',
      'expiresIn': 3600,
      'userId': 'patron-id',
      'name': 'Nimal Perera',
      'email': 'nimal@example.com',
      'role': 'PATRON',
    }).toDomain(now);

    expect(result.accessToken, 'jwt');
    expect(result.patron.id, 'patron-id');
    expect(result.patron.role, 'PATRON');
    expect(result.expiresAt, now.add(const Duration(hours: 1)));
  });

  test('maps the patron registration response', () {
    final response = PatronRegisterResponseDto.fromJson({
      'patronId': 'patron-id',
      'email': 'nimal@example.com',
      'statusCode': 201,
      'statusDescription': 'Created',
    });

    expect(response.patronId, 'patron-id');
    expect(response.email, 'nimal@example.com');
  });

  test('maps loyalty status from the patron detail response', () {
    final patron = PatronDetailResponseDto.fromJson({
      'patron': {
        'patronId': 'patron-id',
        'name': 'Nimal Perera',
        'email': 'nimal@example.com',
        'contactNo': '+94 77 123 4567',
        'dateOfBirth': '1997-08-14',
        'nicPassportNo': '199712345678',
        'loyaltyCardNo': 'LOY-0001',
        'loyaltyHolder': true,
      },
    }).patron;

    expect(patron.phone, '+94 77 123 4567');
    expect(patron.dateOfBirth, DateTime(1997, 8, 14));
    expect(patron.identityNumber, '199712345678');
    expect(patron.isLoyaltyMember, isTrue);
    expect(patron.loyaltyCardNumber, 'LOY-0001');
  });

  test('accepts optional profile fields returned as null', () {
    final patron = PatronDetailResponseDto.fromJson({
      'patron': {
        'patronId': 'patron-id',
        'name': 'Nimal Perera',
        'email': 'nimal@example.com',
        'contactNo': null,
        'dateOfBirth': null,
        'nicPassportNo': null,
        'loyaltyCardNo': null,
        'loyaltyHolder': false,
      },
    }).patron;

    expect(patron.dateOfBirth, isNull);
    expect(patron.identityNumber, isNull);
    expect(patron.isLoyaltyMember, isFalse);
  });
}
