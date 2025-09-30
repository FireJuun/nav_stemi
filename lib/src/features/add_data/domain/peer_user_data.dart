import 'package:equatable/equatable.dart';

/// Represents user data for peer-to-peer session syncing.
///
/// This class contains identifying information about other users who can
/// participate in collaborative STEMI case sessions. It's used to display
/// connected peers and manage automatic syncing preferences.
///
/// The data is fetched from Firestore's 'users' collection and matched
/// against connected Bridgefy peer device IDs (syncId).
///
/// Example usage:
/// ```dart
/// final peer = PeerUserData(
///   firstName: 'John',
///   lastName: 'Doe',
///   phoneNumber: '+1234567890',
///   syncId: 'abc-123-def',
/// );
/// print(peer.displayName); // 'John Doe'
/// ```
class PeerUserData extends Equatable {
  /// Creates a [PeerUserData] instance.
  ///
  /// All fields are optional to accommodate various user data states.
  const PeerUserData({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.syncId,
  });

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The user's phone number (used for authentication).
  final String? phoneNumber;

  /// Unique identifier for peer-to-peer syncing via Bridgefy.
  ///
  /// This ID is used to match connected Bridgefy devices with user profiles
  /// stored in Firestore. It's generated when a user first signs in.
  final String? syncId;

  /// Returns a human-readable display name for the user.
  ///
  /// Priority order:
  /// 1. Full name (firstName + lastName) if available
  /// 2. Phone number if name is not available
  /// 3. Sync ID if neither name nor phone is available
  /// 4. '<unknown>' as a fallback
  ///
  /// Example:
  /// ```dart
  /// // With full name
  /// PeerUserData(firstName: 'John', lastName: 'Doe').displayName
  /// // Returns: 'John Doe'
  ///
  /// // With phone only
  /// PeerUserData(phoneNumber: '+1234567890').displayName
  /// // Returns: '+1234567890'
  ///
  /// // With sync ID only
  /// PeerUserData(syncId: 'abc-123').displayName
  /// // Returns: 'abc-123'
  /// ```
  String get displayName {
    final displayName = [firstName, lastName].nonNulls.join(' ');

    if (displayName.isNotEmpty) {
      return displayName;
    }

    return phoneNumber ?? syncId ?? '<unknown>';
  }

  /// Converts this instance to a map for Firestore storage.
  ///
  /// Returns a map with keys matching Firestore document field names.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'syncId': syncId,
    };
  }

  /// Creates a copy of this instance with the given fields replaced.
  ///
  /// Any field that is not provided will retain its current value.
  ///
  /// Example:
  /// ```dart
  /// final original = PeerUserData(firstName: 'John', lastName: 'Doe');
  /// final updated = original.copyWith(firstName: 'Jane');
  /// // updated.firstName is 'Jane', updated.lastName is still 'Doe'
  /// ```
  PeerUserData copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? syncId,
  }) {
    return PeerUserData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, phoneNumber, syncId];
}
