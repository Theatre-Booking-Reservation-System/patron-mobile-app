import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

class BookingSummaryPage extends StatelessWidget {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookingSummary)),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          final draft = state.draft;
          final quote = state.quote;
          if (draft == null || quote == null) {
            return Center(child: Text(context.l10n.error));
          }
          final locale = Localizations.localeOf(context).languageCode;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.production.title.resolve(locale),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${AppFormatters.date(draft.performance.dateTime, locale)} • ${AppFormatters.time(draft.performance.dateTime, locale)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final line in quote.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${line.seat.row}${line.seat.number} • ${line.seat.zoneName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${line.seat.multiplierPercent}% • ${AppFormatters.money(line.netAfterDiscounts)}',
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.money(line.total),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _AmountRow(
                context.l10n.ticketTotal,
                AppFormatters.money(quote.netTotal),
              ),
              _AmountRow(
                context.l10n.loyaltyDiscount,
                '- ${AppFormatters.money(quote.loyaltyTotal)}',
              ),
              _AmountRow(
                context.l10n.vat(quote.vatPercent),
                AppFormatters.money(quote.vatTotal),
              ),
              const Divider(height: 28),
              _AmountRow(
                context.l10n.totalPayable,
                AppFormatters.money(quote.total),
                emphasized: true,
              ),
              if (state.patron?.isFlagged == true) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined),
                        const SizedBox(width: 10),
                        Expanded(child: Text(context.l10n.flagged)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.consentAccepted,
                onChanged: (value) => context.read<CheckoutBloc>().add(
                  CheckoutConsentChanged(value ?? false),
                ),
                title: Text(context.l10n.termsConsent),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.consentAccepted
                    ? () => context.push('/payment')
                    : null,
                child: Text(context.l10n.proceedCheckout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.value, {this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? const TextStyle(fontWeight: FontWeight.w600)
                : null,
          ),
        ),
        Text(
          value,
          style: emphasized
              ? Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
              : null,
        ),
      ],
    ),
  );
}
