import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:patron_mobile_app/core/config/api_config.dart';

abstract interface class AccessTokenProvider {
  Future<String?> readValidAccessToken();

  Future<void> clear();
}

class SessionExpiryNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

Dio createApiClient({
  required AccessTokenProvider tokenProvider,
  required SessionExpiryNotifier sessionExpiryNotifier,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenProvider.readValidAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final path = error.requestOptions.path;
        final isPublicAuthRequest =
            path.endsWith('/auth/login') || path.endsWith('/patron/register');
        if (error.response?.statusCode == 401 && !isPublicAuthRequest) {
          await tokenProvider.clear();
          sessionExpiryNotifier.notify();
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }
  return dio;
}
