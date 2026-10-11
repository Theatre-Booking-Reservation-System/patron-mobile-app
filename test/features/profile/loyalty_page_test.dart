import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';
import 'package:patron_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/loyalty_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('enrols the signed-in patron from the loyalty screen', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(() => repository.enrollLoyalty('patron-id')).thenAnswer(
      (_) async => const LoyaltyEnrollment(
        patronId: 'patron-id',
        cardNumber: 'LOY-0001',
      ),
    );
    final bloc = AuthBloc(
      repository: repository,
      restoredSession: const AuthSessionData(
        userId: 'patron-id',
        name: 'Nimal Perera',
        email: 'nimal@example.com',
      ),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const LoyaltyPage()),
      ),
    );

    expect(find.text('Enroll as a loyalty member'), findsOneWidget);
    expect(find.text('CARD  LOY-0001'), findsNothing);

    await tester.tap(find.byKey(const Key('enrollLoyaltyButton')));
    await tester.pumpAndSettle();

    expect(find.text('CARD  LOY-0001'), findsOneWidget);
    expect(find.text('Your membership is active.'), findsOneWidget);
    expect(find.text('Enroll as a loyalty member'), findsNothing);
    verify(() => repository.enrollLoyalty('patron-id')).called(1);
  });
}
