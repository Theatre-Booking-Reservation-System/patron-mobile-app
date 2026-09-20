import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/router/app_shell.dart';
import 'package:patron_mobile_app/features/auth/presentation/pages/login_page.dart';
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

GoRouter createRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
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
            state.extra! as ({Production production, Performance performance});
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
    GoRoute(path: '/payment', builder: (context, state) => const PaymentPage()),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const BookingConfirmationPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text(state.error.toString()))),
);
