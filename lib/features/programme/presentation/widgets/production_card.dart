import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/production', extra: production),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                child: ProductionPoster(
                  title: production.title.resolve(locale),
                  seed: production.posterSeed,
                  height: 132,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            production.title.resolve(locale),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.favourite,
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border, size: 20),
                        ),
                      ],
                    ),
                    Text('${production.genre} • $language'),
                    const SizedBox(height: 8),
                    Text(
                      '${AppFormatters.date(performance.dateTime, locale)} • ${AppFormatters.time(performance.dateTime, locale)}',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.fromPrice(
                        AppFormatters.money(production.startingPrice),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
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
