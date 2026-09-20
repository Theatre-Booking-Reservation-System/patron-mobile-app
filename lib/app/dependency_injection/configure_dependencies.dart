import 'package:get_it/get_it.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/mock_theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/datasources/theatre_api_client.dart';
import 'package:patron_mobile_app/features/booking/data/repositories/mock_theatre_repository.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AppSettingsBloc>()) return;
  final preferences = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(preferences)
    ..registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepository(getIt()),
    )
    ..registerLazySingleton<TheatreApiClient>(MockTheatreApiClient.new)
    ..registerLazySingleton<TheatreRepository>(
      () => MockTheatreRepository(getIt()),
    )
    ..registerLazySingleton<AppSettingsBloc>(
      () => AppSettingsBloc(getIt())..add(const AppSettingsStarted()),
    )
    ..registerLazySingleton<AuthBloc>(AuthBloc.new)
    ..registerLazySingleton<ProgrammeBloc>(
      () => ProgrammeBloc(getIt())..add(const ProgrammeRequested()),
    )
    ..registerLazySingleton<CheckoutBloc>(() => CheckoutBloc(getIt()))
    ..registerLazySingleton<BookingsBloc>(
      () => BookingsBloc(getIt())..add(const BookingsRequested()),
    );
}
