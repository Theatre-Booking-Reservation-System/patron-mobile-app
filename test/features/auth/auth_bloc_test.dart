import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  blocTest<AuthBloc, AuthState>(
    'locks the mock account after five failed login attempts',
    build: AuthBloc.new,
    act: (bloc) async {
      bloc.add(const AuthLogoutRequested());
      await Future<void>.delayed(Duration.zero);
      for (var attempt = 0; attempt < 5; attempt++) {
        bloc.add(const AuthLoginRequested('invalid', 'short'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    },
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.status, AuthStatus.locked);
      expect(bloc.state.failedAttempts, 5);
    },
  );
}
