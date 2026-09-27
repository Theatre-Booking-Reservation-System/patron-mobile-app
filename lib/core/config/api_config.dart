abstract final class ApiConfig {
  static const String baseUrl =
      'http://ec2-3-237-240-69.compute-1.amazonaws.com';

  static const String identityService = '/identity-service';
  static const String catalogueService = '/catalogue-service';
  static const String seatService = '/seat-service';
  static const String bookingService = '/booking-service';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
