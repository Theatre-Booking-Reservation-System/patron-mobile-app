import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool simulateFailure = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state.status == CheckoutStatus.confirmed) {
          context.read<BookingsBloc>().add(const BookingsRequested());
          context.go('/confirmation');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.payment)),
        body: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final amount = state.quote?.total ?? 0;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  context.l10n.amountToPay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.money(amount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.radio_button_checked),
                        title: Text(context.l10n.cardPayment),
                        trailing: const Icon(Icons.credit_card),
                      ),
                      ListTile(
                        enabled: false,
                        leading: const Icon(Icons.radio_button_unchecked),
                        title: Text(context.l10n.mobilePayment),
                        trailing: const Icon(Icons.phone_android),
                      ),
                      ListTile(
                        enabled: false,
                        leading: const Icon(Icons.radio_button_unchecked),
                        title: Text(context.l10n.internetBanking),
                        trailing: const Icon(Icons.account_balance),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(context.l10n.mockPaymentNotice)),
                      ],
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: simulateFailure,
                  title: Text(context.l10n.simulateFailure),
                  onChanged: (value) => setState(() => simulateFailure = value),
                ),
                if (state.status == CheckoutStatus.paymentFailure)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      context.l10n.paymentFailed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: state.status == CheckoutStatus.paying
                      ? null
                      : () => context.read<CheckoutBloc>().add(
                          PaymentRequested(simulateFailure: simulateFailure),
                        ),
                  icon: state.status == CheckoutStatus.paying
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(
                    state.status == CheckoutStatus.paymentFailure
                        ? context.l10n.retry
                        : context.l10n.payNow,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
