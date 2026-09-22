import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionData {
  const AuthSessionData({
    required this.name,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.identityNumber,
    this.isLoyaltyMember = false,
  });

  final String name;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? identityNumber;
  final bool isLoyaltyMember;

  Map<String, Object?> toJson() => {
    'version': 1,
    'name': name,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'identityNumber': identityNumber,
    'isLoyaltyMember': isLoyaltyMember,
  };

  static AuthSessionData? fromJson(Map<String, Object?> json) {
    final name = json['name'];
    final email = json['email'];
    if (name is! String || name.isEmpty || email is! String || email.isEmpty) {
      return null;
    }

    final rawDateOfBirth = json['dateOfBirth'];
    return AuthSessionData(
      name: name,
      email: email,
      phone: json['phone'] as String?,
      dateOfBirth: rawDateOfBirth is String
          ? DateTime.tryParse(rawDateOfBirth)
          : null,
      identityNumber: json['identityNumber'] as String?,
      isLoyaltyMember: json['isLoyaltyMember'] == true,
    );
  }
}

abstract interface class AuthSessionStore {
  Future<AuthSessionData?> read();

  Future<void> save(AuthSessionData session);

  Future<void> clear();
}

class SecureAuthSessionStore implements AuthSessionStore {
  const SecureAuthSessionStore(this._storage);

  static const _sessionKey = 'sapumal.authenticated_session.v1';

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
      if (session == null) await clear();
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
  Future<void> save(AuthSessionData session) async {}
}
