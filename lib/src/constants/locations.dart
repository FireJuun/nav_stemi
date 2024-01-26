// ignore_for_file: lines_longer_than_80_chars

import 'package:google_routes_flutter/google_routes_flutter.dart';

const locationRandolphEms =
    LatLng(latitude: 35.668559944183734, longitude: -79.83191024196512);

enum Locations {
  atriumStanly(
    name: 'Atrium Health Stanly Emergency Department',
    shortName: 'Atrium | Stanly ED',
    loc: LatLng(latitude: 35.399265303297575, longitude: -80.18203397003248),
    address: '301 Yadkin St, Albemarle, NC 28001',
    website:
        'https://atriumhealth.org/locations/detail/atrium-health-stanly?utm_source=GMB&utm_medium=Organic&utm_campaign=GCR',
    telephone: '+19803234000',
  ),
  atriumWakeHighPoint(
    name:
        'Atrium Health Wake Forest Baptist | High Point Medical Center Emergency Room',
    shortName: 'Atrium | Wake Forest | High Point Medical Center',
    loc: LatLng(latitude: 35.98519242673937, longitude: -79.99369338396555),
    address: '601 N Elm St, High Point, NC 27262',
    website:
        'https://www.wakehealth.edu/Locations/Emergency-Departments/High-Point-Medical-Center-Emergency-Department',
    telephone: '+13368786009',
    isPCI: true,
  ),
  chatham(
    name: 'Chatham Hospital Emergency Department',
    shortName: 'Chatham Hospital ED',
    loc: LatLng(latitude: 35.766731727815525, longitude: -79.40923937602902),
    address: '475 Progress Blvd, Siler City, NC 27344',
    website:
        'https://www.unchealth.org/care-services/locations/chatham-hospital-emergency-department-chatham-hospital',
    telephone: '+19197994000',
  ),
  coneHealthDrawbridge(
    name: 'Cone Health Emergency Department at Drawbridge Parkway',
    shortName: 'Cone Health ED | Drawbridge Parkway',
    loc: LatLng(latitude: 36.175296903238255, longitude: -79.85757708737738),
    address: '3518 Drawbridge Pkwy Suite LL010, Greensboro, NC 27410',
    website:
        'https://www.conehealth.com/medcenter-greensboro-at-drawbridge-parkway/services/locations/emergency-department-drawbridge-parkway/',
    telephone: '+13368903000',
  ),
  coneHealthHighPoint(
    name: 'Cone Health Emergency Department at MedCenter High Point',
    shortName: 'Cone Health ED | MedCenter High Point',
    loc: LatLng(latitude: 36.065474528620875, longitude: -79.95920061971961),
    address: '2630 Willard Dairy Rd First Floor, Suite C, High Point, NC 27265',
    website: 'https://www.conehealth.com/medcenter-high-point/',
    telephone: '+13368843777',
  ),
  firstHealthMontgomery(
    name: 'FirstHealth Montgomery Memorial Hospital: Emergency Room',
    shortName: 'FirstHealth | Montgomery Memorial ER',
    loc: LatLng(latitude: 35.385657509324936, longitude: -79.85682302191839),
    address: '520 Allen St, Troy, NC 27371',
    website: 'http://www.firsthealth.org/',
    telephone: '+19105715000',
  ),
  firstHealthMoore(
    name: 'FirstHealth Moore Regional Hospital Emergency Room',
    shortName: 'FirstHealth | Moore Regional ER',
    loc: LatLng(latitude: 35.24034962913522, longitude: -79.4700992107263),
    address: '155 Memorial Dr, Pinehurst, NC 28374',
    website:
        'https://www.firsthealth.org/directory/hospitals-and-service-locations/firsthealth-moore-regional-hospital',
    telephone: '+19107151000',
  ),
  randolph(
    name: 'Randolph Health: Emergency Room',
    shortName: 'Randolph Health ER',
    loc: LatLng(latitude: 35.77061131735204, longitude: -79.81026291293811),
    address: '364 White Oak St, Asheboro, NC 27203',
    website: 'https://www.randolphhospital.org/',
    telephone: '+13366255151',
  ),
  ;

  const Locations({
    required this.name,
    required this.shortName,
    required this.loc,
    required this.address,
    required this.website,
    required this.telephone,
    this.isPCI = false,
  });

  final String name;
  final String shortName;
  final LatLng loc;
  final String address;
  final String website;
  final String telephone;
  final bool isPCI;
}
