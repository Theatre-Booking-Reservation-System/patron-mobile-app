import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';

class MockPatron extends Equatable {
  const MockPatron({
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

  MockPatron copyWith({bool? isLoyaltyMember}) => MockPatron(
    name: name,
    email: email,
    phone: phone,
    dateOfBirth: dateOfBirth,
    identityNumber: identityNumber,
    isLoyaltyMember: isLoyaltyMember ?? this.isLoyaltyMember,
  );

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    dateOfBirth,
    identityNumber,
    isLoyaltyMember,
  ];
}

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

final class LoyaltyLinked extends AuthEvent {
  const LoyaltyLinked();
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
  final MockPatron? patron;
  final String error;

  bool get hasAppAccess =>
      status == AuthStatus.authenticated || status == AuthStatus.guest;
  bool get isGuest => status == AuthStatus.guest;

  @override
  List<Object?> get props => [status, patron, error];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  factory AuthBloc({
    AuthSessionStore sessionStore = const NoopAuthSessionStore(),
    AuthSessionData? restoredSession,
  }) => AuthBloc._(sessionStore, restoredSession);

  AuthBloc._(this._sessionStore, AuthSessionData? restoredSession)
    : super(_stateFromSession(restoredSession)) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGuestRequested>(_onGuestRequested);
    on<AuthRegistrationRequested>(_onRegistrationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<LoyaltyLinked>(_onLoyaltyLinked);
  }

  final AuthSessionStore _sessionStore;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.submitting));
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!_isValidEmail(event.email) || !isValidPassword(event.password)) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          error: 'invalidCredentials',
        ),
      );
      return;
    }

    final patron = MockPatron(
      name: _nameFromEmail(event.email),
      email: event.email.trim(),
    );
    await _saveSession(patron);
    emit(AuthState(status: AuthStatus.authenticated, patron: patron));
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

  Future<void> _onLoyaltyLinked(
    LoyaltyLinked event,
    Emitter<AuthState> emit,
  ) async {
    final patron = state.patron;
    if (patron == null) return;

    final updatedPatron = patron.copyWith(isLoyaltyMember: true);
    await _saveSession(updatedPatron);
    emit(AuthState(status: AuthStatus.authenticated, patron: updatedPatron));
  }

  Future<void> _onRegistrationRequested(
    AuthRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.submitting));
    await Future<void>.delayed(const Duration(milliseconds: 750));

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

    emit(
      AuthState(
        status: AuthStatus.registrationSuccess,
        patron: MockPatron(
          name: event.name.trim(),
          email: event.email.trim(),
          phone: event.phone.trim(),
          dateOfBirth: event.dateOfBirth,
          identityNumber: event.identityNumber.trim(),
        ),
      ),
    );
  }

  Future<void> _saveSession(MockPatron patron) =>
      _sessionStore.save(_sessionFromPatron(patron));

  Future<void> _clearSession() => _sessionStore.clear();
}

AuthState _stateFromSession(AuthSessionData? session) => session == null
    ? const AuthState.anonymous()
    : AuthState(
        status: AuthStatus.authenticated,
        patron: MockPatron(
          name: session.name,
          email: session.email,
          phone: session.phone,
          dateOfBirth: session.dateOfBirth,
          identityNumber: session.identityNumber,
          isLoyaltyMember: session.isLoyaltyMember,
        ),
      );

AuthSessionData _sessionFromPatron(MockPatron patron) => AuthSessionData(
  name: patron.name,
  email: patron.email,
  phone: patron.phone,
  dateOfBirth: patron.dateOfBirth,
  identityNumber: patron.identityNumber,
  isLoyaltyMember: patron.isLoyaltyMember,
);

bool isValidPassword(String value) =>
    value.length >= 12 &&
    RegExp('[A-Z]').hasMatch(value) &&
    RegExp('[a-z]').hasMatch(value) &&
    RegExp('[0-9]').hasMatch(value) &&
    RegExp(r'[^A-Za-z0-9]').hasMatch(value);

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
