import 'package:flutter/material.dart';

/// Shared content frame for root tabs and service pages.
///
/// It keeps mobile padding compact and centers a wider desktop canvas without
/// duplicating each screen for web and mobile.
class ResponsivePageFrame extends StatelessWidget {
  const ResponsivePageFrame({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.mobilePadding = const EdgeInsets.fromLTRB(20, 20, 20, 40),
    this.desktopPadding = const EdgeInsets.fromLTRB(32, 28, 32, 48),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry mobilePadding;
  final EdgeInsetsGeometry desktopPadding;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return SingleChildScrollView(
      padding: desktop ? desktopPadding : mobilePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
