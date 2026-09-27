import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/booking_qr_code.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<CheckoutBloc>().state.booking;
    if (booking == null) {
      return Scaffold(body: Center(child: Text(context.l10n.error)));
    }
    final confirmed = booking.status == BookingStatus.confirmed;
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
                decoration: BoxDecoration(
                  color: confirmed
                      ? const Color(0xFF51B46D)
                      : Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  confirmed ? Icons.check : Icons.schedule_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              confirmed ? context.l10n.bookingConfirmed : 'Booking created',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              confirmed
                  ? context.l10n.confirmationMessage
                  : 'Your booking was created and is awaiting confirmation.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (booking.qrCode != null) ...[
              Center(child: BookingQrCode(data: booking.qrCode, size: 210)),
              const SizedBox(height: 12),
              const Text(
                'Present this QR code at the theatre entrance.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
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
                      AppFormatters.money(booking.total),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (booking.cardLast4 != null) ...[
                      const SizedBox(height: 8),
                      Text('Paid with card ending ${booking.cardLast4}'),
                    ],
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
