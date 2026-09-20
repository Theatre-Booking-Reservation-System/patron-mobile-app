import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class MockPatron extends Equatable {
  const MockPatron({
    required this.name,
    required this.email,
    this.isLoyaltyMember = true,
  });

  final String name;
  final String email;
  final bool isLoyaltyMember;

  MockPatron copyWith({bool? isLoyaltyMember}) => MockPatron(
    name: name,
    email: email,
    isLoyaltyMember: isLoyaltyMember ?? this.isLoyaltyMember,
  );

  @override
  List<Object?> get props => [name, email, isLoyaltyMember];
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

final class AuthRegistrationRequested extends AuthEvent {
  const AuthRegistrationRequested(this.name, this.email, this.password);
  final String name;
  final String email;
  final String password;
  @override
  List<Object?> get props => [name, email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class LoyaltyLinked extends AuthEvent {
  const LoyaltyLinked();
}

enum AuthStatus { authenticated, anonymous, submitting, failure, locked }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.patron,
    this.error = '',
    this.failedAttempts = 0,
  });

  const AuthState.demo()
    : status = AuthStatus.authenticated,
      patron = const MockPatron(
        name: 'Nimal Perera',
        email: 'nimal.perera@example.com',
      ),
      error = '',
      failedAttempts = 0;

  final AuthStatus status;
  final MockPatron? patron;
  final String error;
  final int failedAttempts;

  @override
  List<Object?> get props => [status, patron, error, failedAttempts];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.demo()) {
    on<AuthLoginRequested>((event, emit) async {
      final previousAttempts = state.failedAttempts;
      emit(
        AuthState(
          status: AuthStatus.submitting,
          failedAttempts: previousAttempts,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!event.email.contains('@') || !_isValidPassword(event.password)) {
        final attempts = previousAttempts + 1;
        emit(
          AuthState(
            status: attempts >= 5 ? AuthStatus.locked : AuthStatus.failure,
            error: attempts >= 5 ? 'accountLocked' : 'invalidCredentials',
            failedAttempts: attempts,
          ),
        );
        return;
      }
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          patron: MockPatron(
            name: 'Nimal Perera',
            email: event.email,
            isLoyaltyMember: false,
          ),
        ),
      );
    });
    on<AuthRegistrationRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.submitting));
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (event.name.trim().isEmpty ||
          !event.email.contains('@') ||
          !_isValidPassword(event.password)) {
        emit(
          const AuthState(
            status: AuthStatus.failure,
            error: 'invalidCredentials',
          ),
        );
        return;
      }
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          patron: MockPatron(
            name: event.name.trim(),
            email: event.email,
            isLoyaltyMember: false,
          ),
        ),
      );
    });
    on<AuthLogoutRequested>(
      (event, emit) => emit(const AuthState(status: AuthStatus.anonymous)),
    );
    on<LoyaltyLinked>((event, emit) {
      final patron = state.patron;
      if (patron != null) {
        emit(
          AuthState(
            status: AuthStatus.authenticated,
            patron: patron.copyWith(isLoyaltyMember: true),
          ),
        );
      }
    });
  }
}

bool _isValidPassword(String value) =>
    value.length >= 12 &&
    RegExp('[A-Z]').hasMatch(value) &&
    RegExp('[a-z]').hasMatch(value) &&
    RegExp('[0-9]').hasMatch(value) &&
    RegExp(r'[^A-Za-z0-9]').hasMatch(value);
