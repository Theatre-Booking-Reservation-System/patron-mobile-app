import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/language_selector.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';
import 'package:patron_mobile_app/features/programme/presentation/widgets/production_card.dart';

class ProgrammePage extends StatelessWidget {
  const ProgrammePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.shows),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSelector(compact: true),
          ),
        ],
      ),
      body: BlocBuilder<ProgrammeBloc, ProgrammeState>(
        builder: (context, state) {
          if (state.status == ProgrammeStatus.loading ||
              state.status == ProgrammeStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProgrammeStatus.failure) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => context.read<ProgrammeBloc>().add(
                  const ProgrammeRequested(),
                ),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProgrammeBloc>().add(const ProgrammeRequested());
              await context.read<ProgrammeBloc>().stream.firstWhere(
                (value) => value.status != ProgrammeStatus.loading,
              );
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<ProductionLanguage?>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: null,
                            label: Text(context.l10n.all),
                          ),
                          ButtonSegment(
                            value: ProductionLanguage.sinhala,
                            label: Text(context.l10n.sinhala),
                          ),
                          ButtonSegment(
                            value: ProductionLanguage.tamil,
                            label: Text(context.l10n.tamil),
                          ),
                          ButtonSegment(
                            value: ProductionLanguage.english,
                            label: Text(context.l10n.english),
                          ),
                        ],
                        selected: {state.language},
                        onSelectionChanged: (value) => context
                            .read<ProgrammeBloc>()
                            .add(ProgrammeLanguageChanged(value.single)),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      context.l10n.thisWeek,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (state.visibleProductions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(context.l10n.noProductions)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: state.visibleProductions.length,
                      itemBuilder: (context, index) => ProductionCard(
                        production: state.visibleProductions[index],
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
