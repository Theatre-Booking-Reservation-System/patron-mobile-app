import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/services/ticket_pricing_service.dart';

sealed class SeatSelectionEvent extends Equatable {
  const SeatSelectionEvent();
  @override
  List<Object?> get props => const [];
}

final class SeatMapRequested extends SeatSelectionEvent {
  const SeatMapRequested(this.production, this.performance);
  final Production production;
  final Performance performance;
  @override
  List<Object?> get props => [production, performance];
}

final class SeatToggled extends SeatSelectionEvent {
  const SeatToggled(this.seat);
  final Seat seat;
  @override
  List<Object?> get props => [seat];
}

final class SeatSectionChanged extends SeatSelectionEvent {
  const SeatSectionChanged(this.section);
  final SeatSection section;
  @override
  List<Object?> get props => [section];
}

final class _HoldTicked extends SeatSelectionEvent {
  const _HoldTicked();
}

enum SeatSelectionStatus { initial, loading, success, failure, expired }

class SeatSelectionState extends Equatable {
  const SeatSelectionState({
    this.status = SeatSelectionStatus.initial,
    this.production,
    this.performance,
    this.seats = const [],
    this.selected = const [],
    this.section = SeatSection.stalls,
    this.secondsRemaining = 900,
  });

  final SeatSelectionStatus status;
  final Production? production;
  final Performance? performance;
  final List<Seat> seats;
  final List<Seat> selected;
  final SeatSection section;
  final int secondsRemaining;

  List<Seat> get visibleSeats =>
      seats.where((seat) => seat.section == section).toList(growable: false);

  int get vatInclusiveTotal => selected.fold(
    0,
    (sum, seat) => sum + const TicketPricingService().vatInclusivePreview(seat),
  );

  BookingDraft get draft => BookingDraft(
    production: production!,
    performance: performance!,
    seats: selected,
  );

  SeatSelectionState copyWith({
    SeatSelectionStatus? status,
    Production? production,
    Performance? performance,
    List<Seat>? seats,
    List<Seat>? selected,
    SeatSection? section,
    int? secondsRemaining,
  }) => SeatSelectionState(
    status: status ?? this.status,
    production: production ?? this.production,
    performance: performance ?? this.performance,
    seats: seats ?? this.seats,
    selected: selected ?? this.selected,
    section: section ?? this.section,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
  );

  @override
  List<Object?> get props => [
    status,
    production,
    performance,
    seats,
    selected,
    section,
    secondsRemaining,
  ];
}

class SeatSelectionBloc extends Bloc<SeatSelectionEvent, SeatSelectionState> {
  SeatSelectionBloc(this._repository) : super(const SeatSelectionState()) {
    on<SeatMapRequested>(_onRequested);
    on<SeatToggled>(_onToggled);
    on<SeatSectionChanged>(
      (event, emit) => emit(state.copyWith(section: event.section)),
    );
    on<_HoldTicked>((event, emit) {
      if (state.selected.isEmpty) return;
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        emit(
          state.copyWith(
            status: SeatSelectionStatus.expired,
            selected: const [],
            secondsRemaining: 900,
          ),
        );
      } else {
        emit(state.copyWith(secondsRemaining: remaining));
      }
    });
  }

  final TheatreRepository _repository;
  Timer? _timer;

  Future<void> _onRequested(
    SeatMapRequested event,
    Emitter<SeatSelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SeatSelectionStatus.loading,
        production: event.production,
        performance: event.performance,
      ),
    );
    try {
      final seats = await _repository.getSeats(
        event.production,
        event.performance,
      );
      emit(state.copyWith(status: SeatSelectionStatus.success, seats: seats));
    } on Object {
      emit(state.copyWith(status: SeatSelectionStatus.failure));
    }
  }

  void _onToggled(SeatToggled event, Emitter<SeatSelectionState> emit) {
    if (event.seat.status != SeatStatus.available) return;
    final selected = [...state.selected];
    final existing = selected.indexWhere((seat) => seat.id == event.seat.id);
    if (existing >= 0) {
      selected.removeAt(existing);
    } else {
      selected.add(event.seat);
    }
    if (selected.isNotEmpty && state.selected.isEmpty) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const _HoldTicked()),
      );
    }
    if (selected.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
    emit(state.copyWith(selected: selected, secondsRemaining: 900));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
