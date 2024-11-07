import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreenGoogleMap extends ConsumerWidget {
  const NavScreenGoogleMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastKnownOrCurrentPositionValue =
        ref.watch(getLastKnownOrCurrentPositionProvider);

    return AsyncValueWidget<Position>(
      value: lastKnownOrCurrentPositionValue,
      data: (initialPosition) =>
          NavScreenView(initialPosition: initialPosition),
    );
  }
}

/// spec: https://pub.dev/packages/google_navigation_flutter/example
/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation.dart
class NavScreenView extends StatefulWidget {
  const NavScreenView({required this.initialPosition, super.key});

  final Position initialPosition;

  @override
  State<NavScreenView> createState() => _NavScreenViewState();
}

class _NavScreenViewState extends State<NavScreenView> {
  bool _navigationSessionInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNavigationSession();
  }

  Future<void> _initializeNavigationSession() async {
    if (!await GoogleMapsNavigator.areTermsAccepted()) {
      await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'Nav STEMI'.hardcoded,
        'Atrium Health'.hardcoded,
      );
    }

    /// Make sure user has also granted location permissions before
    /// starting navigation session.
    await GoogleMapsNavigator.initializeNavigationSession();
    setState(() {
      _navigationSessionInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _navigationSessionInitialized
        ? Consumer(
            builder: (context, ref, child) {
              return GoogleMapsNavigationView(
                onViewCreated: ref
                    .read(navScreenGoogleControllerProvider.notifier)
                    .onViewCreated,
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition.toLatLng(),
                  zoom: 14,
                ),
                initialNavigationUIEnabledPreference:
                    NavigationUIEnabledPreference.disabled,
                // Other view initialization settings
              );
            },
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    if (_navigationSessionInitialized) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }
}
