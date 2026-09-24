import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';
import 'package:patron_mobile_app/features/checkout/presentation/bloc/checkout_bloc.dart';

class PassengerDetailsPage extends StatefulWidget {
  const PassengerDetailsPage({required this.draft, super.key});

  final BookingDraft draft;

  @override
  State<PassengerDetailsPage> createState() => _PassengerDetailsPageState();
}

class _PassengerDetailsPageState extends State<PassengerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController(text: '0771234567');
  final _identity = TextEditingController();
  ConcessionType _concession = ConcessionType.none;

  @override
  void initState() {
    super.initState();
    final patron = context.read<AuthBloc>().state.patron;
    _name = TextEditingController(text: patron?.name ?? '');
    _email = TextEditingController(text: patron?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _identity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.passengerDetails)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.l10n.contactInfo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.l10n.fullName),
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.l10n.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.l10n.email),
              validator: (value) => value == null || !value.contains('@')
                  ? context.l10n.invalidEmail
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: context.l10n.phone),
              validator: (value) => value == null || value.trim().length < 9
                  ? context.l10n.requiredField
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.concessionOptional,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ConcessionType>(
              initialValue: _concession,
              decoration: InputDecoration(
                labelText: context.l10n.concessionType,
              ),
              items: [
                DropdownMenuItem(
                  value: ConcessionType.none,
                  child: Text(context.l10n.none),
                ),
                DropdownMenuItem(
                  value: ConcessionType.under16,
                  child: Text(context.l10n.under16),
                ),
                DropdownMenuItem(
                  value: ConcessionType.over70,
                  child: Text(context.l10n.over70),
                ),
                DropdownMenuItem(
                  value: ConcessionType.largeParty,
                  child: Text(context.l10n.largeParty),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _concession = value ?? ConcessionType.none),
            ),
            if (_concession != ConcessionType.none) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _identity,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.l10n.identityNumber,
                ),
                validator: (value) {
                  if (_concession == ConcessionType.none) return null;
                  final input = value?.trim() ?? '';
                  return input.length < 8 ? context.l10n.invalidIdentity : null;
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(context.l10n.verificationNotice)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              context.l10n.mockConfigNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                if (_concession == ConcessionType.largeParty &&
                    widget.draft.seats.length <= 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.invalidLargeParty)),
                  );
                  return;
                }
                context.read<CheckoutBloc>().add(
                  PatronDetailsSubmitted(
                    PatronDetails(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      phone: _phone.text.trim(),
                      concession: _concession,
                      identityDocument: _identity.text.trim(),
                    ),
                  ),
                );
                context.push('/summary');
              },
              child: Text(context.l10n.continueSummary),
            ),
          ],
        ),
      ),
    );
  }
}
