import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/core/widgets/language_selector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              seed.withValues(alpha: .96),
              const Color(0xFF170503),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Colors.white),
                    const LanguageSelector(compact: true),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.theater_comedy,
                  size: 78,
                  color: AppTheme.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.appName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.heroTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.heroSubtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => context.go('/shows'),
                  child: Text(context.l10n.bookTickets),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
