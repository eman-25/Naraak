import 'package:flutter/material.dart';

class NaraakLogo extends StatelessWidget {
  const NaraakLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: 'Naraak logo',
        child: Image.asset(
          'assets/images/naraak_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
}
