import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/core/network/api_client.dart';
import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';
import 'package:patron_mobile_app/features/auth/domain/repositories/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

final class AuthRegistrationRequested extends AuthEvent {
  const AuthRegistrationRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.identityNumber,
    required this.password,
  });

  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String identityNumber;
  final String password;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    dateOfBirth,
    identityNumber,
    password,
  ];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class _AuthSessionExpired extends AuthEvent {
  const _AuthSessionExpired();
}

enum AuthStatus {
  anonymous,
  submitting,
  authenticated,
  guest,
  registrationSuccess,
  failure,
}

class AuthState extends Equatable {
  const AuthState({required this.status, this.patron, this.error = ''});

  const AuthState.anonymous()
    : status = AuthStatus.anonymous,
      patron = null,
      error = '';

  final AuthStatus status;
  final Patron? patron;
  final String error;

  bool get hasAppAccess =>
      status == AuthStatus.authenticated || status == AuthStatus.guest;
  bool get isGuest => status == AuthStatus.guest;

  @override
  List<Object?> get props => [status, patron, error];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  factory AuthBloc({
    AuthRepository? repository,
    AuthSessionStore sessionStore = const NoopAuthSessionStore(),
    AuthSessionData? restoredSession,
    SessionExpiryNotifier? sessionExpiryNotifier,
  }) => AuthBloc._(
    repository ?? const MockAuthRepository(),
    sessionStore,
    restoredSession,
    sessionExpiryNotifier,
  );

  AuthBloc._(
    this._repository,
    this._sessionStore,
    this._sessionData,
    SessionExpiryNotifier? sessionExpiryNotifier,
  ) : super(_stateFromSession(_sessionData)) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGuestRequested>(_onGuestRequested);
    on<AuthRegistrationRequested>(_onRegistrationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<_AuthSessionExpired>(_onSessionExpired);
    _expirySubscription = sessionExpiryNotifier?.stream.listen(
      (_) => add(const _AuthSessionExpired()),
    );
  }

  final AuthRepository _repository;
  final AuthSessionStore _sessionStore;
  AuthSessionData? _sessionData;
  StreamSubscription<void>? _expirySubscription;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.submitting));
    if (!_isValidEmail(event.email) || event.password.isEmpty) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          error: 'invalidCredentials',
        ),
      );
      return;
    }

    try {
      final result = await _repository.login(
        email: event.email,
        password: event.password,
      );
      _sessionData = AuthSessionData.fromAuthenticated(result);
      await _sessionStore.save(_sessionData!);
      var patron = result.patron;
      try {
        final profile = await _repository.getPatron(result.patron.id!);
        patron = result.patron.copyWith(
          name: profile.name.isEmpty ? result.patron.name : profile.name,
          email: profile.email.isEmpty ? result.patron.email : profile.email,
          phone: profile.phone,
          dateOfBirth: profile.dateOfBirth,
          identityNumber: profile.identityNumber,
          isLoyaltyMember: profile.isLoyaltyMember,
          loyaltyCardNumber: profile.loyaltyCardNumber,
        );
        await _savePatron(patron);
      } on ApiException {
        // Authentication succeeded. Profile enrichment should not turn a
        // valid login into a misleading connectivity failure.
      }
      emit(AuthState(status: AuthStatus.authenticated, patron: patron));
    } on ApiException catch (error) {
      await _clearSession();
      emit(
        AuthState(
          status: AuthStatus.failure,
          error: switch (error.type) {
            ApiFailureType.accountLocked => 'accountLocked',
            ApiFailureType.unauthenticated ||
            ApiFailureType.validation => 'invalidCredentials',
            _ => 'networkError',
          },
        ),
      );
    }
  }

  Future<void> _onGuestRequested(
    AuthGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _clearSession();
    emit(const AuthState(status: AuthStatus.guest));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _clearSession();
    emit(const AuthState.anonymous());
  }

  Future<void> _onSessionExpired(
    _AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    _sessionData = null;
    if (state.status == AuthStatus.authenticated) {
      emit(
        const AuthState(status: AuthStatus.failure, error: 'sessionExpired'),
      );
      emit(const AuthState.anonymous());
    }
  }

  Future<void> _onRegistrationRequested(
    AuthRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.submitting));
    if (event.name.trim().isEmpty ||
        !_isValidEmail(event.email) ||
        event.phone.trim().isEmpty ||
        event.identityNumber.trim().isEmpty ||
        !isValidPassword(event.password)) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          error: 'invalidRegistration',
        ),
      );
      return;
    }

    try {
      final patron = await _repository.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
        identityNumber: event.identityNumber,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.registrationSuccess, patron: patron));
    } on ApiException catch (error) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          error: switch (error.type) {
            ApiFailureType.conflict => 'emailAlreadyRegistered',
            ApiFailureType.validation => 'invalidRegistration',
            _ => 'networkError',
          },
        ),
      );
    }
  }

  Future<void> _savePatron(Patron patron) async {
    final session = _sessionData;
    if (session == null) return;
    _sessionData = session.copyWith(patron: patron);
    await _sessionStore.save(_sessionData!);
  }

  Future<void> _clearSession() async {
    _sessionData = null;
    await _sessionStore.clear();
  }

  @override
  Future<void> close() async {
    await _expirySubscription?.cancel();
    return super.close();
  }
}

AuthState _stateFromSession(AuthSessionData? session) => session == null
    ? const AuthState.anonymous()
    : AuthState(status: AuthStatus.authenticated, patron: session.toPatron());

bool isValidPassword(String value) =>
    value.length >= 12 &&
    RegExp('[A-Z]').hasMatch(value) &&
    RegExp('[a-z]').hasMatch(value) &&
    RegExp('[0-9]').hasMatch(value) &&
    RegExp(r'[^A-Za-z0-9]').hasMatch(value);

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
