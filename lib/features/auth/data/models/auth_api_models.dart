import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';

class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory LoginResponseDto.fromJson(Map<String, Object?> json) =>
      LoginResponseDto(
        accessToken: _requiredString(json, 'accessToken'),
        tokenType: _string(json, 'tokenType') ?? 'Bearer',
        expiresIn: _requiredInt(json, 'expiresIn'),
        userId: _requiredString(json, 'userId'),
        name: _requiredString(json, 'name'),
        email: _requiredString(json, 'email'),
        role: _requiredString(json, 'role'),
      );

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String name;
  final String email;
  final String role;

  AuthenticatedPatron toDomain(DateTime now) => AuthenticatedPatron(
    patron: Patron(id: userId, name: name, email: email, role: role),
    accessToken: accessToken,
    tokenType: tokenType,
    expiresAt: now.add(Duration(seconds: expiresIn)),
  );
}

class PatronRegisterResponseDto {
  const PatronRegisterResponseDto({
    required this.patronId,
    required this.email,
  });

  factory PatronRegisterResponseDto.fromJson(Map<String, Object?> json) =>
      PatronRegisterResponseDto(
        patronId: _requiredString(json, 'patronId'),
        email: _requiredString(json, 'email'),
      );

  final String patronId;
  final String email;
}

class PatronDetailResponseDto {
  const PatronDetailResponseDto({required this.patron});

  factory PatronDetailResponseDto.fromJson(Map<String, Object?> json) {
    final data = _requiredMap(json, 'patron');
    return PatronDetailResponseDto(
      patron: Patron(
        id: _string(data, 'patronId'),
        name: _string(data, 'name') ?? '',
        email: _string(data, 'email') ?? '',
        phone: _string(data, 'contactNo'),
        dateOfBirth: _date(data, 'dateOfBirth'),
        identityNumber: _string(data, 'nicPassportNo'),
        isLoyaltyMember: data['loyaltyHolder'] == true,
        loyaltyCardNumber: _string(data, 'loyaltyCardNo'),
      ),
    );
  }

  final Patron patron;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (value == null || value.isEmpty) {
    throw ApiException(
      ApiFailureType.invalidResponse,
      message: 'Missing $key in the server response.',
    );
  }
  return value;
}

String? _string(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is String ? value.trim() : null;
}

DateTime? _date(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  return value == null || value.isEmpty ? null : DateTime.parse(value);
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is num) return value.toInt();
  throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Missing $key in the server response.',
  );
}

Map<String, Object?> _requiredMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  throw ApiException(
    ApiFailureType.invalidResponse,
    message: 'Missing $key in the server response.',
  );
}
