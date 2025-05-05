import 'package:equatable/equatable.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import 'package:nav_stemi/nav_stemi.dart';

class ActiveDestination extends Equatable {
  const ActiveDestination({
    required this.destination,
    required this.destinationInfo,
  });

  final Destinations? destination;
  final Hospital destinationInfo;

  ActiveDestination copyWith({
    Destinations? destination,
    Hospital? destinationInfo,
  }) {
    return ActiveDestination(
      destination: destination ?? this.destination,
      destinationInfo: destinationInfo ?? this.destinationInfo,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [destination, destinationInfo];
}
