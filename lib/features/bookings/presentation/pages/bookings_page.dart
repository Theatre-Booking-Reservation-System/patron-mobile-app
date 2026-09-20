import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.bookings),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: context.l10n.upcomingTab),
              Tab(text: context.l10n.pastTab),
            ],
          ),
        ),
        body: BlocBuilder<BookingsBloc, BookingsState>(
          builder: (context, state) {
            if (state.status == BookingsStatus.loading &&
                state.bookings.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final upcoming = state.bookings
                .where((booking) => booking.status == BookingStatus.confirmed)
                .toList();
            final past = state.bookings
                .where((booking) => booking.status != BookingStatus.confirmed)
                .toList();
            return TabBarView(
              children: [
                _BookingList(bookings: upcoming),
                _BookingList(bookings: past),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _BookingLookupDialog(),
          ),
          icon: const Icon(Icons.search),
          label: Text(context.l10n.lookupBooking),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 58,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(context.l10n.noBookings),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final locale = Localizations.localeOf(context).languageCode;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.production.title.resolve(locale),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppFormatters.date(booking.performance.dateTime, locale)} • ${AppFormatters.time(booking.performance.dateTime, locale)}',
                ),
                const SizedBox(height: 6),
                Text(
                  booking.seats
                      .map((seat) => '${seat.row}${seat.number}')
                      .join(', '),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.reference,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Chip(label: Text(context.l10n.bookingConfirmed)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingLookupDialog extends StatefulWidget {
  const _BookingLookupDialog();

  @override
  State<_BookingLookupDialog> createState() => _BookingLookupDialogState();
}

class _BookingLookupDialogState extends State<_BookingLookupDialog> {
  final reference = TextEditingController();
  final email = TextEditingController();

  @override
  void dispose() {
    reference.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.lookupBooking),
      content: BlocBuilder<BookingsBloc, BookingsState>(
        builder: (context, state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reference,
              decoration: InputDecoration(labelText: context.l10n.reference),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: context.l10n.email),
            ),
            if (state.status == BookingsStatus.notFound) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.notFound,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (state.lookupResult != null) ...[
              const SizedBox(height: 12),
              Text(
                state.lookupResult!.production.title.resolve(
                  Localizations.localeOf(context).languageCode,
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => context.read<BookingsBloc>().add(
            BookingLookupRequested(reference.text.trim(), email.text.trim()),
          ),
          child: Text(context.l10n.search),
        ),
      ],
    );
  }
}
