import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// original source: https://github.com/MayJuun/wvems_protocols/blob/main/lib/src/features/preferences/presentation/shared/responsive_dialog_widget.dart

class ResponsiveDialogWidget extends StatelessWidget {
  const ResponsiveDialogWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          final isAboveBreakpoint = constraints.maxWidth >= Breakpoint.tablet;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (isAboveBreakpoint || !isPortrait)
                  ? double.infinity
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
        Row(
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
        const Divider(),
      ],
    );
  }
}

class ResponsiveDialogFooter extends StatelessWidget {
  const ResponsiveDialogFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        gapH8,
      ],
    );
  }
}
