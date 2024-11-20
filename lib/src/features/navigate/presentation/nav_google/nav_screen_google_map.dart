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
class NavScreenView extends ConsumerStatefulWidget {
  const NavScreenView({required this.initialPosition, super.key});

  final Position initialPosition;

  @override
  ConsumerState<NavScreenView> createState() => _NavScreenViewState();
}

class _NavScreenViewState extends ConsumerState<NavScreenView> {
  LatLng? _userLocation;

  @override
  Widget build(BuildContext context) {
    return GoogleMapsNavigationView(
      onViewCreated:
          ref.read(navScreenGoogleControllerProvider.notifier).onViewCreated,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition.toLatLng(),
        zoom: 14,
      ),
      // Other view initialization settings
    );
  }
}
