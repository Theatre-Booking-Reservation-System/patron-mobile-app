import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/production_poster_hero.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/production_details/domain/contact_directory.dart';
import 'package:patron_mobile_app/features/production_details/presentation/share_production_sheet.dart';

class ProductionDetailsPage extends StatefulWidget {
  const ProductionDetailsPage({
    required this.production,
    this.contactDirectory,
    super.key,
  });

  final Production production;
  final ContactDirectory? contactDirectory;

  @override
  State<ProductionDetailsPage> createState() => _ProductionDetailsPageState();
}

class _ProductionDetailsPageState extends State<ProductionDetailsPage> {
  final _detailsBoundaryKey = GlobalKey();

  String _castRole(String role) {
    final words = role.trim().split(RegExp(r'\s+'));
    return [
      for (final word in words)
        if (word.isNotEmpty)
          '${word[0].toUpperCase()}${word.substring(1)}',
    ].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final production = widget.production;
    final locale = Localizations.localeOf(context).languageCode;
    final language = switch (production.language) {
      ProductionLanguage.sinhala => context.l10n.sinhala,
      ProductionLanguage.tamil => context.l10n.tamil,
      ProductionLanguage.english => context.l10n.english,
    };
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            key: _detailsBoundaryKey,
            child: KeyedSubtree(
              key: const Key('productionDetailsCapture'),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    expandedHeight: 372,
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF162447),
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: const EdgeInsetsDirectional.fromSTEB(
                        56,
                        0,
                        96,
                        16,
                      ),
                      title: Text(
                        production.title.resolve(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      background: _ProductionHero(
                        production: production,
                        locale: locale,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    sliver: SliverList.list(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DetailChip(
                              icon: Icons.language_rounded,
                              label: language,
                            ),
                            _DetailChip(
                              icon: Icons.category_outlined,
                              label: production.genre,
                            ),
                            if (production.durationLabel case final duration?)
                              _DetailChip(
                                icon: Icons.schedule,
                                label: duration,
                              ),
                            _DetailChip(
                              icon: Icons.location_on_outlined,
                              label: 'Colombo 07',
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'About this production',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          production.synopsis.resolve(locale),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (production.castCrew.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Cast & crew',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          for (final member in production.castCrew)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _castRole(member.role),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      member.name,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tickets from',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    Text(
                                      AppFormatters.money(
                                        production.startingPrice,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Flexible(
                                child: Text(
                                  'VAT-inclusive total shown at checkout',
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.selectPerformance,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${production.performances.length} dates',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose an available date to view the live seat map.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 14),
                        for (final performance in production.performances)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PerformanceTile(
                              production: production,
                              performance: performance,
                            ),
                          ),
                        const SizedBox(height: 12),
                        _EarlyAccessCard(production: production),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                children: [
                  BackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l10n.favourite,
                    onPressed: () {},
                    color: Colors.white,
                    icon: const Icon(Icons.favorite_border_rounded),
                  ),
                  IconButton(
                    key: const Key('shareProductionButton'),
                    tooltip: context.l10n.shareProduction,
                    color: Colors.white,
                    onPressed: () => shareProductionWithContact(
                      context,
                      production: production,
                      directory:
                          widget.contactDirectory ??
                          GetIt.instance<ContactDirectory>(),
                      detailsBoundaryKey: _detailsBoundaryKey,
                    ),
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionHero extends StatelessWidget {
  const _ProductionHero({required this.production, required this.locale});

  final Production production;
  final String locale;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(72, 72, 72, 54),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF162447), Color(0xFF4C0A10)],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: -110,
          top: -90,
          child: CircleAvatar(
            radius: 150,
            backgroundColor: AppTheme.gold.withValues(alpha: .11),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: ProductionPosterHero(
            production: production,
            locale: locale,
            height: 268,
          ),
        ),
      ],
    ),
  );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _PerformanceTile extends StatelessWidget {
  const _PerformanceTile({required this.production, required this.performance});

  final Production production;
  final Performance performance;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final released = production.isReleasedAt(now);
    final earlyAccess = production.isLoyaltyEarlyAccessAt(now);
    final session = performance.session == PerformanceSession.matinee
        ? context.l10n.matinee
        : context.l10n.evening;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openPerformance(context, production, performance),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.MMM(
                        locale,
                      ).format(performance.dateTime).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat.d(locale).format(performance.dateTime),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.date(performance.dateTime, locale),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.time(performance.dateTime, locale)} · $session',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (earlyAccess) ...[
                      const SizedBox(height: 7),
                      const _StatusPill(
                        label: 'LOYALTY EARLY ACCESS',
                        color: AppTheme.gold,
                      ),
                    ] else if (released) ...[
                      const SizedBox(height: 7),
                      const _StatusPill(
                        label: 'AVAILABLE',
                        color: Color(0xFF7BC391),
                      ),
                    ] else if (production.releaseDate != null) ...[
                      const SizedBox(height: 7),
                      _StatusPill(
                        label:
                            'BOOKING OPENS ${DateFormat.MMMd(locale).format(production.releaseDate!).toUpperCase()}',
                        color: scheme.outline,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color.computeLuminance() > .55 ? const Color(0xFF3A2A00) : color,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _EarlyAccessCard extends StatelessWidget {
  const _EarlyAccessCard({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final loyalty = auth.patron?.isLoyaltyMember == true;
    final guest = auth.isGuest;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final released = production.isReleasedAt(now);
    final earlyAccess = production.isLoyaltyEarlyAccessAt(now);
    final earlyAccessDate = production.loyaltyAccessDate;
    final releaseDate = production.releaseDate;
    final title = released
        ? 'Booking is open'
        : earlyAccess
        ? loyalty
              ? 'Your early access is active'
              : 'Loyalty early access is active'
        : loyalty && earlyAccessDate != null
        ? 'Your early access opens ${DateFormat.MMMd(locale).format(earlyAccessDate)}'
        : releaseDate == null
        ? 'Booking is open'
        : 'Booking opens ${DateFormat.MMMd(locale).format(releaseDate)}';
    final description = released
        ? 'All performances in this production are available to logged-in patrons.'
        : earlyAccess
        ? loyalty
              ? 'Choose any performance. Your 10% loyalty discount is applied automatically.'
              : context.l10n.earlyAccess
        : 'Every performance in this production follows this same release schedule.';
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Light green is only readable with dark text. Dark mode uses a dark
    // green surface and a light foreground for the same card.
    final loyaltyAccent = dark
        ? const Color(0xFFD7F5E4)
        : const Color(0xFF145A4A);
    final background = loyalty
        ? (dark ? const Color(0xFF1A3D32) : const Color(0xFFE5F5EC))
        : guest
        ? scheme.secondaryContainer
        : scheme.surfaceContainerLow;
    final contentColor = loyalty && dark ? loyaltyAccent : null;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            released
                ? Icons.event_available_outlined
                : loyalty
                ? Icons.verified_rounded
                : guest
                ? Icons.lock_person_outlined
                : Icons.workspace_premium_outlined,
            color: loyalty ? loyaltyAccent : scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: contentColor),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: contentColor == null
                      ? null
                      : textTheme.bodyMedium?.copyWith(color: contentColor),
                ),
                if (!released && !loyalty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => context.go('/profile'),
                    child: const Text('View loyalty options'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openPerformance(
  BuildContext context,
  Production production,
  Performance performance,
) async {
  final auth = context.read<AuthBloc>().state;
  final loyalty = auth.patron?.isLoyaltyMember == true;
  if (!production.canBookAt(DateTime.now(), isLoyaltyMember: loyalty)) {
    if (context.mounted) {
      final isEarlyAccess = production.isLoyaltyEarlyAccessAt(DateTime.now());
      final releaseDate = production.releaseDate;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEarlyAccess
                ? context.l10n.loyaltyOnly
                : releaseDate == null
                ? 'Booking is not available yet.'
                : 'Booking opens on ${DateFormat.yMMMd().format(releaseDate)}.',
          ),
        ),
      );
    }
    return;
  }
  if (context.mounted) {
    context.push(
      '/seats',
      extra: (production: production, performance: performance),
    );
  }
}
