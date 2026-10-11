import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/features/auth/data/auth_session_store.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:patron_mobile_app/l10n/app_localizations.dart';

class _MockRepository extends Mock implements TheatreRepository {}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  test('replaces a cancelled booking in the list', () async {
    when(() => repository.getBookings()).thenAnswer((_) async => [_confirmed]);
    when(
      () => repository.cancelBooking(_confirmed),
    ).thenAnswer((_) async => _cancelled);
    final bloc = BookingsBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const BookingsRequested());
    await bloc.stream.firstWhere(
      (state) =>
          state.status == BookingsStatus.success && state.bookings.isNotEmpty,
    );

    bloc.add(BookingCancellationRequested(_confirmed));
    await bloc.stream.firstWhere(
      (state) =>
          state.status == BookingsStatus.success &&
          state.bookings.single.status == BookingStatus.cancelledPatron,
    );

    expect(bloc.state.bookings.single.status, BookingStatus.cancelledPatron);
    expect(bloc.state.lookupResult?.status, BookingStatus.cancelledPatron);
  });

  testWidgets('shows Cancelled on the bookings screen', (tester) async {
    when(() => repository.getBookings()).thenAnswer((_) async => [_cancelled]);
    final bookings = BookingsBloc(repository);
    final auth = AuthBloc(
      restoredSession: const AuthSessionData(
        userId: 'patron-id',
        name: 'Nimal Perera',
        email: 'nimal@example.com',
      ),
    );
    addTearDown(bookings.close);
    addTearDown(auth.close);
    bookings.add(const BookingsRequested());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: auth),
            BlocProvider.value(value: bookings),
          ],
          child: const BookingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Sanda Katha'), findsOneWidget);
  });
}

final _performance = Performance(
  id: 'performance-id',
  dateTime: DateTime(2026, 12, 1, 18, 30),
  session: PerformanceSession.evening,
);

final _production = Production(
  id: 'production-id',
  title: LocalizedText(en: 'Sanda Katha', si: '', ta: ''),
  synopsis: LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Drama',
  baseTicketCost: 1000,
  performances: [_performance],
);

final _confirmed = Booking(
  id: 'booking-id',
  reference: 'BK-100',
  production: _production,
  performance: _performance,
  seats: const [],
  total: 4000,
  status: BookingStatus.confirmed,
  paymentStatus: PaymentStatus.paid,
  createdAt: DateTime(2026, 10, 1),
  patronEmail: 'nimal@example.com',
  isFlagged: false,
);

final _cancelled = Booking(
  id: 'booking-id',
  reference: 'BK-100',
  production: _production,
  performance: _performance,
  seats: const [],
  total: 4000,
  status: BookingStatus.cancelledPatron,
  paymentStatus: PaymentStatus.refunded,
  createdAt: DateTime(2026, 10, 1),
  patronEmail: 'nimal@example.com',
  isFlagged: false,
);
