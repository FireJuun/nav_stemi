import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

class GoToDialog extends StatelessWidget {
  const GoToDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      child: Center(
        child: Column(
          children: [
            ResponsiveDialogHeader(label: 'Go'.hardcoded),
            const Expanded(child: _PlaceholderData()),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderData extends StatelessWidget {
  const _PlaceholderData();

  @override
  Widget build(BuildContext context) {
    const locations = Locations.values;
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) => _PlaceholderButton(locations[index]),
    );
  }
}

class _PlaceholderButton extends StatelessWidget {
  const _PlaceholderButton(this.location);

  final Locations location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: OutlinedButton(
        onPressed: () => context.goNamed(AppRoute.nav.name),
        child: Text(location.shortName, textAlign: TextAlign.center),
      ),
    );
  }
}
