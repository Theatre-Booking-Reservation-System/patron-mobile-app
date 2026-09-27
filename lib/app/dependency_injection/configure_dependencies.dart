import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';
import 'package:patron_mobile_app/core/network/api_client.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:patron_mobile_app/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:patron_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/mock_theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/remote_theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/mock_theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/remote_theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({bool useMockData = false}) async {
  if (getIt.isRegistered<AppSettingsBloc>()) return;

  final preferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  const authSessionStore = SecureAuthSessionStore(secureStorage);
  AuthSessionData? restoredSession;
  try {
    restoredSession = await authSessionStore.read();
  } on Object {
    // Start signed out if the platform keychain is unavailable or locked.
  }

  final expiryNotifier = SessionExpiryNotifier();
  final dio = createApiClient(
    tokenProvider: authSessionStore,
    sessionExpiryNotifier: expiryNotifier,
  );
  final AuthRepository authRepository = useMockData
      ? const MockAuthRepository()
      : RemoteAuthRepository(dio);
  final TheatreApiClient theatreClient = useMockData
      ? MockTheatreApiClient()
      : RemoteTheatreApiClient(dio);
  final TheatreRepository theatreRepository = useMockData
      ? MockTheatreRepository(theatreClient)
      : RemoteTheatreRepository(theatreClient, authSessionStore);
  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerSingleton<AuthSessionStore>(authSessionStore)
    ..registerSingleton<SessionExpiryNotifier>(
      expiryNotifier,
      dispose: (notifier) => notifier.dispose(),
    )
    ..registerSingleton<Dio>(dio, dispose: (client) => client.close())
    ..registerSingleton<AuthRepository>(authRepository)
    ..registerSingleton<TheatreApiClient>(theatreClient)
    ..registerSingleton<TheatreRepository>(theatreRepository)
    ..registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepository(getIt()),
    )
    ..registerLazySingleton<AppSettingsBloc>(
      () => AppSettingsBloc(getIt())..add(const AppSettingsStarted()),
    )
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        repository: getIt(),
        sessionStore: getIt(),
        restoredSession: restoredSession,
        sessionExpiryNotifier: getIt(),
      ),
    )
    ..registerLazySingleton<ProgrammeBloc>(() => ProgrammeBloc(getIt()))
    ..registerLazySingleton<CheckoutBloc>(() => CheckoutBloc(getIt()))
    ..registerLazySingleton<BookingsBloc>(() => BookingsBloc(getIt()));
}
