import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/about_page.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:patron_mobile_app/l10n/app_localizations.dart';

void main() {
  testWidgets('About Us opens the theatre about screen', (tester) async {
    tester.view
      ..physicalSize = const Size(430, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = AuthBloc(
      restoredSession: const AuthSessionData(
        userId: 'patron-id',
        name: 'Nimal Perera',
        email: 'nimal@example.com',
      ),
    );
    addTearDown(bloc.close);

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('About Sapumal Theatre'), findsNothing);

    await tester.scrollUntilVisible(find.text('About Us'), 200);
    await tester.tap(find.text('About Us'));
    await tester.pumpAndSettle();

    expect(find.text('About Sapumal Theatre'), findsOneWidget);
    expect(
      find.text('A home for the performing arts in the heart of Colombo.'),
      findsOneWidget,
    );
    expect(find.text('Our Story'), findsOneWidget);
    expect(find.textContaining('Colombo 07'), findsOneWidget);
    expect(find.text('Our Mission'), findsOneWidget);
    expect(find.text('25+'), findsOneWidget);
    expect(find.text('180+'), findsOneWidget);
    expect(find.text('500K+'), findsOneWidget);
    expect(find.text('850'), findsOneWidget);
    expect(find.text('What We Stand For'), findsOneWidget);
    expect(find.text('Artistic Excellence'), findsOneWidget);
    expect(
      find.text('Stories in three languages for every community.'),
      findsOneWidget,
    );
    expect(
      find.text('A gathering place where people and stories meet.'),
      findsOneWidget,
    );
  });
}
