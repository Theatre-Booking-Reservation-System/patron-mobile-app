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

final class BookingLookupRequested extends BookingsEvent {
  const BookingLookupRequested(this.reference, this.email);
  final String reference;
  final String email;
  @override
  List<Object?> get props => [reference, email];
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
    on<BookingLookupRequested>((event, emit) async {
      emit(
        BookingsState(status: BookingsStatus.loading, bookings: state.bookings),
      );
      final result = await _repository.findBooking(
        event.reference,
        event.email,
      );
      emit(
        BookingsState(
          status: result == null
              ? BookingsStatus.notFound
              : BookingsStatus.success,
          bookings: state.bookings,
          lookupResult: result,
        ),
      );
    });
  }

  final TheatreRepository _repository;
}
