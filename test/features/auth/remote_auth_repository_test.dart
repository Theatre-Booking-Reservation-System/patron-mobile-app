import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/features/auth/data/repositories/remote_auth_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RemoteAuthRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = RemoteAuthRepository(dio);
  });

  test('sends date of birth and NIC/passport when registering', () async {
    when(() => dio.post<Object?>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response<Object?>(
        requestOptions: RequestOptions(),
        data: {
          'statusCode': 201,
          'statusDescription': 'Created',
          'patronId': 'patron-id',
          'email': 'nimal@example.com',
        },
      ),
    );

    final patron = await repository.register(
      name: 'Nimal Perera',
      email: 'nimal@example.com',
      phone: '+94 77 123 4567',
      dateOfBirth: DateTime(1997, 8, 14),
      identityNumber: '199712345678',
      password: 'SapumalDemo#1',
    );

    final request = verify(
      () => dio.post<Object?>(captureAny(), data: captureAny(named: 'data')),
    ).captured;
    expect(request.first, '/identity-service/patron/register');
    expect(request.last, {
      'name': 'Nimal Perera',
      'email': 'nimal@example.com',
      'contactNo': '+94 77 123 4567',
      'dateOfBirth': '1997-08-14',
      'nicPassportNo': '199712345678',
      'password': 'SapumalDemo#1',
    });
    expect(patron.dateOfBirth, DateTime(1997, 8, 14));
    expect(patron.identityNumber, '199712345678');
  });

  test('gets authoritative loyalty status from the patron endpoint', () async {
    when(() => dio.get<Object?>(any())).thenAnswer(
      (_) async => Response<Object?>(
        requestOptions: RequestOptions(),
        data: {
          'patron': {
            'patronId': 'patron/id',
            'name': 'Nimal Perera',
            'email': 'nimal@example.com',
            'contactNo': '+94 77 123 4567',
            'dateOfBirth': '1997-08-14',
            'nicPassportNo': '199712345678',
            'loyaltyCardNo': 'LOY-0001',
            'loyaltyHolder': true,
          },
        },
      ),
    );

    final patron = await repository.getPatron('patron/id');

    verify(
      () => dio.get<Object?>('/identity-service/patron/patron%2Fid'),
    ).called(1);
    expect(patron.isLoyaltyMember, isTrue);
    expect(patron.loyaltyCardNumber, 'LOY-0001');
  });
}
