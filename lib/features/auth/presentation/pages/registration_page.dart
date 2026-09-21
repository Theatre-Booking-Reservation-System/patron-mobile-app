import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patron_mobile_app/features/auth/presentation/widgets/auth_scaffold.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _detailsKey = GlobalKey<FormState>();
  final _securityKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _identity = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  DateTime? _dateOfBirth;
  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _acceptedTerms = false;
  bool _acknowledgedPrivacy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _identity.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      var selected = initial;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => Container(
          height: 350,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        setState(() => _dateOfBirth = selected);
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: DateTime(1900),
                    maximumDate: now,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (selected != null) setState(() => _dateOfBirth = selected);
  }

  void _continueToSecurity() {
    FocusScope.of(context).unfocus();
    if (!(_detailsKey.currentState?.validate() ?? false)) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select your date of birth.')),
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_securityKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms || !_acknowledgedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept the terms and acknowledge the privacy notice.'),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthRegistrationRequested(
        name: _name.text,
        email: _email.text.trim(),
        phone: _phone.text,
        dateOfBirth: _dateOfBirth!,
        identityNumber: _identity.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.registrationSuccess) {
          context.go('/registration-success');
        }
      },
      child: AuthScaffold(
        compactHeader: true,
        showBackButton: true,
        onBack: () {
          if (_step == 1) {
            setState(() => _step = 0);
          } else {
            context.pop();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _step == 0 ? .5 : 1,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_step + 1} of 2',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _step == 0 ? _buildDetails() : _buildSecurity(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() => Form(
    key: _detailsKey,
    child: ListView(
      key: const ValueKey('registration-details'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        Text(
          'Create your account',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'These details help us manage tickets and determine age-based concessions.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        TextFormField(
          key: const Key('registrationNameField'),
          controller: _name,
          autofillHints: const [AutofillHints.name],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: _required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('registrationEmailField'),
          controller: _email,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.mail_outline),
          ),
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'Enter your email address.';
            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
              return 'Enter a valid email address.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '+94 77 123 4567',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            final normalized = (value ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
            if (normalized.isEmpty) return 'Enter your phone number.';
            if (normalized.length < 9) return 'Enter a valid phone number.';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: _dateOfBirth == null
              ? 'Select date of birth'
              : 'Date of birth ${DateFormat.yMMMMd().format(_dateOfBirth!)}',
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickDateOfBirth,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                prefixIcon: Icon(Icons.cake_outlined),
                suffixIcon: Icon(Icons.calendar_month_outlined),
              ),
              child: Text(
                _dateOfBirth == null
                    ? 'Select date'
                    : DateFormat.yMMMMd().format(_dateOfBirth!),
                style: _dateOfBirth == null
                    ? TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _identity,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'NIC or passport number',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (value) {
            final input = value?.trim() ?? '';
            if (input.isEmpty) return 'Enter your NIC or passport number.';
            if (input.length < 6) return 'Enter a valid identity number.';
            return null;
          },
        ),
        const SizedBox(height: 28),
        FilledButton(
          key: const Key('registrationContinueButton'),
          onPressed: _continueToSecurity,
          child: const Text('Continue'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Already registered? Sign in'),
        ),
      ],
    ),
  );

  Widget _buildSecurity() => Form(
    key: _securityKey,
    child: ListView(
      key: const ValueKey('registration-security'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        Text(
          'Secure your account',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Use a strong, unique password to protect your bookings.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        TextFormField(
          key: const Key('registrationPasswordField'),
          controller: _password,
          obscureText: _obscurePassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) => isValidPassword(value ?? '')
              ? null
              : 'Your password does not meet every requirement.',
        ),
        const SizedBox(height: 14),
        _PasswordRequirements(password: _password.text),
        const SizedBox(height: 18),
        TextFormField(
          controller: _confirmPassword,
          obscureText: _obscureConfirmation,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.lock_reset_outlined),
            suffixIcon: IconButton(
              tooltip: _obscureConfirmation ? 'Show password' : 'Hide password',
              onPressed: () =>
                  setState(() => _obscureConfirmation = !_obscureConfirmation),
              icon: Icon(
                _obscureConfirmation
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) =>
              value == _password.text ? null : 'Passwords do not match.',
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: _acceptedTerms,
          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I accept the Terms & Conditions.'),
        ),
        CheckboxListTile(
          value: _acknowledgedPrivacy,
          onChanged: (value) =>
              setState(() => _acknowledgedPrivacy = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I acknowledge the Privacy Notice.'),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final loading = state.status == AuthStatus.submitting;
            return FilledButton(
              key: const Key('createAccountButton'),
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Text('Create account'),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'No API call is made in this build. Registration is simulated locally.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'This field is required.' : null;
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final rules = <(String, bool)>[
      ('At least 12 characters', password.length >= 12),
      ('Uppercase letter', RegExp('[A-Z]').hasMatch(password)),
      ('Lowercase letter', RegExp('[a-z]').hasMatch(password)),
      ('Number', RegExp('[0-9]').hasMatch(password)),
      ('Special character', RegExp(r'[^A-Za-z0-9]').hasMatch(password)),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        runSpacing: 10,
        children: [
          for (final rule in rules)
            SizedBox(
              width: MediaQuery.sizeOf(context).width > 430 ? 220 : 170,
              child: Row(
                children: [
                  Icon(
                    rule.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: rule.$2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      rule.$1,
                      style: Theme.of(context).textTheme.bodySmall,
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
