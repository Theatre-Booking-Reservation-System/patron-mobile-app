import 'package:dio/dio.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

/// Adapter placeholder for the OpenAPI-generated client.
///
/// It is intentionally not registered until the backend-owned contract is ready.
class RemoteTheatreApiClient implements TheatreApiClient {
  RemoteTheatreApiClient(this.dio);

  final Dio dio;

  @override
  Future<List<ProductionDto>> getProductions() {
    throw UnsupportedError(
      'Remote API mode is disabled until backend delivery.',
    );
  }

  @override
  Future<List<SeatDto>> getSeatMap(String performanceId) {
    throw UnsupportedError(
      'Remote API mode is disabled until backend delivery.',
    );
  }
}
