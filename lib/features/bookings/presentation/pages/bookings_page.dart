import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/booking_qr_code.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth.status != AuthStatus.authenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.bookings)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_outlined, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to view and manage your bookings.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    final bloc = context.read<AuthBloc>()
                      ..add(const AuthLogoutRequested());
                    await bloc.stream.firstWhere(
                      (state) => state.status == AuthStatus.anonymous,
                    );
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            if (state.status == BookingsStatus.failure &&
                state.bookings.isEmpty) {
              return _BookingsError(
                onRetry: () =>
                    context.read<BookingsBloc>().add(const BookingsRequested()),
              );
            }
            final now = DateTime.now();
            final upcoming = state.bookings
                .where(
                  (booking) =>
                      booking.canCancel &&
                      !booking.performance.dateTime.isBefore(now),
                )
                .toList();
            final past = state.bookings
                .where((booking) => !upcoming.contains(booking))
                .toList();
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                final bloc = context.read<BookingsBloc>()
                  ..add(const BookingsRequested());
                await bloc.stream.firstWhere(
                  (value) => value.status != BookingsStatus.loading,
                );
              },
              child: TabBarView(
                children: [
                  _BookingList(bookings: upcoming),
                  _BookingList(bookings: past),
                ],
              ),
            );
          },
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final locale = Localizations.localeOf(context).languageCode;
        return _BookingTicket(booking: booking, locale: locale);
      },
    );
  }
}

class _BookingTicket extends StatelessWidget {
  const _BookingTicket({required this.booking, required this.locale});

  final Booking booking;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.reference}'),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 104,
                color: scheme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BookingQrCode(data: booking.qrCode, size: 66),
                    const SizedBox(height: 8),
                    Text(
                      'TICKET QR',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 1,
                child: CustomPaint(
                  painter: _DashedDividerPainter(color: scheme.outlineVariant),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.production.title.resolve(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppFormatters.date(booking.performance.dateTime, locale)} • ${AppFormatters.time(booking.performance.dateTime, locale)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (booking.seats.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Seats ${booking.seats.map((seat) => '${seat.row}${seat.number}').join(', ')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.reference,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: scheme.outline),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppFormatters.money(booking.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _TicketStatus(status: booking.status),
                          const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketStatus extends StatelessWidget {
  const _TicketStatus({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cancelled =
        status == BookingStatus.cancelledAdmin ||
        status == BookingStatus.cancelledPatron ||
        status == BookingStatus.expired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cancelled ? scheme.errorContainer : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cancelled
              ? scheme.onErrorContainer
              : scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset.zero.translate(0, y), Offset(0, y + 4), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BookingsError extends StatelessWidget {
  const _BookingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.error),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}

String _statusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'Pending',
  BookingStatus.confirmed => 'Confirmed',
  BookingStatus.cancelledPatron || BookingStatus.cancelledAdmin => 'Cancelled',
  BookingStatus.expired => 'Expired',
};
