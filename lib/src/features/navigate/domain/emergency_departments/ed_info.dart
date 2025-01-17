// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nav_stemi/nav_stemi.dart';

class EdInfo extends Equatable {
  const EdInfo({
    required this.name,
    required this.shortName,
    required this.location,
    required this.address,
    required this.website,
    required this.telephone,
    this.isPCI = false,
    this.is24HourPci = false,
  });

  final String name;
  final String shortName;
  final AppWaypoint location;
  final String address;
  final String website;
  final String telephone;
  final bool isPCI;
  final bool is24HourPci;

  EdInfo copyWith({
    String? name,
    String? shortName,
    AppWaypoint? location,
    String? address,
    String? website,
    String? telephone,
    bool? isPCI,
    bool? is24HourPci,
  }) {
    return EdInfo(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      location: location ?? this.location,
      address: address ?? this.address,
      website: website ?? this.website,
      telephone: telephone ?? this.telephone,
      isPCI: isPCI ?? this.isPCI,
      is24HourPci: is24HourPci ?? this.is24HourPci,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'shortName': shortName,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'website': website,
      'telephone': telephone,
      'isPCI': isPCI,
      'is24HourPci': is24HourPci,
    };
  }

  factory EdInfo.fromMap(Map<String, dynamic> map) {
    return EdInfo(
      name: map['name'] as String,
      shortName: map['shortName'] as String,
      location: map['location'] as AppWaypoint,
      address: map['address'] as String,
      website: map['website'] as String,
      telephone: map['telephone'] as String,
      isPCI: map['isPCI'] as bool,
      is24HourPci: map['is24HourPci'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory EdInfo.fromJson(String source) =>
      EdInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      name,
      shortName,
      location,
      address,
      website,
      telephone,
      isPCI,
      is24HourPci,
    ];
  }
}
