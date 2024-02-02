import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

// TODO(FireJuun): use this enum to determine active state of Nearsest: options in the nav screen
enum NearestOption { pciCenter, ed, other }

const _util = GoogleMapsToRoutesUtil();

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  bool _showSteps = false;
  bool _showNextTurn = true;

  late GoogleMapController mapController;
  final origin = _util.routesToMaps(locationRandolphEms);
  final destination = _util.routesToMaps(Locations.atriumWakeHighPoint.loc);
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

// TODO(FireJuun): remove polyline points code (deprecated)
  /// down to init state.
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = Env.directionsApi;
  void _addPolyLine() {
    const id = PolylineId('poly');
    final polyline = Polyline(
      polylineId: id,
      width: 4,
      color: Colors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> _getPolyline() async {
    final result = await polylinePoints.getRouteBetweenCoordinates(
      Env.directionsApi,
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      wayPoints: [],
    );
    if (result.points.isNotEmpty) {
      for (final point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(
      origin,
      'origin',
      BitmapDescriptor.defaultMarker,
    );

    /// destination marker
    _addMarker(
      destination,
      'destination',
      BitmapDescriptor.defaultMarkerWithHue(90),
    );
    _getPolyline();
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    final markerId = MarkerId(id);
    final marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;

        bool shouldShowSteps() => _showSteps && !isKeyboardVisible;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  NearestEdSelector(
                    onTapNearestPciCenter: () async {
                      // TODO(FireJuun): handle tap for nearest pci
                      final result = await ActiveRouteRepository().getRoute();
                      debugPrint('route result:\n${result.toJson()}');
                    },
                    onTapNearestEd: () async {
                      // TODO(FireJuun): handle tap for nearest ed
                      final results =
                          await ActiveRouteRepository().getRouteMatrix();
                      for (var i = 0; i < results.length; i++) {
                        final item = results[i].toJson();
                        debugPrint('route matrix result $i:\n$item');
                      }
                      debugPrint('all items found');
                    },
                  ),
                  gapH4,
                  Expanded(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        // const MapScreen(),
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: origin,
                            zoom: 14,
                          ),
                          trafficEnabled: true,
                          myLocationButtonEnabled: false,
                          onMapCreated: _onMapCreated,
                          markers: Set<Marker>.of(markers.values),
                          polylines: Set<Polyline>.of(polylines.values),
                        ),
                        AnimatedSwitcher(
                          duration: 300.ms,
                          child: _showNextTurn
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: TurnDirections(
                                    onTap: () =>
                                        setState(() => _showNextTurn = false),
                                  ),
                                )
                              : Align(
                                  alignment: AlignmentDirectional.topStart,
                                  child: FilledButton.tonalIcon(
                                    icon: const Icon(Icons.expand_more),
                                    label: Text('Next Step'.hardcoded),
                                    onPressed: () =>
                                        setState(() => _showNextTurn = true),
                                  ),
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: 300.ms,
                            height: shouldShowSteps()
                                ? MediaQuery.of(context).size.height * 0.25
                                : 0,
                            // TODO(FireJuun): directions go here
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: shouldShowSteps()
                                  ? Border.all(color: colorScheme.onSurface)
                                  : null,
                            ),
                            child: Center(child: Text('All Steps'.hardcoded)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ColoredBox(
                    color: colorScheme.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedSwitcher(
                          duration: 300.ms,
                          child: shouldShowSteps()
                              ? FilledButton(
                                  onPressed: () =>
                                      setState(() => _showSteps = false),
                                  child: Text('All Steps'.hardcoded),
                                )
                              : OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showSteps = true),
                                  child: Text('All Steps'.hardcoded),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.alt_route),
                              tooltip: 'Other Routes'.hardcoded,
                              onPressed: () {
                                // TODO(FireJuun): Query Other Routes Dialog
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.moving),
                              tooltip: 'Show Entire Route'.hardcoded,
                              onPressed: () {
                                // TODO(FireJuun): Zoom map to full route
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.my_location),
                              tooltip: 'My Location'.hardcoded,
                              onPressed: () {
                                mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: origin,
                                      zoom: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.zoom_out),
                              tooltip: 'Zoom Out'.hardcoded,
                              // onPressed: () {},
                              onPressed: () => mapController
                                  .animateCamera(CameraUpdate.zoomOut()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_in),
                              tooltip: 'Zoom In'.hardcoded,
                              // onPressed: () {},
                              onPressed: () => mapController
                                  .animateCamera(CameraUpdate.zoomIn()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: const Alignment(-1, .25),
                child: IconButton(
                  onPressed: () {
                    // TODO(FireJuun): handle directions toggle (+ redraw)
                  },
                  tooltip: 'Narrate Directions'.hardcoded,
                  icon: const Icon(Icons.voice_over_off),
                ),
              )
                  .animate(
                    target: shouldShowSteps() ? 1 : 0,
                    delay: 400.ms,
                  )
                  .fadeIn(
                    duration: 200.ms,
                  ),
              Align(
                alignment: const Alignment(1, .25),
                child: IconButton(
                  onPressed: () {
                    // TODO(FireJuun): handle north up toggle (+ redraw)
                  },
                  tooltip: 'North Points Up'.hardcoded,
                  icon: const Icon(Icons.explore),
                ),
              )
                  .animate(
                    target: shouldShowSteps() ? 1 : 0,
                    delay: 400.ms,
                  )
                  .fadeIn(
                    duration: 200.ms,
                  ),
            ],
          ),
        );
      },
    );
  }
}
