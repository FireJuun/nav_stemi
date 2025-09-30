import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/src/data/services/bridgefy_service.dart';
import 'package:nav_stemi/src/features/add_data/data/peer_user_repository.dart';
import 'package:nav_stemi/src/features/add_data/domain/peer_user_data.dart';
import 'package:nav_stemi/src/features/export.dart';

class SyncNotifyController extends AsyncNotifier<SyncNotifyState> {
  static final provider =
      AsyncNotifierProvider<SyncNotifyController, SyncNotifyState>(
    SyncNotifyController.new,
  );

  @override
  FutureOr<SyncNotifyState> build() async {
    ref.listen(BridgefyService.eventsProvider, (previous, next) {});
    final connectedPeers = await ref.watch(
      BridgefyService.connectedPeersProvider.future,
    );

    final autosyncPeers =
        ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    final connectedPeersData = await ref
        .watch(PeerInfoRepository.provider)
        .fetchPeerUserData(connectedPeers);

    return SyncNotifyState(
      connectedPeers: connectedPeersData,
      autosyncPeers: autosyncPeers,
    );
  }

  void addAutosyncPeer(String deviceId) {
    ref.read(sharedPreferencesRepositoryProvider).addAutoSyncPeer(deviceId);

    final autosyncPeers =
        ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    state = AsyncValue.data(
      SyncNotifyState(
        connectedPeers: state.value?.connectedPeers ?? [],
        autosyncPeers: autosyncPeers,
      ),
    );
  }

  void removeAutosyncPeer(String deviceId) {
    ref.read(sharedPreferencesRepositoryProvider).removeAutoSyncPeer(deviceId);

    final autosyncPeers =
        ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    state = AsyncValue.data(
      SyncNotifyState(
        connectedPeers: state.value?.connectedPeers ?? [],
        autosyncPeers: autosyncPeers,
      ),
    );
  }

  void onHandleSync(String deviceId, Map<String, dynamic> data) {
    ref
        .read(BridgefyService.provider)
        .sendToDevice(deviceId: deviceId, data: data);
    // Handle sync logic here
  }
}

class SyncNotifyState extends Equatable {
  const SyncNotifyState({
    this.connectedPeers = const [],
    this.autosyncPeers = const [],
  });

  final List<PeerUserData> connectedPeers;
  final List<String> autosyncPeers;

  @override
  List<Object?> get props => [connectedPeers, autosyncPeers];
}
