import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/main.dart
class _HomeState extends State<Home> {
  bool _locationPermitted = false;
  bool _notificationsPermitted = false;

  @override
  void initState() {
    _requestPermissions();
    super.initState();
  }

  /// Request permission for accessing the device's location and notifications.
  ///
  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation (Always and WhenInUse), Notification
  Future<void> _requestPermissions() async {
    final locationPermission = await Permission.location.request();

    var notificationPermission = PermissionStatus.denied;
    if (Platform.isIOS) {
      notificationPermission = await Permission.notification.request();
    }
    setState(() {
      _locationPermitted = locationPermission == PermissionStatus.granted;
      _notificationsPermitted =
          notificationPermission == PermissionStatus.granted;
    });
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
