import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:patron_mobile_app/core/config/api_config.dart';
import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/auth/data/models/auth_api_models.dart';
import 'package:patron_mobile_app/features/auth/domain/entities/patron.dart';
import 'package:patron_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<Patron> getPatron(String patronId) async {
    try {
      final response = await _dio.get<Object?>(
        '${ApiConfig.identityService}/patron/${Uri.encodeComponent(patronId)}',
      );
      return PatronDetailResponseDto.fromJson(
        _jsonObject(response.data),
      ).patron;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.toString(),
      );
    }
  }

  @override
  Future<AuthenticatedPatron> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '${ApiConfig.identityService}/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return LoginResponseDto.fromJson(
        _jsonObject(response.data),
      ).toDomain(DateTime.now());
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.toString(),
      );
    }
  }

  @override
  Future<Patron> register({
    required String name,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String identityNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '${ApiConfig.identityService}/patron/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'contactNo': phone.trim(),
          'dateOfBirth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
          'nicPassportNo': identityNumber.trim(),
          'password': password,
        },
      );
      final result = PatronRegisterResponseDto.fromJson(
        _jsonObject(response.data),
      );
      return Patron(
        id: result.patronId,
        name: name.trim(),
        email: result.email,
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
        identityNumber: identityNumber.trim(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        ApiFailureType.invalidResponse,
        message: error.toString(),
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
