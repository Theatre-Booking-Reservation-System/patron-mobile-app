import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  late _RecordingAuthSessionStore sessionStore;

  test('starts without granting application access', () {
    final bloc = AuthBloc();
    addTearDown(bloc.close);

    expect(bloc.state.status, AuthStatus.anonymous);
    expect(bloc.state.hasAppAccess, isFalse);
  });

  blocTest<AuthBloc, AuthState>(
    'creates an explicit guest session',
    build: AuthBloc.new,
    act: (bloc) => bloc.add(const AuthGuestRequested()),
    expect: () => [const AuthState(status: AuthStatus.guest)],
  );

  test('starts authenticated when a secure session was restored', () {
    final bloc = AuthBloc(
      restoredSession: const AuthSessionData(
        name: 'Nimal Perera',
        email: 'nimal.perera@example.com',
      ),
    );
    addTearDown(bloc.close);

    expect(bloc.state.status, AuthStatus.authenticated);
    expect(bloc.state.patron?.email, 'nimal.perera@example.com');
  });

  blocTest<AuthBloc, AuthState>(
    'persists a successful login in the session store',
    setUp: () => sessionStore = _RecordingAuthSessionStore(),
    build: () => AuthBloc(sessionStore: sessionStore),
    act: (bloc) => bloc.add(
      const AuthLoginRequested('nimal.perera@example.com', 'SapumalDemo#1'),
    ),
    wait: const Duration(milliseconds: 700),
    verify: (_) {
      expect(sessionStore.session?.email, 'nimal.perera@example.com');
    },
  );

  blocTest<AuthBloc, AuthState>(
    'clears the persisted session on explicit logout',
    setUp: () => sessionStore = _RecordingAuthSessionStore(
      const AuthSessionData(
        name: 'Nimal Perera',
        email: 'nimal.perera@example.com',
      ),
    ),
    build: () => AuthBloc(
      sessionStore: sessionStore,
      restoredSession: sessionStore.session,
    ),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState.anonymous()],
    verify: (_) {
      expect(sessionStore.session, isNull);
      expect(sessionStore.clearCount, 1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'authenticates locally when login details pass validation',
    build: AuthBloc.new,
    act: (bloc) => bloc.add(
      const AuthLoginRequested('nimal.perera@example.com', 'SapumalDemo#1'),
    ),
    wait: const Duration(milliseconds: 700),
    expect: () => [
      const AuthState(status: AuthStatus.submitting),
      const AuthState(
        status: AuthStatus.authenticated,
        patron: MockPatron(
          name: 'Nimal Perera',
          email: 'nimal.perera@example.com',
        ),
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'rejects malformed local login details',
    build: AuthBloc.new,
    act: (bloc) => bloc.add(const AuthLoginRequested('invalid', 'short')),
    wait: const Duration(milliseconds: 700),
    expect: () => [
      const AuthState(status: AuthStatus.submitting),
      const AuthState(status: AuthStatus.failure, error: 'invalidCredentials'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'retains date of birth in the local registration result',
    build: AuthBloc.new,
    act: (bloc) => bloc.add(
      AuthRegistrationRequested(
        name: 'Haritha Perera',
        email: 'haritha@example.com',
        phone: '+94 77 123 4567',
        dateOfBirth: DateTime(1997, 8, 14),
        identityNumber: '199712345678',
        password: 'SapumalDemo#1',
      ),
    ),
    wait: const Duration(milliseconds: 800),
    verify: (bloc) {
      expect(bloc.state.status, AuthStatus.registrationSuccess);
      expect(bloc.state.patron?.dateOfBirth, DateTime(1997, 8, 14));
    },
  );
}

class _RecordingAuthSessionStore implements AuthSessionStore {
  _RecordingAuthSessionStore([this.session]);

  AuthSessionData? session;
  int clearCount = 0;

  @override
  Future<void> clear() async {
    clearCount++;
    session = null;
  }

  @override
  Future<AuthSessionData?> read() async => session;

  @override
  Future<void> save(AuthSessionData session) async {
    this.session = session;
  }
}
