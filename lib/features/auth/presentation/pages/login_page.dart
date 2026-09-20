import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final name = TextEditingController();
  final email = TextEditingController(text: 'nimal.perera@example.com');
  final password = TextEditingController(text: 'SapumalDemo#1');
  bool registering = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) context.go('/profile');
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.login)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.theater_comedy, size: 72),
            const SizedBox(height: 24),
            if (registering) ...[
              TextField(
                controller: name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: context.l10n.fullName),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: context.l10n.email),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(labelText: context.l10n.password),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.demoCredentials,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status != AuthStatus.failure &&
                    state.status != AuthStatus.locked) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.status == AuthStatus.locked
                        ? context.l10n.accountLocked
                        : context.l10n.invalidCredentials,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => FilledButton(
                onPressed: state.status == AuthStatus.submitting
                    ? null
                    : state.status == AuthStatus.locked
                    ? null
                    : () => context.read<AuthBloc>().add(
                        registering
                            ? AuthRegistrationRequested(
                                name.text,
                                email.text.trim(),
                                password.text,
                              )
                            : AuthLoginRequested(
                                email.text.trim(),
                                password.text,
                              ),
                      ),
                child: state.status == AuthStatus.submitting
                    ? const CircularProgressIndicator()
                    : Text(
                        registering
                            ? context.l10n.createAccount
                            : context.l10n.signIn,
                      ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => registering = !registering),
              child: Text(
                registering ? context.l10n.signIn : context.l10n.register,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
