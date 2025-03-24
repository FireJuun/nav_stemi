import 'dart:async';

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
  /// spec: https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html
  late final AppLifecycleListener _listener;

  bool _locationPermitted = true;
  bool _notificationsPermitted = true;

  bool permissionsMissing() => !_locationPermitted || !_notificationsPermitted;

  HomeController get notifier => ref.read(homeControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(_checkAndSavePermissions());

    _listener = AppLifecycleListener(
      onResume: _checkAndSavePermissions,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _checkAndSavePermissions() async {
    final permissions = await notifier.checkPermissionsOnAppStart();

    if (context.mounted) {
      setState(() {
        _locationPermitted = permissions.areLocationsPermitted;
        _notificationsPermitted = permissions.areNotificationsPermitted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(homeControllerProvider);

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('nav - STEMI'.hardcoded),
        centerTitle: true,
      ),
      endDrawer: const RightNavDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                // TODO(FireJuun): move this to admin UI, to add/update hospitals list
                // FilledButton(
                //   onPressed: selectAndUploadCSV,
                //   child: Text('Upload CSV'.hardcoded),
                // ),
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
                if (permissionsMissing())
                  Column(
                    children: [
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: textTheme.bodyLarge?.apply(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          children: [
                            TextSpan(
                              text: 'Error',
                              style: textTheme.bodyLarge?.apply(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            TextSpan(text: ': '.hardcoded),
                            TextSpan(
                              text: 'Missing the following permissions:'
                                  .hardcoded,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_locationPermitted)
                            Text(
                              '• Location'.hardcoded,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.apply(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          if (!_notificationsPermitted)
                            Text(
                              '• Notifications'.hardcoded,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.apply(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                        ],
                      ),
                      gapH8,
                    ],
                  ),

                /// temporary button to sign in with Google, for testing
                // TODO(FireJuun): remove this button + gapH16 below
                OutlinedButton(
                  onPressed: () {
                    GoogleAuthRepository().signIn().then((_) {
                      if (context.mounted) {
                        debugPrint('User signed in');
                      }
                    });
                  },
                  child: Text(
                    'Login'.hardcoded,
                    style: textTheme.headlineMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (permissionsMissing())
                      FilledButton(
                        onPressed: notifier.openAppSettingsPage,
                        child: Text(
                          'Open App\nSettings'.hardcoded,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall!.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: permissionsMissing()
                          ? null
                          : () => context.goNamed(AppRoute.goTo.name),
                      child: Text(
                        '+ GO'.hardcoded,
                        style: textTheme.headlineMedium!.apply(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
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
