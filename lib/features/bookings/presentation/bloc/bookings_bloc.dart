import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';

sealed class BookingsEvent extends Equatable {
  const BookingsEvent();
  @override
  List<Object?> get props => const [];
}

final class BookingsRequested extends BookingsEvent {
  const BookingsRequested();
}

final class BookingDetailsRequested extends BookingsEvent {
  const BookingDetailsRequested(this.reference);
  final String reference;
  @override
  List<Object?> get props => [reference];
}

final class BookingCancellationRequested extends BookingsEvent {
  const BookingCancellationRequested(this.booking);
  final Booking booking;
  @override
  List<Object?> get props => [booking];
}

enum BookingsStatus { initial, loading, success, failure, notFound }

class BookingsState extends Equatable {
  const BookingsState({
    this.status = BookingsStatus.initial,
    this.bookings = const [],
    this.lookupResult,
  });

  final BookingsStatus status;
  final List<Booking> bookings;
  final Booking? lookupResult;

  @override
  List<Object?> get props => [status, bookings, lookupResult];
}

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc(this._repository) : super(const BookingsState()) {
    on<BookingsRequested>((event, emit) async {
      emit(const BookingsState(status: BookingsStatus.loading));
      try {
        emit(
          BookingsState(
            status: BookingsStatus.success,
            bookings: await _repository.getBookings(),
          ),
        );
      } on Object {
        emit(const BookingsState(status: BookingsStatus.failure));
      }
    });
    on<BookingDetailsRequested>((event, emit) async {
      emit(
        BookingsState(status: BookingsStatus.loading, bookings: state.bookings),
      );
      try {
        final result = await _repository.getBooking(event.reference);
        emit(
          BookingsState(
            status: BookingsStatus.success,
            bookings: state.bookings,
            lookupResult: result,
          ),
        );
      } on Object {
        emit(
          BookingsState(
            status: BookingsStatus.notFound,
            bookings: state.bookings,
          ),
        );
      }
    });
    on<BookingCancellationRequested>((event, emit) async {
      emit(
        BookingsState(
          status: BookingsStatus.loading,
          bookings: state.bookings,
          lookupResult: state.lookupResult,
        ),
      );
      try {
        final cancelled = await _repository.cancelBooking(event.booking);
        final updated = state.bookings
            .map((item) => item.id == cancelled.id ? cancelled : item)
            .toList(growable: false);
        emit(
          BookingsState(
            status: BookingsStatus.success,
            bookings: updated,
            lookupResult: cancelled,
          ),
        );
      } on Object {
        emit(
          BookingsState(
            status: BookingsStatus.failure,
            bookings: state.bookings,
            lookupResult: state.lookupResult,
          ),
        );
      }
    });
  }

  final TheatreRepository _repository;
}
