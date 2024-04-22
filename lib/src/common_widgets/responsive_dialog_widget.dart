import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// original source: https://github.com/MayJuun/wvems_protocols/blob/main/lib/src/features/preferences/presentation/shared/responsive_dialog_widget.dart

class ResponsiveDialogWidget extends StatelessWidget {
  const ResponsiveDialogWidget({
    required this.child,
    this.denseHeight = false,
    super.key,
  });

  final Widget child;
  final bool denseHeight;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor:
          const Color(0xFFFFEBE7), // TODO(FireJuun): extract into theme
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          final isAboveBreakpoint = constraints.maxWidth >= Breakpoint.tablet;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (isAboveBreakpoint || !isPortrait)
                  ? double.infinity
                  : denseHeight
                      ? 500
                      : MediaQuery.of(context).size.height - 256,
              maxWidth: isAboveBreakpoint ? 600 : double.infinity,
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class ResponsiveDialogHeader extends StatelessWidget {
  const ResponsiveDialogHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          color: const Color(0xFFB8B8D1), // TODO(FireJuun): extract into theme
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.apply(fontWeightDelta: 2),
              ),
              gapW32,
            ],
          ),
        ),
        gapH8,
      ],
    );
  }
}

class ResponsiveDialogFooter extends StatelessWidget {
  const ResponsiveDialogFooter({
    this.label,
    this.includeAccept = false,
    this.onAccept,
    super.key,
  });

  final String? label;
  final bool includeAccept;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.secondary,
      child: Column(
        children: [
          const Divider(thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(label ?? 'Cancel'.hardcoded),
              ),
              if (includeAccept)
                FilledButton(
                  style: Theme.of(context).filledButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        if (states.any(interactiveStates.contains)) {
                          return colorScheme.secondary;
                        }
                        // disabled state = grey
                        else if (states
                            .any((state) => state == MaterialState.disabled)) {
                          return colorScheme.outline;
                        }
                        return colorScheme.primary;
                      },
                    ),
                  ),
                  onPressed: onAccept,
                  child: Text('Accept'.hardcoded),
                ),
            ],
          ),
          gapH8,
        ],
      ),
    );
  }
}
