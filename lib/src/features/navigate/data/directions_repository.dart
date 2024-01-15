import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class DirectionsRepository {
  // DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final _api = Env.mapsApi();
}
