// ignore_for_file: lines_longer_than_80_char
import 'package:nav_stemi/nav_stemi.dart';

const locationRandolphEms =
    AppWaypoint(latitude: 35.668559944183734, longitude: -79.83191024196512);

const locations = <Hospital>[
  Hospital(
    facilityBrandedName: 'Atrium Health Stanly Emergency Department',
    latitude: 35.399265303297575,
    longitude: -80.18203397003248,
    facilityAddress: '301 Yadkin St',
    facilityCity: 'Albemarle',
    county: 'Stanly',
    source: 'Google',
    distanceToAsheboro: 40,
    pciCenter: 0,
    facilityZip: 28001,
    facilityState: 'NC',
    facilityPhone1: '+19803234000',
  ),
];

const simulationLocations = [
  /// Randolph EMS
  randolphEms,

  AppWaypoint(
    latitude: 35.69035468873936,
    longitude: -79.80255486524308,
    label: 'E Dixie Dr',
  ),

  AppWaypoint(
    latitude: 35.5156040045054,
    longitude: -79.5770717840869,
    label: 'Jabo Hussey Rd',
  ),
];

const randolphEms = AppWaypoint(
  latitude: 35.668559944183734,
  longitude: -79.83191024196512,
  label: 'New Century Dr',
);
