import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.productionDetails)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ProductionPoster(
            title: production.title.resolve(locale),
            seed: production.posterSeed,
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  production.title.resolve(locale),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${production.genre} • ${context.l10n.venue}'),
                const SizedBox(height: 16),
                Text(
                  production.synopsis.resolve(locale),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                Text(
                  context.l10n.selectPerformance,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                for (final performance in production.performances)
                  _PerformanceTile(
                    production: production,
                    performance: performance,
                  ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined),
                        const SizedBox(width: 10),
                        Expanded(child: Text(context.l10n.earlyAccess)),
                      ],
                    ),
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
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: Icon(
          performance.isPoyaDay ? Icons.event_busy : Icons.event_available,
        ),
        title: Text(AppFormatters.date(performance.dateTime, locale)),
        subtitle: Text(
          performance.isPoyaDay
              ? context.l10n.poyaDay
              : '${AppFormatters.time(performance.dateTime, locale)} • $session',
        ),
        trailing: performance.isPoyaDay
            ? null
            : const Icon(Icons.chevron_right),
        enabled: !performance.isPoyaDay,
        onTap: performance.isPoyaDay
            ? null
            : () async {
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
                if (performance.earlyAccessOnly &&
                    auth.patron?.isLoyaltyMember != true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.loyaltyOnly)),
                  );
                  return;
                }
                context.push(
                  '/seats',
                  extra: (production: production, performance: performance),
                );
              },
      ),
    );
  }
}
