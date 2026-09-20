import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

abstract interface class TheatreRepository {
  Future<List<Production>> getProductions();
  Future<List<Seat>> getSeats(Production production, Performance performance);
  Future<Booking> confirmBooking({
    required BookingDraft draft,
    required PatronDetails patron,
    required BookingQuote quote,
  });
  Future<List<Booking>> getBookings();
  Future<Booking?> findBooking(String reference, String email);
}
