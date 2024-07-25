import 'package:flutter/material.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavStep extends StatelessWidget {
  const NavStep({required this.routeLegStep, required this.onTap, super.key});

  final RouteLegStep routeLegStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final values = routeLegStep.relevantValues();
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        /// implemented because ListTile isn't showing a splash color
        onTap: onTap,
        splashColor: colorScheme.secondary,
        child: ListTile(
          leading: NavIconByManeuver(values.maneuver),
          title: Text(values.instructions),
          trailing: Text(values.distance),
        ),
      ),
    );
  }
}
