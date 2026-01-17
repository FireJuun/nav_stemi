import 'package:nav_stemi/nav_stemi.dart';

class FirebaseUserData {
  FirebaseUserData({
    required this.appUser,
    this.firstName,
    this.lastName,
    this.isAdmin = false,
    this.syncId,
  });

  final FirebaseAppUser appUser;
  final String? firstName;
  final String? lastName;

  final String? syncId;
  final bool isAdmin;

  String? get phoneNumber => appUser.user.phoneNumber;

  String get displayName {
    final displayName =
        appUser.user.displayName ?? [firstName, lastName].nonNulls.join(' ');

    if (displayName.isNotEmpty) {
      return displayName;
    }

    return phoneNumber ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'isAdmin': isAdmin,
      'syncId': syncId,
    };
  }

  FirebaseUserData copyWith({
    required FirebaseAppUser appUser,
    String? firstName,
    String? lastName,
    bool? isAdmin,
  }) {
    return FirebaseUserData(
      appUser: appUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
