import 'package:flutter/material.dart';

import 'meter_bar.dart';

class FlightEnergyBar extends StatelessWidget {
  const FlightEnergyBar({super.key, required this.value, required this.flying, this.width = 150});
  final double value;
  final bool flying;
  final double width;

  @override
  Widget build(BuildContext context) =>
      MeterBar(value: value, color: const Color(0xFF38B6FF), icon: Icons.air_rounded, active: flying, width: width);
}
