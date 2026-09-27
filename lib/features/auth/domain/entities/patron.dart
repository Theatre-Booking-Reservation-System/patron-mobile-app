import 'package:equatable/equatable.dart';

class Patron extends Equatable {
  const Patron({
    required this.name,
    required this.email,
    this.id,
    this.phone,
    this.dateOfBirth,
    this.identityNumber,
    this.role,
    this.isLoyaltyMember = false,
    this.loyaltyCardNumber,
  });

  final String? id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? identityNumber;
  final String? role;
  final bool isLoyaltyMember;
  final String? loyaltyCardNumber;

  Patron copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? identityNumber,
    String? role,
    bool? isLoyaltyMember,
    String? loyaltyCardNumber,
  }) => Patron(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    identityNumber: identityNumber ?? this.identityNumber,
    role: role ?? this.role,
    isLoyaltyMember: isLoyaltyMember ?? this.isLoyaltyMember,
    loyaltyCardNumber: loyaltyCardNumber ?? this.loyaltyCardNumber,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    dateOfBirth,
    identityNumber,
    role,
    isLoyaltyMember,
    loyaltyCardNumber,
  ];
}

class AuthenticatedPatron extends Equatable {
  const AuthenticatedPatron({
    required this.patron,
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
  });

  final Patron patron;
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [patron, accessToken, tokenType, expiresAt];
}
