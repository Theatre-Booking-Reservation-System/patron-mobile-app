import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final paths = ['/home', '/shows', '/bookings', '/profile', '/more'];
    final selected = paths.indexWhere((item) => path.startsWith(item));
    final l10n = context.l10n;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(paths[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.theater_comedy_outlined),
            selectedIcon: const Icon(Icons.theater_comedy),
            label: l10n.shows,
          ),
          NavigationDestination(
            icon: const Icon(Icons.confirmation_number_outlined),
            selectedIcon: const Icon(Icons.confirmation_number),
            label: l10n.bookings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
          NavigationDestination(icon: const Icon(Icons.menu), label: l10n.more),
        ],
      ),
    );
  }
}
