import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    HapticFeedback.selectionClick();
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
      extendBody: true,
      body: body,
      bottomNavigationBar: LiquidGlassNavigationBar(
        selectedIndex: _activeIndex,
        pageController: _pageController,
        onDestinationSelected: _selectTab,
        destinations: [
          LiquidGlassNavigationDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.home,
          ),
          LiquidGlassNavigationDestination(
            icon: Icons.theater_comedy_outlined,
            selectedIcon: Icons.theater_comedy_rounded,
            label: l10n.shows,
          ),
          LiquidGlassNavigationDestination(
            icon: Icons.confirmation_number_outlined,
            selectedIcon: Icons.confirmation_number_rounded,
            label: l10n.bookings,
          ),
          LiquidGlassNavigationDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

@immutable
class LiquidGlassNavigationDestination {
  const LiquidGlassNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class LiquidGlassNavigationBar extends StatelessWidget {
  const LiquidGlassNavigationBar({
    required this.selectedIndex,
    required this.pageController,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  final int selectedIndex;
  final PageController pageController;
  final ValueChanged<int> onDestinationSelected;
  final List<LiquidGlassNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(30));

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .34 : .16),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: scheme.primary.withValues(alpha: dark ? .12 : .08),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                key: const Key('bottomNavigationDock'),
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? .18 : .72),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            Colors.white.withValues(alpha: .14),
                            scheme.surface.withValues(alpha: .68),
                            Colors.white.withValues(alpha: .07),
                          ]
                        : [
                            Colors.white.withValues(alpha: .88),
                            scheme.surface.withValues(alpha: .66),
                            Colors.white.withValues(alpha: .56),
                          ],
                    stops: const [0, .52, 1],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth =
                        constraints.maxWidth / destinations.length;
                    return AnimatedBuilder(
                      animation: pageController,
                      builder: (context, _) {
                        final page = pageController.hasClients
                            ? pageController.page ?? selectedIndex.toDouble()
                            : selectedIndex.toDouble();
                        final glassPosition = page.clamp(
                          0.0,
                          (destinations.length - 1).toDouble(),
                        );
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: itemWidth * glassPosition + 5,
                              top: 6,
                              bottom: 6,
                              width: itemWidth - 10,
                              child: _LiquidSelectionCapsule(
                                color: scheme.primary,
                                dark: dark,
                              ),
                            ),
                            Positioned(
                              left: 24,
                              right: 24,
                              top: .5,
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(
                                        alpha: dark ? .34 : .9,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                for (
                                  var index = 0;
                                  index < destinations.length;
                                  index++
                                )
                                  Expanded(
                                    child: _LiquidNavigationItem(
                                      key: Key('bottomNavItem-$index'),
                                      destination: destinations[index],
                                      selected: selectedIndex == index,
                                      onTap: () => onDestinationSelected(index),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidSelectionCapsule extends StatelessWidget {
  const _LiquidSelectionCapsule({required this.color, required this.dark});

  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .28)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: .18), color),
          color.withValues(alpha: dark ? .78 : .9),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: dark ? .42 : .28),
          blurRadius: 18,
          spreadRadius: -3,
          offset: const Offset(0, 7),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: .2),
          blurRadius: 5,
          spreadRadius: -2,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Align(
      alignment: const Alignment(0, -.92),
      child: Container(
        width: 26,
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: .84),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),
  );
}

class _LiquidNavigationItem extends StatelessWidget {
  const _LiquidNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final LiquidGlassNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedColor = scheme.onPrimary;
    final idleColor = scheme.onSurface.withValues(alpha: .68);

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: onTap,
            radius: 34,
            containedInkWell: true,
            highlightShape: BoxShape.rectangle,
            splashColor: scheme.primary.withValues(alpha: .1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 23,
                    color: selected ? selectedColor : idleColor,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: selected ? selectedColor : idleColor,
                    fontSize: 11,
                    height: 1,
                    letterSpacing: selected ? .05 : .15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w600,
                  ),
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
