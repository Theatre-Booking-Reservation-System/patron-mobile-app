import 'package:flutter/material.dart';
import 'package:patron_mobile_app/app/theme/app_theme.dart';
import 'package:patron_mobile_app/core/localization/l10n_extension.dart';

class ProductionPoster extends StatelessWidget {
  const ProductionPoster({
    required this.title,
    required this.seed,
    this.height = 160,
    super.key,
  });

  final String title;
  final int seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [Color(0xFF120606), Color(0xFF6B0D12)],
      [Color(0xFF24110B), Color(0xFF8A3B16)],
      [Color(0xFF070707), Color(0xFF3A2710)],
    ];
    final colors = gradients[seed % gradients.length];
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Icon(Icons.theater_comedy, color: AppTheme.gold, size: 38),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1.08,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              context.l10n.appName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
