import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<CheckoutBloc>().state.booking;
    if (booking == null) {
      return Scaffold(body: Center(child: Text(context.l10n.error)));
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 28),
            Center(
              child: Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFF51B46D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 58),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.bookingConfirmed,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.confirmationMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.bookingReference),
                    const SizedBox(height: 4),
                    SelectableText(
                      booking.reference,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(height: 28),
                    Text(
                      booking.production.title.resolve(
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.seats
                          .map((seat) => '${seat.row}${seat.number}')
                          .join(', '),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.money(booking.quote.total),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            if (booking.isFlagged) ...[
              const SizedBox(height: 14),
              Text(context.l10n.flagged, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/bookings'),
              child: Text(context.l10n.viewBookings),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(context.l10n.backHome),
            ),
          ],
        ),
      ),
    );
  }
}
