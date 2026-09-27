import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/core/network/api_exception.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/seat_selection/presentation/bloc/seat_selection_bloc.dart';

class _MockRepository extends Mock implements TheatreRepository {}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  test('selects the first section that actually contains seats', () async {
    when(
      () => repository.getSeats(_production, _performance),
    ).thenAnswer((_) async => const [_circleSeat]);
    final bloc = SeatSelectionBloc(repository);
    addTearDown(bloc.close);

    bloc.add(SeatMapRequested(_production, _performance));
    await bloc.stream.firstWhere(
      (state) => state.status == SeatSelectionStatus.success,
    );

    expect(bloc.state.section, SeatSection.circle);
    expect(bloc.state.visibleSeats, const [_circleSeat]);
  });

  test(
    'retains an empty successful inventory for explicit UI handling',
    () async {
      when(
        () => repository.getSeats(_production, _performance),
      ).thenAnswer((_) async => const []);
      final bloc = SeatSelectionBloc(repository);
      addTearDown(bloc.close);

      bloc.add(SeatMapRequested(_production, _performance));
      await bloc.stream.firstWhere(
        (state) => state.status == SeatSelectionStatus.success,
      );

      expect(bloc.state.seats, isEmpty);
      expect(bloc.state.failure, isNull);
    },
  );

  test('preserves a useful failure reason from the Seat Service', () async {
    when(
      () => repository.getSeats(_production, _performance),
    ).thenThrow(const ApiException(ApiFailureType.notFound));
    final bloc = SeatSelectionBloc(repository);
    addTearDown(bloc.close);

    bloc.add(SeatMapRequested(_production, _performance));
    await bloc.stream.firstWhere(
      (state) => state.status == SeatSelectionStatus.failure,
    );

    expect(bloc.state.failure, SeatSelectionFailure.notFound);
  });
}

final _performance = Performance(
  id: 'performance-id',
  dateTime: DateTime(2026, 10, 9, 18, 30),
  session: PerformanceSession.evening,
);

final _production = Production(
  id: 'production-id',
  title: LocalizedText(en: 'Production', si: '', ta: ''),
  synopsis: LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Drama',
  baseTicketCost: 1000,
  performances: [_performance],
);

const _circleSeat = Seat(
  id: 'seat-id',
  section: SeatSection.circle,
  row: 'A',
  number: 1,
  zoneName: 'Centre',
  multiplierPercent: 120,
  netPrice: 1200,
  status: SeatStatus.available,
);
