import 'package:flutter/material.dart';
import 'package:patron_mobile_app/core/widgets/production_poster.dart';
import 'package:patron_mobile_app/features/booking/domain/entities/theatre_models.dart';

class ProductionPosterHero extends StatelessWidget {
  const ProductionPosterHero({
    required this.production,
    required this.locale,
    required this.height,
    this.borderRadius = 18,
    super.key,
  });

  final Production production;
  final String locale;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'poster-${production.id}',
    transitionOnUserGestures: true,
    createRectTween: (begin, end) => RectTween(begin: begin, end: end),
    child: ProductionPoster(
      title: production.title.resolve(locale),
      seed: production.posterSeed,
      height: height,
      borderRadius: borderRadius,
      showLabel: false,
    ),
  );
}
