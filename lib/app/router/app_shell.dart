import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';
import 'package:patron_mobile_app/features/bookings/presentation/pages/bookings_page.dart';
import 'package:patron_mobile_app/features/home/presentation/pages/home_page.dart';
import 'package:patron_mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:patron_mobile_app/features/programme/presentation/pages/programme_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.child, required this.selectedIndex, super.key});

  final Widget child;
  final int selectedIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _paths = ['/home', '/shows', '/bookings', '/profile'];
  static const _tabAnimationDuration = Duration(milliseconds: 360);

  late final PageController _pageController;
  late int _activeIndex;
  int? _animationTarget;

  @override
  void initState() {
    super.initState();
    _activeIndex = _safeIndex(widget.selectedIndex);
    _pageController = PageController(initialPage: _activeIndex);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _safeIndex(widget.selectedIndex);
    if (nextIndex == _activeIndex || !_pageController.hasClients) return;

    // Route changes originating outside the navigation bar are tab changes,
    // not pushed iOS pages.
    _activeIndex = nextIndex;
    _pageController.jumpToPage(nextIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _safeIndex(int index) => index < 0 ? 0 : index;

  void _selectTab(int index) {
    if (index == _activeIndex) return;
    setState(() {
      _activeIndex = index;
      _animationTarget = index;
    });
    context.go(_paths[index]);
    _pageController
        .animateToPage(
          index,
          duration: _tabAnimationDuration,
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() {
          if (!mounted || _animationTarget != index) return;
          setState(() => _animationTarget = null);
        });
  }

  void _handlePageChanged(int index) {
    // animateToPage crosses intermediate pages when destinations are not
    // adjacent. Keep the chosen destination selected and avoid route churn.
    if (_animationTarget != null) return;
    if (_activeIndex != index) {
      setState(() => _activeIndex = index);
    }
    if (widget.selectedIndex != index) context.go(_paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Keep non-tab shell destinations functional without putting them in the
    // horizontally swipeable tab set.
    final body = widget.selectedIndex < 0
        ? widget.child
        : PageView(
            key: const Key('primaryTabPageView'),
            controller: _pageController,
            onPageChanged: _handlePageChanged,
            children: [
              HeroMode(
                enabled: _activeIndex == 0,
                child: const HomePage(key: PageStorageKey('homeTab')),
              ),
              HeroMode(
                enabled: _activeIndex == 1,
                child: const ProgrammePage(key: PageStorageKey('showsTab')),
              ),
              HeroMode(
                enabled: _activeIndex == 2,
                child: const BookingsPage(key: PageStorageKey('bookingsTab')),
              ),
              HeroMode(
                enabled: _activeIndex == 3,
                child: const ProfilePage(key: PageStorageKey('profileTab')),
              ),
            ],
          );

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _activeIndex,
        onDestinationSelected: _selectTab,
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
        ],
      ),
    );
  }
}
