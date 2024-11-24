import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/main.dart
class _HomeState extends ConsumerState<Home> {
  bool _locationPermitted = false;
  bool _notificationsPermitted = false;

  @override
  void initState() {
    ref.read(permissionsServiceProvider).checkPermissionsOnAppStart().then(
      (permissions) {
        setState(() {
          _locationPermitted = permissions.areLocationsPermitted;
          _notificationsPermitted = permissions.areNotificationsPermitted;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO(FireJuun): show [_locationPermitted] and [_notificationsPermitted] in the UI, if not accepted

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('nav - STEMI'.hardcoded),
        centerTitle: true,
      ),
      endDrawer: const Drawer(
        child: Center(child: Text('text')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Click `Go` to begin'.hardcoded,
                  style:
                      textTheme.titleLarge!.apply(fontStyle: FontStyle.italic),
                ),
                gapH24,
                Text(
                  'Click `Add Data`\nto pre-enter info'.hardcoded,
                  style:
                      textTheme.titleLarge!.apply(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'FYI',
                    style: textTheme.bodyLarge?.apply(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ': '.hardcoded),
                  TextSpan(text: 'You can modify info at anytime'.hardcoded),
                ],
              ),
            ),
            Column(
              children: [
                FilledButton(
                  onPressed: () => context.goNamed(AppRoute.goTo.name),
                  child: Text(
                    '+ GO'.hardcoded,
                    style: textTheme.headlineMedium!
                        .apply(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                gapH16,
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.navAddData.name),
                  child: Text(
                    'Add Data'.hardcoded,
                    style: textTheme.headlineMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
