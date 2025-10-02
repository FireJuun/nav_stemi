import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Data model for sharing STEMI case session data via QR code.
///
/// This class encapsulates patient information and time metrics data
/// for peer-to-peer session syncing. It can be serialized to JSON
/// for QR code encoding and deserialized when scanning a QR code.
///
/// Example usage:
/// ```dart
/// final sessionData = SessionShareData(
///   patientInfo: patientInfoModel,
///   timeMetrics: timeMetricsModel,
/// );
/// final jsonString = sessionData.toJson();
/// // Use jsonString to generate QR code
/// ```
class SessionShareData extends Equatable {
  /// Creates a [SessionShareData] instance.
  const SessionShareData({
    this.patientInfo,
    this.timeMetrics,
    this.version = 1,
  });

  /// Creates a [SessionShareData] instance from a map.
  factory SessionShareData.fromMap(Map<String, dynamic> map) {
    debugPrint('Deserializing session data: $map');
    return SessionShareData(
      version: map['version'] as int? ?? 1,
      patientInfo: map['patientInfo'] != null
          ? PatientInfoModel.fromMap(map['patientInfo'] as Map<String, dynamic>)
          : null,
      timeMetrics: map['timeMetrics'] != null
          ? TimeMetricsModel.fromMap(
              map['timeMetrics'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Creates a [SessionShareData] instance from a JSON string.
  ///
  /// This is used when scanning a QR code to deserialize the data.
  factory SessionShareData.fromJson(String source) {
    return SessionShareData.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }

  /// Patient information for the current STEMI case.
  final PatientInfoModel? patientInfo;

  /// Time metrics data for the current STEMI case.
  final TimeMetricsModel? timeMetrics;

  /// Version number for data format compatibility.
  ///
  /// This allows for future schema changes while maintaining
  /// backward compatibility when scanning QR codes.
  final int version;

  /// Checks if there is any data to share.
  ///
  /// Returns true if either patient info or time metrics exist.
  bool get hasData => patientInfo != null || timeMetrics != null;

  /// Converts this instance to a map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'patientInfo': patientInfo?.toMap(),
      'timeMetrics': timeMetrics?.toMap(),
    };
  }

  /// Converts this instance to a JSON string.
  ///
  /// This is the format used for QR code encoding.
  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [patientInfo, timeMetrics, version];

  @override
  bool get stringify => true;
}
