import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.showBackButton = false,
    this.onBack,
    this.compactHeader = false,
    super.key,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool compactHeader;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.primary.withValues(alpha: .09),
                      scheme.surface,
                      scheme.surface,
                    ],
                    stops: const [0, .34, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -90,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.gold.withValues(alpha: .12),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      SizedBox(
                        height: compactHeader ? 56 : 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (showBackButton)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    tooltip: 'Back',
                                    onPressed: onBack,
                                    icon: const Icon(Icons.arrow_back_ios_new),
                                  ),
                                ),
                              ),
                            Semantics(
                              label: 'Sapumal Theatre',
                              image: true,
                              child: Image.asset(
                                'assets/images/sapumal_logo.png',
                                height: compactHeader ? 48 : 62,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthLegalFooter extends StatelessWidget {
  const AuthLegalFooter({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 4,
    children: [
      TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
      Text('•', style: Theme.of(context).textTheme.bodySmall),
      TextButton(onPressed: () {}, child: const Text('Terms & Conditions')),
    ],
  );
}
