import 'package:flutter/material.dart';

import 'meter_bar.dart';

class StaminaBar extends StatelessWidget {
  const StaminaBar({super.key, required this.value, required this.sprinting, this.width = 150});
  final double value;
  final bool sprinting;
  final double width;

  @override
  Widget build(BuildContext context) =>
      MeterBar(value: value, color: const Color(0xFF3FBF5A), icon: Icons.bolt_rounded, active: sprinting, width: width);
}
