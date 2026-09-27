import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

abstract interface class TheatreApiClient {
  Future<List<ProductionDto>> getProductions();
  Future<List<PerformanceDto>> getPerformances(String productionId);
  Future<PerformanceDto> getPerformance(String performanceId);
  Future<List<SeatZoneDto>> getSeatZones();
  Future<List<SeatDto>> getSeatMap(String performanceId);
  Future<BookingDto> createBooking(BookingRequestDto request);
  Future<List<BookingSummaryDto>> getBookings(String patronId);
  Future<BookingDto> getBooking(String reference);
  Future<BookingDto> cancelBooking(String bookingId);
}
