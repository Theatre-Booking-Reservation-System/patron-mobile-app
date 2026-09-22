import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/booking/domain/repositories/theatre_repository.dart';

sealed class ProgrammeEvent extends Equatable {
  const ProgrammeEvent();
  @override
  List<Object?> get props => const [];
}

final class ProgrammeRequested extends ProgrammeEvent {
  const ProgrammeRequested();
}

final class ProgrammeLanguageChanged extends ProgrammeEvent {
  const ProgrammeLanguageChanged(this.language);
  final ProductionLanguage? language;
  @override
  List<Object?> get props => [language];
}

final class ProgrammeSearchChanged extends ProgrammeEvent {
  const ProgrammeSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class ProgrammeDateChanged extends ProgrammeEvent {
  const ProgrammeDateChanged(this.date);
  final DateTime? date;
  @override
  List<Object?> get props => [date];
}

enum ProgrammeStatus { initial, loading, success, failure }

class ProgrammeState extends Equatable {
  const ProgrammeState({
    this.status = ProgrammeStatus.initial,
    this.productions = const [],
    this.language,
    this.query = '',
    this.date,
  });

  final ProgrammeStatus status;
  final List<Production> productions;
  final ProductionLanguage? language;
  final String query;
  final DateTime? date;

  List<Production> get visibleProductions {
    final normalizedQuery = query.trim().toLowerCase();
    return productions
        .where((production) {
          final matchesLanguage =
              language == null || production.language == language;
          final matchesSearch =
              normalizedQuery.isEmpty ||
              production.title.en.toLowerCase().contains(normalizedQuery) ||
              production.title.si.toLowerCase().contains(normalizedQuery) ||
              production.title.ta.toLowerCase().contains(normalizedQuery);
          final matchesDate =
              date == null ||
              production.performances.any(
                (performance) => _isSameDay(performance.dateTime, date!),
              );
          return matchesLanguage && matchesSearch && matchesDate;
        })
        .toList(growable: false);
  }

  ProgrammeState copyWith({
    ProgrammeStatus? status,
    List<Production>? productions,
    ProductionLanguage? language,
    bool clearLanguage = false,
    String? query,
    DateTime? date,
    bool clearDate = false,
  }) => ProgrammeState(
    status: status ?? this.status,
    productions: productions ?? this.productions,
    language: clearLanguage ? null : language ?? this.language,
    query: query ?? this.query,
    date: clearDate ? null : date ?? this.date,
  );

  @override
  List<Object?> get props => [status, productions, language, query, date];
}

class ProgrammeBloc extends Bloc<ProgrammeEvent, ProgrammeState> {
  ProgrammeBloc(this._repository) : super(const ProgrammeState()) {
    on<ProgrammeRequested>((event, emit) async {
      emit(state.copyWith(status: ProgrammeStatus.loading));
      try {
        final productions = await _repository.getProductions();
        productions.sort(
          (a, b) => a.performances.first.dateTime.compareTo(
            b.performances.first.dateTime,
          ),
        );
        emit(
          state.copyWith(
            status: ProgrammeStatus.success,
            productions: productions,
          ),
        );
      } on Object {
        emit(state.copyWith(status: ProgrammeStatus.failure));
      }
    });
    on<ProgrammeLanguageChanged>((event, emit) {
      emit(
        event.language == null
            ? state.copyWith(clearLanguage: true)
            : state.copyWith(language: event.language),
      );
    });
    on<ProgrammeSearchChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<ProgrammeDateChanged>((event, emit) {
      emit(
        event.date == null
            ? state.copyWith(clearDate: true)
            : state.copyWith(date: event.date),
      );
    });
  }

  final TheatreRepository _repository;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
