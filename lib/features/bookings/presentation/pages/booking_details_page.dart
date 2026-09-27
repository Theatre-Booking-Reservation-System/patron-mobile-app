import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/widgets/booking_qr_code.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';

class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({required this.reference, super.key});

  final String reference;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        BookingsBloc(getIt<TheatreRepository>())
          ..add(BookingDetailsRequested(reference)),
    child: const _BookingDetailsView(),
  );
}

class _BookingDetailsView extends StatelessWidget {
  const _BookingDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket details')),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, state) {
          if (state.status == BookingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The booking could not be updated.'),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookingsStatus.loading &&
              state.lookupResult == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final booking = state.lookupResult;
          if (booking == null) {
            return const Center(child: Text('Booking details were not found.'));
          }
          return _Details(
            booking: booking,
            loading: state.status == BookingsStatus.loading,
          );
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.booking, required this.loading});

  final Booking booking;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (booking.qrCode != null) ...[
          Center(child: BookingQrCode(data: booking.qrCode, size: 220)),
          const SizedBox(height: 10),
          const Text(
            'Present this QR code at the theatre entrance.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.production.title.resolve(locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppFormatters.date(booking.performance.dateTime, locale)} • ${AppFormatters.time(booking.performance.dateTime, locale)}',
                ),
                const Divider(height: 28),
                const Text('Booking reference'),
                SelectableText(
                  booking.reference,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _ValueRow('Booking status', _bookingStatus(booking.status)),
                _ValueRow(
                  'Payment status',
                  _paymentStatus(booking.paymentStatus),
                ),
                if (booking.cardLast4 != null)
                  _ValueRow('Card', '•••• ${booking.cardLast4}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final line in booking.quote?.lines ?? const <TicketPrice>[])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.event_seat_outlined),
                title: Text('${line.seat.row}${line.seat.number}'),
                subtitle: Text(line.seat.zoneName),
                trailing: Text(AppFormatters.money(line.total)),
              ),
            ),
          ),
        const Divider(height: 28),
        _ValueRow(
          'Total',
          AppFormatters.money(booking.total),
          emphasized: true,
        ),
        if (booking.canCancel) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: loading ? null : () => _confirmCancellation(context),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel booking'),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmCancellation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
          'This action cannot be undone. A paid booking will be marked for refund.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BookingsBloc>().add(BookingCancellationRequested(booking));
    }
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value, {this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

String _bookingStatus(BookingStatus value) => switch (value) {
  BookingStatus.pending => 'Pending',
  BookingStatus.confirmed => 'Confirmed',
  BookingStatus.cancelledPatron || BookingStatus.cancelledAdmin => 'Cancelled',
  BookingStatus.expired => 'Expired',
};

String _paymentStatus(PaymentStatus value) => switch (value) {
  PaymentStatus.unpaid => 'Unpaid',
  PaymentStatus.paid => 'Paid',
  PaymentStatus.refunded => 'Refunded',
  PaymentStatus.failed => 'Failed',
};
