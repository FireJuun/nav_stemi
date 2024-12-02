import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavStep extends StatelessWidget {
  const NavStep({required this.routeLegStep, required this.onTap, super.key});

  final StepInfo routeLegStep;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        /// implemented because ListTile isn't showing a splash color
        onTap: onTap,
        splashColor: colorScheme.secondary,
        child: ListTile(
          leading: NavIconByManeuver(routeLegStep.maneuver),
          title: Text(routeLegStep.fullInstructions),
          // TODO(FireJuun): convert meters to other units
          trailing: Text('${routeLegStep.distanceFromPrevStepMeters} m'),
        ),
      ),
    );
  }
}
