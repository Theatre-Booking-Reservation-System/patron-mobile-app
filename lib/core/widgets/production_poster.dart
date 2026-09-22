import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';

class ProductionPoster extends StatelessWidget {
  const ProductionPoster({
    required this.title,
    required this.seed,
    this.height = 160,
    this.borderRadius = 18,
    super.key,
  });

  final String title;
  final int seed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [Color(0xFF101A36), Color(0xFF6B0D12)],
      [Color(0xFF30150D), Color(0xFF8A3B16)],
      [Color(0xFF0C241F), Color(0xFF162447)],
    ];
    final colors = gradients[seed % gradients.length];
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PosterArtwork(seed: seed)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .05),
                  Colors.black.withValues(alpha: .72),
                ],
                stops: const [0, .48, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const Spacer(),
                Text(
                  title.toUpperCase(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: height > 200 ? 17 : 12,
                    height: 1.04,
                    letterSpacing: -.25,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  context.l10n.appName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: height > 200 ? 8 : 6,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    decoration: TextDecoration.none,
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

class _PosterArtwork extends CustomPainter {
  const _PosterArtwork({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed + 17);
    final glow = Paint()..color = AppTheme.gold.withValues(alpha: .23);
    final pale = Paint()..color = Colors.white.withValues(alpha: .08);

    canvas.drawCircle(
      Offset(size.width * (.7 + random.nextDouble() * .12), size.height * .22),
      size.shortestSide * .42,
      glow,
    );
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .48),
      size.shortestSide * .32,
      pale,
    );

    final spotlight = Path()
      ..moveTo(size.width * .35, 0)
      ..lineTo(size.width * .65, 0)
      ..lineTo(size.width * .9, size.height)
      ..lineTo(size.width * .1, size.height)
      ..close();
    canvas.drawPath(
      spotlight,
      Paint()..color = Colors.white.withValues(alpha: .045),
    );

    final arc = Paint()
      ..color = AppTheme.gold.withValues(alpha: .72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3, size.width * .025)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .2,
        size.height * .24,
        size.width * .6,
        size.height * .3,
      ),
      3.35,
      2.72,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _PosterArtwork oldDelegate) =>
      oldDelegate.seed != seed;
}
