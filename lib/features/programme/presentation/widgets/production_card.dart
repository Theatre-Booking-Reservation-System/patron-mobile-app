import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/production_poster_hero.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class ProductionCard extends StatelessWidget {
  const ProductionCard({required this.production, super.key});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final performance = production.performances.first;
    final language = switch (production.language) {
      ProductionLanguage.sinhala => context.l10n.sinhala,
      ProductionLanguage.tamil => context.l10n.tamil,
      ProductionLanguage.english => context.l10n.english,
    };
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => context.push('/production', extra: production),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: ProductionPosterHero(
                  production: production,
                  locale: locale,
                  height: 168,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 168,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MetadataPill(label: language),
                          _MetadataPill(label: production.genre),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        production.title.resolve(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        production.synopsis.resolve(locale),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 17,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${AppFormatters.date(performance.dateTime, locale)} · '
                              '${AppFormatters.time(performance.dateTime, locale)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.fromPrice(
                                AppFormatters.money(production.startingPrice),
                              ),
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: scheme.primary,
                          ),
                        ],
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

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: .4,
      ),
    ),
  );
}
