import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';
import 'package:patron_mobile_app/features/programme/presentation/widgets/production_card.dart';

class ProgrammePage extends StatefulWidget {
  const ProgrammePage({super.key});

  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(DateTime? currentDate) async {
    if (currentDate != null) {
      context.read<ProgrammeBloc>().add(const ProgrammeDateChanged(null));
      return;
    }
    final now = DateTime.now();
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      var selected = now;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => Container(
          height: 350,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        context.read<ProgrammeBloc>().add(
                          ProgrammeDateChanged(selected),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: now,
                    minimumDate: now.subtract(const Duration(days: 1)),
                    maximumDate: DateTime(now.year + 2),
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
      helpText: 'Filter by performance date',
    );
    if (selected != null && mounted) {
      context.read<ProgrammeBloc>().add(ProgrammeDateChanged(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProgrammeBloc, ProgrammeState>(
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              final bloc = context.read<ProgrammeBloc>()
                ..add(const ProgrammeRequested());
              await bloc.stream.firstWhere(
                (value) => value.status != ProgrammeStatus.loading,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar.large(
                  pinned: true,
                  title: Text(context.l10n.shows),
                  actions: [
                    IconButton(
                      tooltip: 'Calendar',
                      onPressed: () => _selectDate(state.date),
                      icon: Badge(
                        isLabelVisible: state.date != null,
                        smallSize: 7,
                        child: const Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Search productions',
                      leading: const Icon(Icons.search_rounded),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProgrammeBloc>().add(
                                const ProgrammeSearchChanged(''),
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                      ],
                      onChanged: (query) {
                        context.read<ProgrammeBloc>().add(
                          ProgrammeSearchChanged(query),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _LanguageFilter(
                          label: context.l10n.all,
                          selected: state.language == null,
                          onSelected: () => context.read<ProgrammeBloc>().add(
                            const ProgrammeLanguageChanged(null),
                          ),
                        ),
                        _LanguageFilter(
                          label: context.l10n.sinhala,
                          selected:
                              state.language == ProductionLanguage.sinhala,
                          onSelected: () => context.read<ProgrammeBloc>().add(
                            const ProgrammeLanguageChanged(
                              ProductionLanguage.sinhala,
                            ),
                          ),
                        ),
                        _LanguageFilter(
                          label: context.l10n.tamil,
                          selected: state.language == ProductionLanguage.tamil,
                          onSelected: () => context.read<ProgrammeBloc>().add(
                            const ProgrammeLanguageChanged(
                              ProductionLanguage.tamil,
                            ),
                          ),
                        ),
                        _LanguageFilter(
                          label: context.l10n.english,
                          selected:
                              state.language == ProductionLanguage.english,
                          onSelected: () => context.read<ProgrammeBloc>().add(
                            const ProgrammeLanguageChanged(
                              ProductionLanguage.english,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        FilterChip(
                          avatar: const Icon(Icons.event_outlined, size: 18),
                          label: Text(
                            state.date == null
                                ? 'Date'
                                : DateFormat.MMMd().format(state.date!),
                          ),
                          selected: state.date != null,
                          onSelected: (_) => _selectDate(state.date),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == ProgrammeStatus.loading ||
                    state.status == ProgrammeStatus.initial)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 28),
                    sliver: _ProgrammeSkeleton(),
                  )
                else if (state.status == ProgrammeStatus.failure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ProgrammeError(
                      onRetry: () => context.read<ProgrammeBloc>().add(
                        const ProgrammeRequested(),
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.query.trim().isEmpty && state.date == null
                                  ? 'Upcoming productions'
                                  : 'Matching productions',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(
                            '${state.visibleProductions.length} found',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.visibleProductions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyProgramme(
                        onClear: () {
                          _searchController.clear();
                          context.read<ProgrammeBloc>()
                            ..add(const ProgrammeSearchChanged(''))
                            ..add(const ProgrammeLanguageChanged(null))
                            ..add(const ProgrammeDateChanged(null));
                          setState(() {});
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: state.visibleProductions.length,
                        itemBuilder: (context, index) => ProductionCard(
                          production: state.visibleProductions[index],
                        ),
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageFilter extends StatelessWidget {
  const _LanguageFilter({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    ),
  );
}

class _ProgrammeSkeleton extends StatelessWidget {
  const _ProgrammeSkeleton();

  @override
  Widget build(BuildContext context) => SliverList.separated(
    itemCount: 3,
    separatorBuilder: (_, _) => const SizedBox(height: 14),
    itemBuilder: (_, _) => Container(
      height: 184,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}

class _ProgrammeError extends StatelessWidget {
  const _ProgrammeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48),
          const SizedBox(height: 16),
          Text(
            'We could not load the programme',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Check your connection and try again.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyProgramme extends StatelessWidget {
  const _EmptyProgramme({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No productions match these filters',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try another title, language, or performance date.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          TextButton(onPressed: onClear, child: const Text('Clear filters')),
        ],
      ),
    ),
  );
}
