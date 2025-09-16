import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nav_stemi/nav_stemi.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  static const Key profileIconButtonKey = Key('profile_icon_button');

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

  void _showAuthDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const AuthDialog(),
    );
  }

  void _showEncountersDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const PriorEncountersDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      homeControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final authState = ref.watch(authStateChangesProvider);
    final textTheme = Theme.of(context).textTheme;

    // Watch environment configuration with Riverpod
    final environmentConfig = ref.watch(appEnvironmentConfigProvider);

    final backgroundColor = environmentConfig.when(
      data: (config) => config.getAppBarColor(),
      loading: () => Colors.transparent,
      error: (_, __) => Colors.transparent,
    );

    final foregroundColor = environmentConfig.when(
      data: (config) => config.environment != AppEnvironment.production
          ? Theme.of(context).colorScheme.onPrimary
          : null,
      loading: () => Colors.transparent,
      error: (_, __) => Colors.transparent,
    );

    final isUserLoggedIn = authState.whenOrNull(
          data: (user) => user != null,
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'nav - STEMI'.hardcoded,
              style: textTheme.titleLarge?.apply(color: foregroundColor),
            ),
            // Display version number in dev and staging environments
            environmentConfig.when(
              data: (config) {
                if (config.environment != AppEnvironment.production) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '''v${config.version}.${config.environment == AppEnvironment.development ? 'dev' : 'stg'}''',
                      style:
                          textTheme.titleSmall?.apply(color: foregroundColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
        actions: [
          // Profile icon button - same as in AppBarWidget
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              color: foregroundColor,
              key: const Key('profile_icon_button'),
              icon: authState.when(
                data: (user) => user != null
                    ? const Icon(Icons.account_circle)
                    : const Icon(Icons.account_circle_outlined),
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Icon(Icons.error_outline),
              ),
              onPressed: () => _showAuthDialog(context, ref),
            ),
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                gapH24,
                Column(
                  children: [
                    Text(
                      'Click `Go` to begin'.hardcoded,
                      style: textTheme.titleLarge!
                          .apply(fontStyle: FontStyle.italic),
                    ),
                    gapH24,
                    Text(
                      'Click `Add Data`\nto pre-enter info'.hardcoded,
                      style: textTheme.titleLarge!
                          .apply(fontStyle: FontStyle.italic),
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
                      TextSpan(
                        text: 'You can modify info at anytime'.hardcoded,
                      ),
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
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              if (!_notificationsPermitted)
                                Text(
                                  '• Notifications'.hardcoded,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.apply(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                ),
                            ],
                          ),
                          gapH8,
                        ],
                      ),
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
                              : () {
                                  // If user is logged in, initialize FHIR resources before navigating
                                  if (isUserLoggedIn) {
                                    ref
                                        .read(fhirInitServiceProvider)
                                        .initializeBlankResources();
                                  }
                                  context.goNamed(AppRoute.goTo.name);
                                },
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
                      onPressed: () =>
                          context.goNamed(AppRoute.navAddData.name),
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

          // Add the login status indicator at the top right
          LoginStatusIndicator(
            onShowEncountersPressed: () => _showEncountersDialog(context),
          ),
        ],
      ),
    );
  }
}
