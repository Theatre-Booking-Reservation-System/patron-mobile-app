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
            SliverAppBar(
              pinned: true,
              toolbarHeight: 82,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: .96),
              surfaceTintColor: Colors.transparent,
              title: _DashboardIdentity(greeting: greeting, auth: auth),
              actions: [
                _NotificationButton(onPressed: () {}),
                const SizedBox(width: 16),
              ],
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 126),
                  sliver: SliverList.list(
                    children: [
                      if (productions.isNotEmpty)
                        _FeaturedProduction(production: productions.first),
                      const SizedBox(height: 30),
                      _SectionHeading(
                        eyebrow: 'SHORTCUTS',
                        title: 'Quick access',
                        actionLabel: 'Explore all',
                        onAction: () => context.go('/shows'),
                      ),
                      const SizedBox(height: 14),
                      _QuickAccessDock(
                        actions: [
                          _QuickActionData(
                            icon: Icons.theater_comedy_outlined,
                            label: 'Browse shows',
                            onTap: () => context.go('/shows'),
                          ),
                          _QuickActionData(
                            icon: Icons.confirmation_number_outlined,
                            label: auth.isGuest
                                ? 'Booking access'
                                : 'My bookings',
                            onTap: () => context.go('/bookings'),
                          ),
                          _QuickActionData(
                            icon: Icons.person_outline_rounded,
                            label: auth.isGuest ? 'Account' : 'My profile',
                            onTap: () => context.go('/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _SectionHeading(
                        eyebrow: 'CURATED FOR YOU',
                        title: 'Coming up',
                        actionLabel: 'See programme',
                        onAction: () => context.go('/shows'),
                      ),
                      const SizedBox(height: 12),
                      if (productions.isEmpty)
                        const _EmptyProgramme()
                      else
                        SizedBox(
                          height: 250,
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

class _DashboardIdentity extends StatelessWidget {
  const _DashboardIdentity({required this.greeting, required this.auth});

  final String greeting;
  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final loyaltyMember =
        auth.status == AuthStatus.authenticated &&
        auth.patron?.isLoyaltyMember == true;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                auth.isGuest ? 'EXPLORE SAPUMAL' : 'WELCOME BACK',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  letterSpacing: 1.25,
                ),
              ),
            ),
            if (loyaltyMember) ...[
              const SizedBox(width: 9),
              const _LoyaltyMemberBadge(),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -.35),
        ),
      ],
    );
  }
}

class _LoyaltyMemberBadge extends StatelessWidget {
  const _LoyaltyMemberBadge();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Sapumal loyalty member',
    child: Container(
      key: const Key('loyaltyMemberBadge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFE29A)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE7A7), Color(0xFFD9A62E)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: .22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 13,
            color: Color(0xFF3C2900),
          ),
          SizedBox(width: 4),
          Text(
            'Loyalty member',
            style: TextStyle(
              color: Color(0xFF3C2900),
              fontSize: 10,
              height: 1,
              letterSpacing: .1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: 'Notifications',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
      ),
      icon: const Badge(
        smallSize: 7,
        child: Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}

class _FeaturedProduction extends StatelessWidget {
  const _FeaturedProduction({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final performance = production.performances.first;
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: () => context.push('/production', extra: production),
        child: Container(
          height: 306,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111936), Color(0xFF360E17)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1020).withValues(alpha: .22),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 184,
                child: Opacity(
                  opacity: .94,
                  child: Hero(
                    tag: 'poster-${production.id}',
                    child: ProductionPoster(
                      title: production.title.resolve(locale),
                      seed: production.posterSeed,
                      height: 306,
                      borderRadius: 0,
                      showLabel: false,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF12172F),
                      Color(0xF212172F),
                      Color(0xA812172F),
                      Color(0x0012172F),
                    ],
                    stops: [0, .47, .7, 1],
                  ),
                ),
              ),
              Positioned(
                right: -38,
                top: -48,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.gold.withValues(alpha: .13),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: .09),
                        blurRadius: 42,
                        spreadRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: SizedBox(
                  width: 238,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .13),
                              ),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            production.genre.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .9,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        production.title.resolve(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          height: 1.02,
                          letterSpacing: -.75,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 7,
                        children: [
                          _HeroMetadata(
                            icon: Icons.calendar_today_rounded,
                            label: AppFormatters.date(
                              performance.dateTime,
                              locale,
                            ),
                          ),
                          _HeroMetadata(
                            icon: Icons.schedule_rounded,
                            label: AppFormatters.time(
                              performance.dateTime,
                              locale,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'From ${AppFormatters.money(production.startingPrice)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 172,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: AppTheme.gold,
                            foregroundColor: const Color(0xFF2D2104),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () =>
                              context.push('/production', extra: production),
                          icon: const Icon(
                            Icons.local_activity_rounded,
                            size: 18,
                          ),
                          label: const Text('Book Tickets'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetadata extends StatelessWidget {
  const _HeroMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white70, size: 13),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickAccessDock extends StatelessWidget {
  const _QuickAccessDock({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 94,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            Expanded(child: _QuickAccessItem(action: actions[index])),
            if (index != actions.length - 1)
              Container(
                width: 1,
                height: 42,
                color: scheme.outlineVariant.withValues(alpha: .65),
              ),
          ],
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({required this.action});

  final _QuickActionData action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(action.icon, size: 21, color: scheme.primary),
            ),
            const SizedBox(height: 7),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final performance = production.performances.first;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 184,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .48)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/production', extra: production),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductionPoster(
                title: production.title.resolve(locale),
                seed: production.posterSeed,
                height: 158,
                borderRadius: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      production.title.resolve(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${AppFormatters.date(performance.dateTime, locale)} · '
                            '${AppFormatters.time(performance.dateTime, locale)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
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
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String eyebrow;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 23,
                  letterSpacing: -.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _EmptyProgramme extends StatelessWidget {
  const _EmptyProgramme();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Row(
      children: [
        Icon(Icons.event_available_outlined),
        SizedBox(width: 12),
        Expanded(
          child: Text('New performances will appear here when announced.'),
        ),
      ],
    ),
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
