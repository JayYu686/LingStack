import 'package:flutter/material.dart';

import 'ai_surface_card.dart';

class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      padding: padding,
      variant: AiCardVariant.elevated,
      child: child,
    );
  }
}
