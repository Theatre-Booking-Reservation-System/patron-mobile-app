import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/services/ticket_pricing_service.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:patron_mobile_app/features/seat_selection/presentation/bloc/seat_selection_bloc.dart';

class SeatSelectionPage extends StatelessWidget {
  const SeatSelectionPage({
    required this.production,
    required this.performance,
    super.key,
  });

  final Production production;
  final Performance performance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SeatSelectionBloc(getIt<TheatreRepository>())
            ..add(SeatMapRequested(production, performance)),
      child: const _SeatSelectionView(),
    );
  }
}

class _SeatSelectionView extends StatelessWidget {
  const _SeatSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.seatSelection)),
      body: BlocBuilder<SeatSelectionBloc, SeatSelectionState>(
        builder: (context, state) {
          if (state.status == SeatSelectionStatus.loading ||
              state.status == SeatSelectionStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == SeatSelectionStatus.failure) {
            return _SeatLoadFailure(state: state);
          }
          if (state.seats.isEmpty) {
            return _EmptySeatInventory(state: state);
          }
          final grouped = <String, List<Seat>>{};
          for (final seat in state.visibleSeats) {
            grouped.putIfAbsent(seat.row, () => []).add(seat);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.production!.title.resolve(
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _Legend(),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<SeatSection>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: SeatSection.stalls,
                            label: Text(context.l10n.stalls),
                            enabled: state.seats.any(
                              (seat) => seat.section == SeatSection.stalls,
                            ),
                          ),
                          ButtonSegment(
                            value: SeatSection.circle,
                            label: Text(context.l10n.circle),
                            enabled: state.seats.any(
                              (seat) => seat.section == SeatSection.circle,
                            ),
                          ),
                          ButtonSegment(
                            value: SeatSection.upperCircle,
                            label: Text(context.l10n.upperCircle),
                            enabled: state.seats.any(
                              (seat) => seat.section == SeatSection.upperCircle,
                            ),
                          ),
                        ],
                        selected: {state.section},
                        onSelectionChanged: (value) => context
                            .read<SeatSelectionBloc>()
                            .add(SeatSectionChanged(value.single)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 28,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.l10n.stage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final entry in grouped.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 7,
                                children: [
                                  for (final seat in entry.value)
                                    _SeatButton(
                                      seat: seat,
                                      isSelected: state.selected.any(
                                        (item) => item.id == seat.id,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.seatsSelected(
                                    state.selected.length,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (state.selected.isNotEmpty)
                                  Text(
                                    'Availability is checked again at checkout.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppFormatters.money(state.vatInclusiveTotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: state.selected.isEmpty
                            ? null
                            : () {
                                final loyalty =
                                    context
                                        .read<AuthBloc>()
                                        .state
                                        .patron
                                        ?.isLoyaltyMember ==
                                    true;
                                context.read<CheckoutBloc>().add(
                                  CheckoutStarted(
                                    state.draft,
                                    isLoyaltyMember: loyalty,
                                  ),
                                );
                                context.push('/checkout', extra: state.draft);
                              },
                        child: Text(context.l10n.continueLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SeatLoadFailure extends StatelessWidget {
  const _SeatLoadFailure({required this.state});

  final SeatSelectionState state;

  @override
  Widget build(BuildContext context) {
    final message = switch (state.failure) {
      SeatSelectionFailure.unauthenticated =>
        'Your session has expired. Please sign in again.',
      SeatSelectionFailure.forbidden =>
        'Seat availability is not accessible with this account.',
      SeatSelectionFailure.notFound =>
        'No seat inventory exists for this performance yet.',
      SeatSelectionFailure.noConnection =>
        'Could not connect to the Seat Service. Check your connection and try again.',
      SeatSelectionFailure.timeout =>
        'The Seat Service took too long to respond. Please try again.',
      SeatSelectionFailure.server =>
        'The Seat Service is temporarily unavailable. Please try again.',
      SeatSelectionFailure.invalidResponse =>
        'The Seat Service returned seat data that could not be read.',
      _ => context.l10n.error,
    };
    return _SeatStatusMessage(
      icon: Icons.event_seat_outlined,
      title: 'Seats could not be loaded',
      message: message,
      buttonLabel: context.l10n.retry,
      onPressed: () => _retry(context, state),
    );
  }
}

class _EmptySeatInventory extends StatelessWidget {
  const _EmptySeatInventory({required this.state});

  final SeatSelectionState state;

  @override
  Widget build(BuildContext context) => _SeatStatusMessage(
    icon: Icons.event_busy_outlined,
    title: 'No seats released yet',
    message:
        'The Seat Service returned an empty inventory for this performance.',
    buttonLabel: context.l10n.retry,
    onPressed: () => _retry(context, state),
  );
}

class _SeatStatusMessage extends StatelessWidget {
  const _SeatStatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(buttonLabel),
          ),
        ],
      ),
    ),
  );
}

void _retry(BuildContext context, SeatSelectionState state) {
  final production = state.production;
  final performance = state.performance;
  if (production == null || performance == null) return;
  context.read<SeatSelectionBloc>().add(
    SeatMapRequested(production, performance),
  );
}

class _SeatButton extends StatelessWidget {
  const _SeatButton({required this.seat, required this.isSelected});

  final Seat seat;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final seatTheme = Theme.of(context).extension<SeatStatusTheme>()!;
    final status = isSelected ? SeatStatus.available : seat.status;
    final color = isSelected
        ? seatTheme.selected
        : switch (status) {
            SeatStatus.available => seatTheme.available,
            SeatStatus.held => seatTheme.held,
            SeatStatus.booked => seatTheme.booked,
            SeatStatus.unavailable => seatTheme.unavailable,
          };
    final statusLabel = isSelected
        ? context.l10n.selected
        : switch (seat.status) {
            SeatStatus.available => context.l10n.available,
            SeatStatus.held => context.l10n.held,
            SeatStatus.booked => context.l10n.booked,
            SeatStatus.unavailable => context.l10n.unavailable,
          };
    final enabled = seat.status == SeatStatus.available;
    final label =
        '${seat.row}${seat.number}, ${seat.zoneName}, ${AppFormatters.money(const TicketPricingService().vatInclusivePreview(seat))}, $statusLabel${seat.isAccessible ? ', ${context.l10n.accessibleSeat}' : ''}';
    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          key: ValueKey('seat_${seat.id}'),
          onTap: enabled
              ? () => context.read<SeatSelectionBloc>().add(SeatToggled(seat))
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : color.withValues(alpha: .8),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: seat.isAccessible
                ? const Icon(Icons.accessible, size: 15, color: Colors.black87)
                : Text(
                    '${seat.number}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<SeatStatusTheme>()!;
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(theme.available, context.l10n.available),
        _LegendItem(theme.selected, context.l10n.selected),
        _LegendItem(theme.booked, context.l10n.booked),
        _LegendItem(theme.held, context.l10n.held),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
