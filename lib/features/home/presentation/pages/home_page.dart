import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/programme/presentation/bloc/programme_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final firstName = auth.patron?.name.split(' ').first;
    final greeting = firstName == null
        ? 'Welcome to Sapumal'
        : 'Hello, $firstName';

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          final bloc = context.read<ProgrammeBloc>()
            ..add(const ProgrammeRequested());
          await bloc.stream.firstWhere(
            (state) => state.status != ProgrammeStatus.loading,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              pinned: true,
              expandedHeight: 176,
              backgroundColor: Theme.of(context).colorScheme.primary,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              title: Text(greeting),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: const Badge(
                    smallSize: 7,
                    child: Icon(Icons.notifications_none_rounded),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _DashboardHeader(isGuest: auth.isGuest),
              ),
            ),
            BlocBuilder<ProgrammeBloc, ProgrammeState>(
              builder: (context, state) {
                if (state.status == ProgrammeStatus.initial ||
                    state.status == ProgrammeStatus.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                if (state.status == ProgrammeStatus.failure) {
                  return SliverFillRemaining(
                    child: _DashboardError(
                      onRetry: () => context.read<ProgrammeBloc>().add(
                        const ProgrammeRequested(),
                      ),
                    ),
                  );
                }
                final productions = state.productions;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList.list(
                    children: [
                      if (productions.isNotEmpty)
                        _FeaturedProduction(production: productions.first),
                      const SizedBox(height: 28),
                      _SectionHeading(
                        title: 'Quick actions',
                        actionLabel: 'Browse all',
                        onAction: () => context.go('/shows'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.theater_comedy_outlined,
                              label: 'Browse shows',
                              onTap: () => context.go('/shows'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.confirmation_number_outlined,
                              label: auth.isGuest
                                  ? 'Booking access'
                                  : 'My bookings',
                              onTap: () => context.go('/bookings'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.loyalty_outlined,
                              label: 'Loyalty',
                              onTap: () => context.go('/profile'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _AccessCard(auth: auth),
                      const SizedBox(height: 28),
                      _SectionHeading(
                        title: 'Coming up',
                        actionLabel: 'See programme',
                        onAction: () => context.go('/shows'),
                      ),
                      const SizedBox(height: 12),
                      if (productions.isEmpty)
                        const _EmptyProgramme()
                      else
                        SizedBox(
                          height: 224,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: productions.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) =>
                                _UpcomingCard(production: productions[index]),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 80, 16, 18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary,
          const Color(0xFF162447),
        ],
      ),
    ),
    child: Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        isGuest
            ? 'Browse freely. Sign in when you are ready to book.'
            : 'Your next unforgettable performance starts here.',
        style: const TextStyle(color: Colors.white70, fontSize: 15),
      ),
    ),
  );
}

class _FeaturedProduction extends StatelessWidget {
  const _FeaturedProduction({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final performance = production.performances.first;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162447), Color(0xFF351019)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -46,
            child: CircleAvatar(
              radius: 108,
              backgroundColor: AppTheme.gold.withValues(alpha: .12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 116,
                  child: Hero(
                    tag: 'poster-${production.id}',
                    child: ProductionPoster(
                      title: production.title.resolve(locale),
                      seed: production.posterSeed,
                      height: 172,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEXT ON STAGE',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        production.title.resolve(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${AppFormatters.date(performance.dateTime, locale)} · '
                        '${AppFormatters.time(performance.dateTime, locale)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: AppTheme.gold,
                          foregroundColor: const Color(0xFF2D2104),
                        ),
                        onPressed: () =>
                            context.push('/production', extra: production),
                        child: const Text('Book Tickets'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final loyalty = auth.patron?.isLoyaltyMember == true;
    final guest = auth.isGuest;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: guest
            ? scheme.secondaryContainer
            : loyalty
            ? const Color(0xFFE5F5EC)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: guest
                ? scheme.secondary
                : loyalty
                ? const Color(0xFF145A4A)
                : scheme.primary,
            foregroundColor: Colors.white,
            child: Icon(
              guest
                  ? Icons.lock_person_outlined
                  : loyalty
                  ? Icons.workspace_premium_outlined
                  : Icons.loyalty_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest
                      ? 'Ready when you are'
                      : loyalty
                      ? 'Loyalty access is active'
                      : 'Unlock early access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  guest
                      ? 'Create an account or sign in before selecting seats.'
                      : loyalty
                      ? 'Book seven days early and receive 10% off eligible tickets.'
                      : 'Link a loyalty card to book seven days before general sale.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => context.go('/profile'),
                  child: Text(
                    guest ? 'View account options' : 'Manage loyalty',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 9),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final performance = production.performances.first;
    return SizedBox(
      width: 164,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/production', extra: production),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductionPoster(
                title: production.title.resolve(locale),
                seed: production.posterSeed,
                height: 128,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      production.title.resolve(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.date(performance.dateTime, locale),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      TextButton(onPressed: onAction, child: Text(actionLabel)),
    ],
  );
}

class _EmptyProgramme extends StatelessWidget {
  const _EmptyProgramme();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Text('New performances will appear here when announced.'),
  );
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 46,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load the programme',
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
