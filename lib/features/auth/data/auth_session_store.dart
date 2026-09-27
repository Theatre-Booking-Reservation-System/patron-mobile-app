import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:patron_mobile_app/core/network/api_client.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';

class AuthSessionData {
  const AuthSessionData({
    required this.name,
    required this.email,
    this.userId,
    this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
    this.role,
    this.phone,
    this.dateOfBirth,
    this.identityNumber,
    this.isLoyaltyMember = false,
    this.loyaltyCardNumber,
  });

  factory AuthSessionData.fromAuthenticated(AuthenticatedPatron result) =>
      AuthSessionData(
        userId: result.patron.id,
        accessToken: result.accessToken,
        tokenType: result.tokenType,
        expiresAt: result.expiresAt,
        role: result.patron.role,
        name: result.patron.name,
        email: result.patron.email,
        phone: result.patron.phone,
        dateOfBirth: result.patron.dateOfBirth,
        identityNumber: result.patron.identityNumber,
        isLoyaltyMember: result.patron.isLoyaltyMember,
        loyaltyCardNumber: result.patron.loyaltyCardNumber,
      );

  final String? userId;
  final String? accessToken;
  final String tokenType;
  final DateTime? expiresAt;
  final String? role;
  final String name;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? identityNumber;
  final bool isLoyaltyMember;
  final String? loyaltyCardNumber;

  bool get hasValidAccessToken =>
      accessToken != null &&
      accessToken!.isNotEmpty &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());

  Patron toPatron() => Patron(
    id: userId,
    name: name,
    email: email,
    phone: phone,
    dateOfBirth: dateOfBirth,
    identityNumber: identityNumber,
    role: role,
    isLoyaltyMember: isLoyaltyMember,
    loyaltyCardNumber: loyaltyCardNumber,
  );

  AuthSessionData copyWith({required Patron patron}) => AuthSessionData(
    userId: userId ?? patron.id,
    accessToken: accessToken,
    tokenType: tokenType,
    expiresAt: expiresAt,
    role: role ?? patron.role,
    name: patron.name,
    email: patron.email,
    phone: patron.phone,
    dateOfBirth: patron.dateOfBirth,
    identityNumber: patron.identityNumber,
    isLoyaltyMember: patron.isLoyaltyMember,
    loyaltyCardNumber: patron.loyaltyCardNumber,
  );

  Map<String, Object?> toJson() => {
    'version': 2,
    'userId': userId,
    'accessToken': accessToken,
    'tokenType': tokenType,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'identityNumber': identityNumber,
    'isLoyaltyMember': isLoyaltyMember,
    'loyaltyCardNumber': loyaltyCardNumber,
  };

  static AuthSessionData? fromJson(Map<String, Object?> json) {
    final name = json['name'];
    final email = json['email'];
    if (json['version'] != 2 ||
        name is! String ||
        name.isEmpty ||
        email is! String ||
        email.isEmpty) {
      return null;
    }

    final rawDateOfBirth = json['dateOfBirth'];
    final rawExpiry = json['expiresAt'];
    return AuthSessionData(
      userId: json['userId'] as String?,
      accessToken: json['accessToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresAt: rawExpiry is String ? DateTime.tryParse(rawExpiry) : null,
      role: json['role'] as String?,
      name: name,
      email: email,
      phone: json['phone'] as String?,
      dateOfBirth: rawDateOfBirth is String
          ? DateTime.tryParse(rawDateOfBirth)
          : null,
      identityNumber: json['identityNumber'] as String?,
      isLoyaltyMember: json['isLoyaltyMember'] == true,
      loyaltyCardNumber: json['loyaltyCardNumber'] as String?,
    );
  }
}

abstract interface class AuthSessionStore implements AccessTokenProvider {
  Future<AuthSessionData?> read();

  Future<void> save(AuthSessionData session);
}

class SecureAuthSessionStore implements AuthSessionStore {
  const SecureAuthSessionStore(this._storage);

  static const _sessionKey = 'sapumal.authenticated_session.v2';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSessionData?> read() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }
      final session = AuthSessionData.fromJson(decoded);
      if (session == null || !session.hasValidAccessToken) {
        await clear();
        return null;
      }
      return session;
    } on FormatException {
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    }
  }

  @override
  Future<String?> readValidAccessToken() async => (await read())?.accessToken;

  @override
  Future<void> save(AuthSessionData session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}

class NoopAuthSessionStore implements AuthSessionStore {
  const NoopAuthSessionStore();

  @override
  Future<void> clear() async {}

  @override
  Future<AuthSessionData?> read() async => null;

  @override
  Future<String?> readValidAccessToken() async => null;

  @override
  Future<void> save(AuthSessionData session) async {}
}
