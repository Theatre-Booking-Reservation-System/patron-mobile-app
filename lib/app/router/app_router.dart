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
import 'package:patron_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/booking_confirmation_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/booking_summary_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/passenger_details_page.dart';
import 'package:patron_mobile_app/features/checkout/presentation/pages/payment_page.dart';
import 'package:patron_mobile_app/features/home/presentation/pages/home_page.dart';
import 'package:patron_mobile_app/features/more/presentation/pages/more_page.dart';
import 'package:patron_mobile_app/features/production_details/presentation/pages/production_details_page.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:patron_mobile_app/features/programme/presentation/pages/programme_page.dart';
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
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/shows',
            builder: (context, state) => const ProgrammePage(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(path: '/more', builder: (context, state) => const MorePage()),
        ],
      ),
      GoRoute(
        path: '/production',
        builder: (context, state) =>
            ProductionDetailsPage(production: state.extra! as Production),
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
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
}

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
