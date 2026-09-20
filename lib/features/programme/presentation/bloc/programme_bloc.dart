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

enum ProgrammeStatus { initial, loading, success, failure }

class ProgrammeState extends Equatable {
  const ProgrammeState({
    this.status = ProgrammeStatus.initial,
    this.productions = const [],
    this.language,
  });

  final ProgrammeStatus status;
  final List<Production> productions;
  final ProductionLanguage? language;

  List<Production> get visibleProductions => language == null
      ? productions
      : productions.where((item) => item.language == language).toList();

  ProgrammeState copyWith({
    ProgrammeStatus? status,
    List<Production>? productions,
    ProductionLanguage? language,
    bool clearLanguage = false,
  }) => ProgrammeState(
    status: status ?? this.status,
    productions: productions ?? this.productions,
    language: clearLanguage ? null : language ?? this.language,
  );

  @override
  List<Object?> get props => [status, productions, language];
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
  }

  final TheatreRepository _repository;
}
