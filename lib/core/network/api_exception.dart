import 'package:dio/dio.dart';

enum ApiFailureType {
  validation,
  unauthenticated,
  forbidden,
  notFound,
  conflict,
  accountLocked,
  timeout,
  noConnection,
  server,
  invalidResponse,
  unknown,
}

class ApiException implements Exception {
  const ApiException(this.type, {this.message, this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _descriptionFrom(error.response?.data) ?? error.message;
    final type = switch (statusCode) {
      400 || 422 => ApiFailureType.validation,
      401 => ApiFailureType.unauthenticated,
      403 => ApiFailureType.forbidden,
      404 => ApiFailureType.notFound,
      409 => ApiFailureType.conflict,
      423 => ApiFailureType.accountLocked,
      final code when code != null && code >= 500 => ApiFailureType.server,
      _ => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => ApiFailureType.timeout,
        DioExceptionType.connectionError => ApiFailureType.noConnection,
        _ => ApiFailureType.unknown,
      },
    };
    return ApiException(type, message: message, statusCode: statusCode);
  }

  final ApiFailureType type;
  final String? message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($type, $statusCode, $message)';
}

String? _descriptionFrom(Object? data) {
  if (data is! Map) return null;
  final description = data['statusDescription'] ?? data['message'];
  return description is String && description.trim().isNotEmpty
      ? description.trim()
      : null;
}
