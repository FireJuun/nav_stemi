import 'package:flutter/material.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NextStep extends StatelessWidget {
  const NextStep({required this.routeLegStep, required this.onTap, super.key});

  final RouteLegStep routeLegStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final values = routeLegStep.relevantValues();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const borderRadius = BorderRadius.vertical(
      bottom: Radius.circular(12),
    );

    return Material(
      color: colorScheme.secondary,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              IconTheme(
                data: Theme.of(context).iconTheme.copyWith(
                      color: colorScheme.onSecondary,
                    ),
                child: NavIconByManeuver(values.maneuver),
              ),
              gapW16,
              Expanded(
                child: Text(
                  values.instructions,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.apply(
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
              gapW8,
              Text(
                values.distance,
                style: textTheme.bodyMedium?.apply(
                  color: colorScheme.onSecondary,
                  fontStyle: FontStyle.italic,
                  fontWeightDelta: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
