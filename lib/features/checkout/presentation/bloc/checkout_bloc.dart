import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/services/ticket_pricing_service.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => const [];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted(this.draft, {required this.isLoyaltyMember});
  final BookingDraft draft;
  final bool isLoyaltyMember;
  @override
  List<Object?> get props => [draft, isLoyaltyMember];
}

final class PatronDetailsSubmitted extends CheckoutEvent {
  const PatronDetailsSubmitted(this.details);
  final PatronDetails details;
  @override
  List<Object?> get props => [details];
}

final class CheckoutConsentChanged extends CheckoutEvent {
  const CheckoutConsentChanged(this.accepted);
  final bool accepted;
  @override
  List<Object?> get props => [accepted];
}

final class PaymentRequested extends CheckoutEvent {
  const PaymentRequested({this.simulateFailure = false});
  final bool simulateFailure;
  @override
  List<Object?> get props => [simulateFailure];
}

final class CheckoutReset extends CheckoutEvent {
  const CheckoutReset();
}

enum CheckoutStatus {
  initial,
  editing,
  quoted,
  paying,
  paymentFailure,
  confirmed,
}

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.draft,
    this.patron,
    this.quote,
    this.booking,
    this.isLoyaltyMember = false,
    this.consentAccepted = false,
  });

  final CheckoutStatus status;
  final BookingDraft? draft;
  final PatronDetails? patron;
  final BookingQuote? quote;
  final Booking? booking;
  final bool isLoyaltyMember;
  final bool consentAccepted;

  CheckoutState copyWith({
    CheckoutStatus? status,
    BookingDraft? draft,
    PatronDetails? patron,
    BookingQuote? quote,
    Booking? booking,
    bool? isLoyaltyMember,
    bool? consentAccepted,
  }) => CheckoutState(
    status: status ?? this.status,
    draft: draft ?? this.draft,
    patron: patron ?? this.patron,
    quote: quote ?? this.quote,
    booking: booking ?? this.booking,
    isLoyaltyMember: isLoyaltyMember ?? this.isLoyaltyMember,
    consentAccepted: consentAccepted ?? this.consentAccepted,
  );

  @override
  List<Object?> get props => [
    status,
    draft,
    patron,
    quote,
    booking,
    isLoyaltyMember,
    consentAccepted,
  ];
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc(this._repository) : super(const CheckoutState()) {
    on<CheckoutStarted>((event, emit) {
      emit(
        CheckoutState(
          status: CheckoutStatus.editing,
          draft: event.draft,
          isLoyaltyMember: event.isLoyaltyMember,
        ),
      );
    });
    on<PatronDetailsSubmitted>((event, emit) {
      final quote = _pricing.quote(
        seats: state.draft!.seats,
        isLoyaltyMember: state.isLoyaltyMember,
        concession: event.details.concession,
      );
      emit(
        state.copyWith(
          status: CheckoutStatus.quoted,
          patron: event.details,
          quote: quote,
        ),
      );
    });
    on<CheckoutConsentChanged>(
      (event, emit) => emit(state.copyWith(consentAccepted: event.accepted)),
    );
    on<PaymentRequested>((event, emit) async {
      emit(state.copyWith(status: CheckoutStatus.paying));
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (event.simulateFailure) {
        emit(state.copyWith(status: CheckoutStatus.paymentFailure));
        return;
      }
      final booking = await _repository.confirmBooking(
        draft: state.draft!,
        patron: state.patron!,
        quote: state.quote!,
      );
      emit(state.copyWith(status: CheckoutStatus.confirmed, booking: booking));
    });
    on<CheckoutReset>((event, emit) => emit(const CheckoutState()));
  }

  final TheatreRepository _repository;
  final TicketPricingService _pricing = const TicketPricingService();
}
