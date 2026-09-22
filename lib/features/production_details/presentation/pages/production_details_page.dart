import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class ProductionDetailsPage extends StatelessWidget {
  const ProductionDetailsPage({required this.production, super.key});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final language = switch (production.language) {
      ProductionLanguage.sinhala => context.l10n.sinhala,
      ProductionLanguage.tamil => context.l10n.tamil,
      ProductionLanguage.english => context.l10n.english,
    };
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 372,
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF162447),
            actions: [
              IconButton(
                tooltip: context.l10n.favourite,
                onPressed: () {},
                icon: const Icon(Icons.favorite_border_rounded),
              ),
              IconButton(
                tooltip: 'Share production',
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsetsDirectional.fromSTEB(56, 0, 96, 16),
              title: Text(
                production.title.resolve(locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
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
                    _DetailChip(icon: Icons.language_rounded, label: language),
                    _DetailChip(
                      icon: Icons.category_outlined,
                      label: production.genre,
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              AppFormatters.money(production.startingPrice),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
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
                            ?.copyWith(fontWeight: FontWeight.w800),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        Hero(
          tag: 'poster-${production.id}',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: ProductionPoster(
              title: production.title.resolve(locale),
              seed: production.posterSeed,
              height: 268,
            ),
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
    final session = performance.session == PerformanceSession.matinee
        ? context.l10n.matinee
        : context.l10n.evening;
    final unavailable = performance.isPoyaDay;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: unavailable
          ? scheme.surfaceContainerLow.withValues(alpha: .65)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: unavailable
            ? null
            : () => _openPerformance(context, production, performance),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 64,
                decoration: BoxDecoration(
                  color: unavailable
                      ? scheme.surfaceContainerHighest
                      : scheme.primaryContainer,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      DateFormat.d(locale).format(performance.dateTime),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
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
                      unavailable
                          ? context.l10n.poyaDay
                          : '${AppFormatters.time(performance.dateTime, locale)} · $session',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (performance.earlyAccessOnly) ...[
                      const SizedBox(height: 7),
                      const _StatusPill(
                        label: 'LOYALTY EARLY ACCESS',
                        color: AppTheme.gold,
                      ),
                    ] else if (!unavailable) ...[
                      const SizedBox(height: 7),
                      const _StatusPill(
                        label: 'AVAILABLE',
                        color: Color(0xFF7BC391),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                unavailable ? Icons.lock_outline : Icons.chevron_right_rounded,
                color: unavailable ? scheme.outline : scheme.primary,
              ),
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
        fontWeight: FontWeight.w800,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: loyalty
            ? const Color(0xFFE5F5EC)
            : guest
            ? scheme.secondaryContainer
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            loyalty
                ? Icons.verified_rounded
                : guest
                ? Icons.lock_person_outlined
                : Icons.workspace_premium_outlined,
            color: loyalty ? const Color(0xFF145A4A) : scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loyalty
                      ? 'Your early access is active'
                      : guest
                      ? 'Loyalty access requires an account'
                      : 'Book seven days earlier',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  loyalty
                      ? 'Eligible tickets automatically receive your 10% loyalty discount.'
                      : guest
                      ? 'Sign in or register, then link a loyalty card from your profile.'
                      : context.l10n.earlyAccess,
                ),
                if (!loyalty) ...[
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
  final authBloc = context.read<AuthBloc>();
  final auth = authBloc.state;
  if (auth.status != AuthStatus.authenticated) {
    if (auth.status == AuthStatus.guest) {
      authBloc.add(const AuthLogoutRequested());
      await authBloc.stream.firstWhere(
        (state) => state.status == AuthStatus.anonymous,
      );
    }
    if (context.mounted) context.push('/login');
    return;
  }
  if (performance.earlyAccessOnly && auth.patron?.isLoyaltyMember != true) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loyaltyOnly)));
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
