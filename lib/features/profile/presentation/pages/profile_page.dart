import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/settings/app_settings_bloc.dart';
import 'package:patron_mobile_app/app/settings/app_settings_repository.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/language_selector.dart';
import 'package:patron_mobile_app/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final settings = context.watch<AppSettingsBloc>().state;
    final patron = auth.patron;
    if (patron == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.profile)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    size: 46,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'You are browsing as a guest',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create an account to book seats, manage reservations, and '
                  'link a Sapumal loyalty card.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () async {
                    final authBloc = context.read<AuthBloc>()
                      ..add(const AuthLogoutRequested());
                    await authBloc.stream.firstWhere(
                      (state) => state.status == AuthStatus.anonymous,
                    );
                    if (context.mounted) context.go('/register');
                  },
                  child: Text(context.l10n.createAccount),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    final authBloc = context.read<AuthBloc>()
                      ..add(const AuthLogoutRequested());
                    await authBloc.stream.firstWhere(
                      (state) => state.status == AuthStatus.anonymous,
                    );
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(context.l10n.login),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/shows'),
                  child: const Text('Continue browsing'),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const Icon(Icons.logout),
                  label: const Text('End guest session'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            title: Text(context.l10n.profile),
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Colors.black87,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 52, 22, 16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: AppTheme.gold,
                          child: Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patron.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                patron.email,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              if (patron.isLoyaltyMember)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    context.l10n.loyaltyMember,
                                    style: const TextStyle(
                                      color: AppTheme.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileTile(
                  icon: Icons.person_outline,
                  label: context.l10n.myProfile,
                ),
                _ProfileTile(
                  icon: Icons.card_membership,
                  label: context.l10n.loyaltyCard,
                  onTap: () {
                    context.read<AuthBloc>().add(const LoyaltyLinked());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.loyaltyLinked)),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.credit_card,
                  label: context.l10n.paymentMethods,
                ),
                _ProfileTile(
                  icon: Icons.help_outline,
                  label: context.l10n.helpSupport,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.settings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(
                          settings.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        title: Text(context.l10n.themeMode),
                        subtitle: Text(
                          settings.themeMode == ThemeMode.dark
                              ? context.l10n.dark
                              : context.l10n.light,
                        ),
                        value: settings.themeMode == ThemeMode.dark,
                        onChanged: (_) => context.read<AppSettingsBloc>().add(
                          const AppBrightnessToggled(),
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.seedFor(settings.palette),
                        ),
                        title: Text(context.l10n.colourPalette),
                        subtitle: Text(_paletteName(context, settings.palette)),
                        trailing: const Icon(Icons.palette_outlined),
                        onTap: () => context.read<AppSettingsBloc>().add(
                          const AppPaletteCycled(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(context.l10n.language),
                            const SizedBox(height: 8),
                            const LanguageSelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.info_outline,
                  label: context.l10n.aboutUs,
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    context.l10n.logout,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _paletteName(BuildContext context, AppPalette palette) =>
      switch (palette) {
        AppPalette.burgundy => context.l10n.burgundy,
        AppPalette.midnight => context.l10n.midnight,
        AppPalette.emerald => context.l10n.emerald,
      };
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap ?? () {},
  );
}
