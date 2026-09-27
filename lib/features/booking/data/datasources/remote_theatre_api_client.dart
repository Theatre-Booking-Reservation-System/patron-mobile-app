import 'package:dio/dio.dart';
import 'package:patron_mobile_app/core/config/api_config.dart';
import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/models/api_models.dart';

class RemoteTheatreApiClient implements TheatreApiClient {
  const RemoteTheatreApiClient(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductionDto>> getProductions() async {
    final json = await _get('${ApiConfig.catalogueService}/productions');
    return _objectList(
      json['productions'],
    ).map(ProductionDto.fromJson).toList(growable: false);
  }

  @override
  Future<List<PerformanceDto>> getPerformances(String productionId) async {
    final json = await _get(
      '${ApiConfig.catalogueService}/productions/$productionId/performances',
    );
    return _objectList(
      json['performances'],
    ).map(PerformanceDto.fromJson).toList(growable: false);
  }

  @override
  Future<PerformanceDto> getPerformance(String performanceId) async {
    final json = await _get(
      '${ApiConfig.catalogueService}/performances/$performanceId',
    );
    return PerformanceDto.fromJson(json);
  }

  @override
  Future<List<SeatZoneDto>> getSeatZones() async {
    final json = await _get('${ApiConfig.seatService}/seat-zones');
    return _objectList(
      json['seatZones'],
    ).map(SeatZoneDto.fromJson).toList(growable: false);
  }

  @override
  Future<List<SeatDto>> getSeatMap(String performanceId) async {
    final json = await _get(
      '${ApiConfig.seatService}/performances/$performanceId/seats',
    );
    return _objectList(
      json['seats'],
    ).map(SeatDto.fromJson).toList(growable: false);
  }

  @override
  Future<BookingDto> createBooking(BookingRequestDto request) async {
    final json = await _send(
      '${ApiConfig.bookingService}/bookings',
      data: request.toJson(),
    );
    return BookingDto.fromJson(json);
  }

  @override
  Future<List<BookingSummaryDto>> getBookings(String patronId) async {
    final json = await _get(
      '${ApiConfig.bookingService}/patrons/$patronId/bookings',
    );
    return _objectList(
      json['bookings'],
    ).map(BookingSummaryDto.fromJson).toList(growable: false);
  }

  @override
  Future<BookingDto> getBooking(String reference) async {
    final json = await _get(
      '${ApiConfig.bookingService}/bookings/${Uri.encodeComponent(reference)}',
    );
    return BookingDto.fromJson(json);
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId) async {
    final json = await _send(
      '${ApiConfig.bookingService}/bookings/$bookingId/cancel',
      method: 'PUT',
    );
    return BookingDto.fromJson(json);
  }

  Future<Map<String, Object?>> _get(String path) async {
    try {
      final response = await _dio.get<Object?>(path);
      return _jsonObject(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on TypeError catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.toString(),
      );
    } on FormatException catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.message,
      );
    }
  }

  Future<Map<String, Object?>> _send(
    String path, {
    String method = 'POST',
    Object? data,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        options: Options(method: method),
      );
      return _jsonObject(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on TypeError catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.toString(),
      );
    } on FormatException catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.message,
      );
    }
  }
}

Map<String, Object?> _jsonObject(Object? data) {
  if (data is Map<String, Object?>) return data;
  if (data is Map) return data.cast<String, Object?>();
  throw const ApiException(
    ApiFailureType.invalidResponse,
    message: 'Expected a JSON object from the server.',
  );
}

List<Map<String, Object?>> _objectList(Object? data) {
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .map((value) => value.cast<String, Object?>())
      .toList(growable: false);
}
