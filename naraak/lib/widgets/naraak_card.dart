import 'package:flutter/material.dart';
import 'app_card.dart';

class NaraakCard extends StatelessWidget {
  const NaraakCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: padding,
        color: color,
        child: child,
      );
}
