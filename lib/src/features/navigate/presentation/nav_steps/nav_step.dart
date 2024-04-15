import 'package:flutter/material.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavStep extends StatelessWidget {
  const NavStep({required this.routeLegStep, super.key});

  final RouteLegStep routeLegStep;

  @override
  Widget build(BuildContext context) {
    final values = routeLegStep.relevantValues();
    return ListTile(
      leading: NavIconByManeuver(values.maneuver),
      title: Text(values.instructions),
      trailing: Text(values.distance),
    );
  }
}
