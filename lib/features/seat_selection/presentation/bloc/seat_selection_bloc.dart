import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/core/network/api_exception.dart';
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

enum SeatSelectionStatus { initial, loading, success, failure }

enum SeatSelectionFailure {
  unauthenticated,
  forbidden,
  notFound,
  noConnection,
  timeout,
  server,
  invalidResponse,
  unknown,
}

class SeatSelectionState extends Equatable {
  const SeatSelectionState({
    this.status = SeatSelectionStatus.initial,
    this.production,
    this.performance,
    this.seats = const [],
    this.selected = const [],
    this.section = SeatSection.stalls,
    this.failure,
  });

  final SeatSelectionStatus status;
  final Production? production;
  final Performance? performance;
  final List<Seat> seats;
  final List<Seat> selected;
  final SeatSection section;
  final SeatSelectionFailure? failure;

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
    SeatSelectionFailure? failure,
    bool clearFailure = false,
  }) => SeatSelectionState(
    status: status ?? this.status,
    production: production ?? this.production,
    performance: performance ?? this.performance,
    seats: seats ?? this.seats,
    selected: selected ?? this.selected,
    section: section ?? this.section,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    production,
    performance,
    seats,
    selected,
    section,
    failure,
  ];
}

class SeatSelectionBloc extends Bloc<SeatSelectionEvent, SeatSelectionState> {
  SeatSelectionBloc(this._repository) : super(const SeatSelectionState()) {
    on<SeatMapRequested>(_onRequested);
    on<SeatToggled>(_onToggled);
    on<SeatSectionChanged>(
      (event, emit) => emit(state.copyWith(section: event.section)),
    );
  }

  final TheatreRepository _repository;

  Future<void> _onRequested(
    SeatMapRequested event,
    Emitter<SeatSelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SeatSelectionStatus.loading,
        production: event.production,
        performance: event.performance,
        clearFailure: true,
      ),
    );
    try {
      final seats = await _repository.getSeats(
        event.production,
        event.performance,
      );
      final selectedSection = seats.any((seat) => seat.section == state.section)
          ? state.section
          : seats.isEmpty
          ? state.section
          : seats.first.section;
      emit(
        state.copyWith(
          status: SeatSelectionStatus.success,
          seats: seats,
          section: selectedSection,
          clearFailure: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: SeatSelectionStatus.failure,
          failure: _mapFailure(error.type),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: SeatSelectionStatus.failure,
          failure: SeatSelectionFailure.unknown,
        ),
      );
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
    emit(state.copyWith(selected: selected));
  }
}

SeatSelectionFailure _mapFailure(ApiFailureType type) => switch (type) {
  ApiFailureType.unauthenticated => SeatSelectionFailure.unauthenticated,
  ApiFailureType.forbidden => SeatSelectionFailure.forbidden,
  ApiFailureType.notFound => SeatSelectionFailure.notFound,
  ApiFailureType.noConnection => SeatSelectionFailure.noConnection,
  ApiFailureType.timeout => SeatSelectionFailure.timeout,
  ApiFailureType.server => SeatSelectionFailure.server,
  ApiFailureType.invalidResponse => SeatSelectionFailure.invalidResponse,
  _ => SeatSelectionFailure.unknown,
};
