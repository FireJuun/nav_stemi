import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/src/features/add_data/domain/peer_user_data.dart';

/// Repository for fetching peer user information from Firestore.
///
/// This repository is responsible for retrieving user profile data for
/// connected peers during collaborative STEMI case sessions. It queries
/// the Firestore 'users' collection to match Bridgefy device sync IDs
/// with user profiles.
///
/// The repository is used by SyncNotifyController to display information
/// about connected peers and enable automatic session syncing.
///
/// Example usage:
/// ```dart
/// final repository = ref.read(PeerInfoRepository.provider);
/// final connectedPeerIds = ['abc-123', 'def-456'];
/// final peerData = await repository.fetchPeerUserData(connectedPeerIds);
/// // Returns list of PeerUserData for matching users
/// ```
class PeerInfoRepository {
  /// Creates a [PeerInfoRepository] with the given Firestore instance.
  PeerInfoRepository(this._firestore);

  /// Riverpod provider for [PeerInfoRepository].
  ///
  /// Provides a singleton instance using the default FirebaseFirestore.
  static final provider = Provider<PeerInfoRepository>(
    (ref) => PeerInfoRepository(FirebaseFirestore.instance),
  );

  final FirebaseFirestore _firestore;

  /// Firestore collection path for user documents.
  static const String _usersPath = 'users';

  /// Fetches user data for the given list of sync IDs.
  ///
  /// Queries Firestore for users whose 'syncId' field matches any of the
  /// provided [syncIds]. This is typically used to get profile information
  /// for connected Bridgefy peers.
  ///
  /// Returns an empty list if no matching users are found.
  ///
  /// Parameters:
  /// - [syncIds]: List of Bridgefy device sync IDs to query for
  ///
  /// Returns:
  /// - List of [PeerUserData] objects for matching users
  ///
  /// Example:
  /// ```dart
  /// final connectedDeviceIds = ['abc-123-def', 'xyz-789-uvw'];
  /// final peers = await repository.fetchPeerUserData(connectedDeviceIds);
  /// for (final peer in peers) {
  ///   print('Connected: ${peer.displayName}');
  /// }
  /// ```
  ///
  /// Note: Firestore's `arrayContainsAny` has a limit of 30 items per query.
  /// If more than 30 sync IDs need to be queried, multiple queries should
  /// be performed.
  Future<List<PeerUserData>> fetchPeerUserData(List<String> syncIds) async {
    final querySnapshot = await _firestore
        .collection(_usersPath)
        .where('syncId', arrayContainsAny: syncIds)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        return PeerUserData(
          firstName: data['firstName'] as String?,
          lastName: data['lastName'] as String?,
          syncId: data['syncId'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
        );
      }).toList();
    }
    return [];
  }
}
