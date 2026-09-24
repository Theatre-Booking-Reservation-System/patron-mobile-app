import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';

class _MockRepository extends Mock implements TheatreRepository {}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  blocTest<ProgrammeBloc, ProgrammeState>(
    'loads productions and filters by language',
    build: () {
      when(repository.getProductions).thenAnswer((_) async => [_production]);
      return ProgrammeBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const ProgrammeRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProgrammeLanguageChanged(ProductionLanguage.tamil));
    },
    verify: (bloc) => expect(bloc.state.visibleProductions, isEmpty),
  );

  blocTest<ProgrammeBloc, ProgrammeState>(
    'filters productions by localized title search',
    build: () {
      when(
        repository.getProductions,
      ).thenAnswer((_) async => [_production, _secondProduction]);
      return ProgrammeBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const ProgrammeRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ProgrammeSearchChanged('වෙළෙන්දා'));
    },
    verify: (bloc) => expect(
      bloc.state.visibleProductions.map((item) => item.id),
      ['merchant'],
    ),
  );

  blocTest<ProgrammeBloc, ProgrammeState>(
    'filters productions by performance date and clears the date',
    build: () {
      when(
        repository.getProductions,
      ).thenAnswer((_) async => [_production, _secondProduction]);
      return ProgrammeBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const ProgrammeRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(ProgrammeDateChanged(DateTime(2026, 11, 5)));
    },
    verify: (bloc) => expect(
      bloc.state.visibleProductions.map((item) => item.id),
      ['merchant'],
    ),
  );
}

final _production = Production(
  id: 'test',
  title: const LocalizedText(en: 'Test', si: 'Test', ta: 'Test'),
  synopsis: const LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Drama',
  baseTicketCost: 1000,
  posterSeed: 0,
  performances: [
    Performance(
      id: 'performance',
      dateTime: DateTime(2026, 10),
      session: PerformanceSession.evening,
    ),
  ],
);

final _secondProduction = Production(
  id: 'merchant',
  title: const LocalizedText(en: 'The Merchant', si: 'වෙළෙන්දා', ta: 'வணிகன்'),
  synopsis: const LocalizedText(en: '', si: '', ta: ''),
  language: ProductionLanguage.english,
  genre: 'Classic',
  baseTicketCost: 1200,
  posterSeed: 1,
  performances: [
    Performance(
      id: 'merchant-performance',
      dateTime: DateTime(2026, 11, 5, 19, 30),
      session: PerformanceSession.evening,
    ),
  ],
);
