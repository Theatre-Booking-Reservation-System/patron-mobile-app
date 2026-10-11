import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/formatters/app_formatters.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/checkout/domain/card_payment_validation.dart';
import 'package:patron_mobile_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

enum _PaymentMethod { card, mobile, internetBanking }

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _holderName = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  _PaymentMethod _method = _PaymentMethod.card;
  bool _showFieldErrors = false;

  @override
  void dispose() {
    _holderName.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _pay() {
    final cardSelected = _method == _PaymentMethod.card;
    if (cardSelected) {
      setState(() => _showFieldErrors = true);
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    context.read<CheckoutBloc>().add(
      PaymentRequested(
        card: CardPaymentDetails(
          holderName: _holderName.text.trim(),
          number: _cardNumber.text.replaceAll(RegExp(r'\D'), ''),
          expiry: _expiry.text,
          cvv: _cvv.text,
        ),
      ),
    );
  }

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
            return Form(
              key: _formKey,
              autovalidateMode: _showFieldErrors
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            _method == _PaymentMethod.card
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                          title: Text(context.l10n.cardPayment),
                          trailing: const Icon(Icons.credit_card),
                          onTap: () =>
                              setState(() => _method = _PaymentMethod.card),
                        ),
                        ListTile(
                          enabled: false,
                          leading: Icon(
                            _method == _PaymentMethod.mobile
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                          title: Text(context.l10n.mobilePayment),
                          trailing: const Icon(Icons.phone_android),
                        ),
                        ListTile(
                          enabled: false,
                          leading: Icon(
                            _method == _PaymentMethod.internetBanking
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                          title: Text(context.l10n.internetBanking),
                          trailing: const Icon(Icons.account_balance),
                        ),
                      ],
                    ),
                  ),
                  if (_method == _PaymentMethod.card) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.cardDetails,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('cardHolderField'),
                      controller: _holderName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.cardHolderName,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.requiredField
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('cardNumberField'),
                      controller: _cardNumber,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: const [_CardNumberFormatter()],
                      decoration: InputDecoration(
                        labelText: context.l10n.cardNumber,
                        hintText: '1234 5678 9012 3456',
                      ),
                      validator: (value) => isValidCardNumber(value ?? '')
                          ? null
                          : context.l10n.invalidCardNumber,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('cardExpiryField'),
                            controller: _expiry,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: const [_ExpiryFormatter()],
                            decoration: InputDecoration(
                              labelText: context.l10n.cardExpiry,
                              hintText: 'MM/YY',
                            ),
                            validator: (value) =>
                                switch (cardExpiryFailure(value ?? '')) {
                                  CardExpiryFailure.format =>
                                    context.l10n.invalidCardExpiry,
                                  CardExpiryFailure.month =>
                                    context.l10n.invalidCardMonth,
                                  null => null,
                                },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const Key('cardCvvField'),
                            controller: _cvv,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              labelText: context.l10n.cardCvv,
                            ),
                            validator: (value) => isValidCvv(value ?? '')
                                ? null
                                : context.l10n.invalidCardCvv,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  if (state.status == CheckoutStatus.paymentFailure)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.error == 'seatsUnavailable'
                            ? 'One or more selected seats are no longer available. Please return and select seats again.'
                            : context.l10n.paymentFailed,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: state.status == CheckoutStatus.paying
                        ? null
                        : _pay,
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  const _CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buffer = StringBuffer();
    for (var index = 0; index < trimmed.length; index++) {
      if (index > 0 && index % 4 == 0) buffer.write(' ');
      buffer.write(trimmed[index]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  const _ExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 6 ? digits.substring(0, 6) : digits;
    final text = trimmed.length <= 2
        ? trimmed
        : '${trimmed.substring(0, 2)}/${trimmed.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
