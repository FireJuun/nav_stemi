import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class TurnDirections extends StatelessWidget {
  const TurnDirections({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            horizontal: 8,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              Icon(
                Icons.turn_left,
                color: colorScheme.onSecondary,
              ),
              gapW8,
              Expanded(
                child: Text(
                  'Left onto Random Street',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.apply(
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
              gapW8,
              Text(
                '500 ft',
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
