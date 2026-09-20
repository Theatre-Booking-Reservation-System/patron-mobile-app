import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/app/dependency_injection/configure_dependencies.dart';
import 'package:patron_mobile_app/app/router/app_router.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';
import 'package:patron_mobile_app/l10n/app_localizations.dart';

class SapumalApp extends StatefulWidget {
  const SapumalApp({super.key});

  @override
  State<SapumalApp> createState() => _SapumalAppState();
}

class _SapumalAppState extends State<SapumalApp> {
  late final router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AppSettingsBloc>()),
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<ProgrammeBloc>()),
        BlocProvider.value(value: getIt<CheckoutBloc>()),
        BlocProvider.value(value: getIt<BookingsBloc>()),
      ],
      child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
        builder: (context, settings) => MaterialApp.router(
          title: 'Sapumal Theatre',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeMode: settings.themeMode,
          theme: AppTheme.build(settings.palette, Brightness.light),
          darkTheme: AppTheme.build(settings.palette, Brightness.dark),
        ),
      ),
    );
  }
}
