import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/features/auth/presentation/widgets/auth_scaffold.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver {
  static const _slideDuration = Duration(seconds: 5);
  static const _animationDuration = Duration(milliseconds: 650);

  final _pageController = PageController();
  Timer? _rotationTimer;
  int _currentPage = 0;

  static const _slides = [
    _WelcomeSlideData(
      eyebrow: 'CURATED FOR THE STAGE',
      title: 'Discover remarkable theatre.',
      description:
          'Explore Sinhala, Tamil, and English productions from one beautifully curated programme.',
      visual: _WelcomeVisual.spotlight,
      topColor: Color(0xFF101A36),
      bottomColor: Color(0xFF6B0D12),
    ),
    _WelcomeSlideData(
      eyebrow: 'YOUR VIEW, YOUR CHOICE',
      title: 'Choose the seats you love.',
      description:
          'Compare sections, understand every seat state, and see the complete price before you continue.',
      visual: _WelcomeVisual.seats,
      topColor: Color(0xFF121D3D),
      bottomColor: Color(0xFF3E1735),
    ),
    _WelcomeSlideData(
      eyebrow: 'EVERY VISIT, TOGETHER',
      title: 'Keep the magic close.',
      description:
          'Manage upcoming performances, receipts, and loyalty benefits whenever you return.',
      visual: _WelcomeVisual.ticket,
      topColor: Color(0xFF132C2A),
      bottomColor: Color(0xFF6B0D12),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRotation());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startRotation();
    } else {
      _rotationTimer?.cancel();
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _rotationTimer = Timer.periodic(_slideDuration, (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: _animationDuration,
        curve: Curves.easeInOutCubicEmphasized,
      );
    });
  }

  void _selectPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    _startRotation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rotationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOutCubicEmphasized,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [slide.topColor, slide.bottomColor],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _AmbientBackdrop(),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Semantics(
                        label: 'Sapumal Theatre',
                        image: true,
                        child: Image.asset(
                          'assets/images/sapumal_logo.png',
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                          _startRotation();
                        },
                        itemBuilder: (context, index) => Semantics(
                          label: 'Slide ${index + 1} of ${_slides.length}',
                          child: _WelcomeSlide(data: _slides[index]),
                        ),
                      ),
                    ),
                    _PageIndicator(
                      currentPage: _currentPage,
                      pageCount: _slides.length,
                      onSelected: _selectPage,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: const Color(0xFF2D2104),
                        ),
                        onPressed: () => context.push('/login'),
                        child: const Text('Get started'),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      onPressed: () => context.push('/login'),
                      child: const Text('I already have an account'),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFD8CDC5),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      child: const AuthLegalFooter(),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({required this.data});

  final _WelcomeSlideData data;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Center(child: _WelcomeArtwork(type: data.visual)),
        ),
        const SizedBox(height: 16),
        Text(
          data.eyebrow,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          data.description,
          style: const TextStyle(
            color: Color(0xFFF4EDE5),
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}

class _WelcomeArtwork extends StatelessWidget {
  const _WelcomeArtwork({required this.type});

  final _WelcomeVisual type;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 370),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          color: Colors.white.withValues(alpha: .08),
          border: Border.all(color: Colors.white.withValues(alpha: .12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 36,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _WelcomeArtworkPainter(type: type),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _WelcomeArtworkPainter extends CustomPainter {
  const _WelcomeArtworkPainter({required this.type});

  final _WelcomeVisual type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _WelcomeVisual.spotlight:
        _paintSpotlight(canvas, size);
      case _WelcomeVisual.seats:
        _paintSeats(canvas, size);
      case _WelcomeVisual.ticket:
        _paintTicket(canvas, size);
    }
  }

  void _paintSpotlight(Canvas canvas, Size size) {
    final gold = Paint()..color = AppTheme.gold;
    final pale = Paint()
      ..color = const Color(0xFFFFE8A4).withValues(alpha: .22);
    final wine = Paint()..color = const Color(0xFF8C1720);
    final center = Offset(size.width * .5, size.height * .57);
    final spotlight = Path()
      ..moveTo(size.width * .34, 0)
      ..lineTo(size.width * .66, 0)
      ..lineTo(size.width * .82, size.height)
      ..lineTo(size.width * .18, size.height)
      ..close();
    canvas.drawPath(spotlight, pale);
    canvas.drawCircle(center, size.shortestSide * .2, wine);
    canvas.drawCircle(center.translate(-34, -4), 38, gold);
    canvas.drawCircle(center.translate(34, -4), 38, gold);
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(-34, 2), radius: 20),
      .15,
      2.8,
      false,
      Paint()
        ..color = const Color(0xFF6B0D12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(34, 10), radius: 20),
      3.35,
      2.7,
      false,
      Paint()
        ..color = const Color(0xFF6B0D12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  void _paintSeats(Canvas canvas, Size size) {
    final stage = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11;
    canvas.drawArc(
      Rect.fromLTWH(size.width * .18, size.height * .1, size.width * .64, 86),
      3.35,
      2.72,
      false,
      stage,
    );
    final colors = [
      const Color(0xFF7BC391),
      AppTheme.gold,
      const Color(0xFF7BC391),
      const Color(0xFFA8171C),
    ];
    for (var row = 0; row < 4; row++) {
      final count = 6 + row;
      final spacing = size.width * .68 / (count - 1);
      for (var seat = 0; seat < count; seat++) {
        final color = colors[(row + seat) % colors.length];
        final center = Offset(
          size.width * .16 + seat * spacing,
          size.height * (.43 + row * .13),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: 25, height: 22),
            const Radius.circular(7),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  void _paintTicket(Canvas canvas, Size size) {
    final ticketRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .53),
        width: size.width * .72,
        height: size.height * .58,
      ),
      const Radius.circular(26),
    );
    canvas.save();
    canvas.rotate(-.06);
    canvas.drawRRect(ticketRect, Paint()..color = const Color(0xFFFFFBF5));
    final left = ticketRect.left + 28;
    final top = ticketRect.top + 30;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          top,
          ticketRect.width * .28,
          ticketRect.height - 60,
        ),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF6B0D12),
    );
    canvas.drawCircle(
      Offset(left + ticketRect.width * .14, top + ticketRect.height * .25),
      24,
      Paint()..color = AppTheme.gold,
    );
    final ink = Paint()
      ..color = const Color(0xFF162447)
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 3; index++) {
      ink.strokeWidth = index == 0 ? 9 : 6;
      canvas.drawLine(
        Offset(ticketRect.left + ticketRect.width * .42, top + 16 + index * 35),
        Offset(ticketRect.right - 28, top + 16 + index * 35),
        ink,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WelcomeArtworkPainter oldDelegate) =>
      oldDelegate.type != type;
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.pageCount,
    required this.onSelected,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Page ${currentPage + 1} of $pageCount',
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final selected = index == currentPage;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(index),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: selected ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: selected
                    ? AppTheme.gold
                    : Colors.white.withValues(alpha: .42),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        top: -120,
        left: -110,
        child: Container(
          width: 310,
          height: 310,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
      ),
      Positioned(
        right: -120,
        bottom: 180,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.gold.withValues(alpha: .1),
          ),
        ),
      ),
    ],
  );
}

enum _WelcomeVisual { spotlight, seats, ticket }

class _WelcomeSlideData {
  const _WelcomeSlideData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.visual,
    required this.topColor,
    required this.bottomColor,
  });

  final String eyebrow;
  final String title;
  final String description;
  final _WelcomeVisual visual;
  final Color topColor;
  final Color bottomColor;
}
