// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:nav_stemi/nav_stemi.dart';

class Hospital extends Equatable {
  const Hospital({
    required this.facilityBrandedName,
    required this.facilityAddress,
    required this.facilityCity,
    required this.facilityState,
    required this.facilityZip,
    required this.latitude,
    required this.longitude,
    required this.county,
    required this.source,
    required this.facilityPhone1,
    required this.distanceToAsheboro,
    required this.pciCenter,
    this.facilityPhone1Note,
    this.facilityPhone2,
    this.facilityPhone2Note,
    this.facilityPhone3,
    this.facilityPhone3Note,
  });

  /// Name of the hospital, shown in the app
  final String facilityBrandedName;

  /// Human-readable address of the hospital
  final String facilityAddress;

  /// City of the hospital
  final String facilityCity;

  /// State of the hospital, in 2-letter format
  final String facilityState;

  /// Zip code of the hospital, as a 5-digit integer
  final int facilityZip;

  /// Latitude of the hospital
  final double latitude;

  /// Longitude of the hospital
  final double longitude;

  /// County of the hospital
  final String county;

  /// Location where the data was sourced from
  final String source;

  /// Phone number of the hospital (required)
  /// This may have a note attached to it, such as "ER" or "Charge"
  final String facilityPhone1;
  final String? facilityPhone1Note;

  /// Phone number of the hospital #2 (optional)
  /// This may have a note attached to it, such as "ER" or "Charge"
  final String? facilityPhone2;
  final String? facilityPhone2Note;

  /// Phone number of the hospital #3 (optional)
  /// This may have a note attached to it, such as "ER" or "Charge"
  final String? facilityPhone3;
  final String? facilityPhone3Note;

  /// Distance in miles to Asheboro
  final double distanceToAsheboro;

  /// 0 if not a PCI center, 1 if a PCI center
  final int pciCenter;

  Hospital copyWith({
    String? facilityBrandedName,
    String? facilityAddress,
    String? facilityCity,
    String? facilityState,
    int? facilityZip,
    double? latitude,
    double? longitude,
    String? county,
    String? source,
    String? facilityPhone1,
    String? facilityPhone1Note,
    String? facilityPhone2,
    String? facilityPhone2Note,
    String? facilityPhone3,
    String? facilityPhone3Note,
    double? distanceToAsheboro,
    int? pciCenter,
  }) {
    return Hospital(
      facilityBrandedName: facilityBrandedName ?? this.facilityBrandedName,
      facilityAddress: facilityAddress ?? this.facilityAddress,
      facilityCity: facilityCity ?? this.facilityCity,
      facilityState: facilityState ?? this.facilityState,
      facilityZip: facilityZip ?? this.facilityZip,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      county: county ?? this.county,
      source: source ?? this.source,
      facilityPhone1: facilityPhone1 ?? this.facilityPhone1,
      facilityPhone1Note: facilityPhone1Note ?? this.facilityPhone1Note,
      facilityPhone2: facilityPhone2 ?? this.facilityPhone2,
      facilityPhone2Note: facilityPhone2Note ?? this.facilityPhone2Note,
      facilityPhone3: facilityPhone3 ?? this.facilityPhone3,
      facilityPhone3Note: facilityPhone3Note ?? this.facilityPhone3Note,
      distanceToAsheboro: distanceToAsheboro ?? this.distanceToAsheboro,
      pciCenter: pciCenter ?? this.pciCenter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'facilityBrandedName': facilityBrandedName,
      'facilityAddress': facilityAddress,
      'facilityCity': facilityCity,
      'facilityState': facilityState,
      'facilityZip': facilityZip,
      'latitude': latitude,
      'longitude': longitude,
      'county': county,
      'source': source,
      'facilityPhone1': facilityPhone1,
      'facilityPhone1Note': facilityPhone1Note,
      'facilityPhone2': facilityPhone2,
      'facilityPhone2Note': facilityPhone2Note,
      'facilityPhone3': facilityPhone3,
      'facilityPhone3Note': facilityPhone3Note,
      'distanceToAsheboro': distanceToAsheboro,
      'pciCenter': pciCenter,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      facilityBrandedName: map['facilityBrandedName'] as String,
      facilityAddress: map['facilityAddress'] as String,
      facilityCity: map['facilityCity'] as String,
      facilityState: map['facilityState'] as String,
      facilityZip: map['facilityZip'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      county: map['county'] as String,
      source: map['source'] as String,
      facilityPhone1: map['facilityPhone1'] as String,
      facilityPhone1Note: map['facilityPhone1Note'] != null
          ? map['facilityPhone1Note'] as String
          : null,
      facilityPhone2: map['facilityPhone2'] != null
          ? map['facilityPhone2'] as String
          : null,
      facilityPhone2Note: map['facilityPhone2Note'] != null
          ? map['facilityPhone2Note'] as String
          : null,
      facilityPhone3: map['facilityPhone3'] != null
          ? map['facilityPhone3'] as String
          : null,
      facilityPhone3Note: map['facilityPhone3Note'] != null
          ? map['facilityPhone3Note'] as String
          : null,
      distanceToAsheboro: map['distanceToAsheboro'] as double,
      pciCenter: map['pciCenter'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Hospital.fromJson(String source) =>
      Hospital.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      facilityBrandedName,
      facilityAddress,
      facilityCity,
      facilityState,
      facilityZip,
      latitude,
      longitude,
      county,
      source,
      facilityPhone1,
      facilityPhone1Note,
      facilityPhone2,
      facilityPhone2Note,
      facilityPhone3,
      facilityPhone3Note,
      distanceToAsheboro,
      pciCenter,
    ];
  }

  /// Helper method to convert the hospital to a [AppWaypoint] object
  /// Used for backwards compatibility with prior versions of the app
  AppWaypoint location() {
    return AppWaypoint(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Helper method to determine if the hospital is a PCI center
  /// Used for backwards compatibility with prior versions of the app
  bool isPci() {
    return switch (pciCenter) {
      0 => false,
      1 => true,
      // TODO(FireJuun): extract to AppException
      _ => throw Exception('Invalid PCI center value: $pciCenter'),
    };
  }
}
