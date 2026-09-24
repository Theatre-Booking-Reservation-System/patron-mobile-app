import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/app/router/app_shell.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:patron_mobile_app/features/auth/presentation/pages/registration_page.dart';
import 'package:patron_mobile_app/features/auth/presentation/pages/registration_success_page.dart';
import 'package:patron_mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/booking_confirmation_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/booking_summary_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/passenger_details_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/payment_page.dart';
import 'package:patron_mobile_app/features/more/presentation/pages/more_page.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/language_page.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/theme_page.dart';
import 'package:patron_mobile_app/features/production_details/presentation/pages/production_details_page.dart';
import 'package:patron_mobile_app/features/seat_selection/presentation/pages/seat_selection_page.dart';

GoRouter createRouter() {
  final authBloc = getIt<AuthBloc>();
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = {
        '/welcome',
        '/login',
        '/register',
        '/registration-success',
      }.contains(path);

      if (authBloc.state.hasAppAccess) {
        return isPublic ? '/home' : null;
      }
      return isPublic ? null : '/welcome';
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/registration-success',
        builder: (context, state) => const RegistrationSuccessPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          selectedIndex: _tabPaths.indexWhere(
            (path) => state.uri.path.startsWith(path),
          ),
          child: child,
        ),
        routes: [
          ..._tabPaths.map(
            (path) => GoRoute(
              path: path,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          GoRoute(path: '/more', builder: (context, state) => const MorePage()),
        ],
      ),
      GoRoute(
        path: '/production',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          child: ProductionDetailsPage(production: state.extra! as Production),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/seats',
        builder: (context, state) {
          final data =
              state.extra!
                  as ({Production production, Performance performance});
          return SeatSelectionPage(
            production: data.production,
            performance: data.performance,
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) =>
            PassengerDetailsPage(draft: state.extra! as BookingDraft),
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) => const BookingSummaryPage(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: '/confirmation',
        builder: (context, state) => const BookingConfirmationPage(),
      ),
      GoRoute(path: '/theme', builder: (context, state) => const ThemePage()),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguagePage(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
}

const _tabPaths = ['/home', '/shows', '/bookings', '/profile'];

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
