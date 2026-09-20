import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

abstract interface class TheatreApiClient {
  Future<List<ProductionDto>> getProductions();
  Future<List<SeatDto>> getSeatMap(String performanceId);
}
