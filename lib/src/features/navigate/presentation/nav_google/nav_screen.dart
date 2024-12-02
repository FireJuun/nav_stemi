import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreen extends ConsumerWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionValue = ref.watch(getCurrentPositionProvider);
    return AsyncValueWidget<Position?>(
      value: positionValue,
      data: (position) => position == null
          ? const Center(child: CircularProgressIndicator())
          : NavScreenGoogle(initialPosition: position),
    );
  }
}
