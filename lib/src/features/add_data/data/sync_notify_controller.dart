import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/src/data/services/bridgefy_service.dart';
import 'package:nav_stemi/src/features/add_data/data/peer_user_repository.dart';
import 'package:nav_stemi/src/features/export.dart';
import 'package:nav_stemi/src/utils/result.dart';

class SyncNotifyController extends AsyncNotifier<SyncNotifyState> {
  static final provider =
      AsyncNotifierProvider<SyncNotifyController, SyncNotifyState>(
    SyncNotifyController.new,
  );

  @override
  FutureOr<SyncNotifyState> build() async {
    // ref.listen(BridgefyService.eventsProvider, (previous, next) {});
    // final connectedPeers = await ref.watch(
    //   BridgefyService.connectedPeersProvider.future,
    // );

    // final autosyncPeers =
    //     ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    // final connectedPeersData = await ref
    //     .watch(PeerInfoRepository.provider)
    //     .fetchPeerUserData(connectedPeers);

    // final autosyncPeersData = await ref
    //     .watch(PeerInfoRepository.provider)
    //     .fetchPeerUserData(autosyncPeers);

    return SyncNotifyState(
      connectedPeers: [],
      autosyncPeers: [],
      patientInfo: ref.watch(patientInfoServiceProvider).patientInfoModel,
      timeMetrics: ref.watch(timeMetricsRepositoryProvider).getTimeMetrics(),
    );
  }

  Future<void> addAutosyncPeer(String deviceId) async {
    ref.read(sharedPreferencesRepositoryProvider).addAutoSyncPeer(deviceId);

    final autosyncPeers =
        ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    final autosyncPeersData = await ref
        .watch(PeerInfoRepository.provider)
        .fetchPeerUserData(autosyncPeers);

    state = AsyncValue.data(
      SyncNotifyState(
        connectedPeers: state.value?.connectedPeers ?? [],
        autosyncPeers: autosyncPeersData,
      ),
    );
  }

  Future<void> removeAutosyncPeer(String deviceId) async {
    ref.read(sharedPreferencesRepositoryProvider).removeAutoSyncPeer(deviceId);

    final autosyncPeers =
        ref.watch(sharedPreferencesRepositoryProvider).getAutoSyncPeers();

    final autosyncPeersData = await ref
        .watch(PeerInfoRepository.provider)
        .fetchPeerUserData(autosyncPeers);

    state = AsyncValue.data(
      SyncNotifyState(
        connectedPeers: state.value?.connectedPeers ?? [],
        autosyncPeers: autosyncPeersData,
      ),
    );
  }

  /// IMPORTANT: BridgefyService must be initialized and started before
  /// calling this method.
  Future<Result<String?, String>> onHandleSync(String? deviceId) async {
    if (deviceId == null) {
      return const Result.failure('Device ID is null');
    }

    final syncData = {
      'patientInfo': _patientInfo.toMap(),
      'timeMetrics': _timeMetrics.toMap(),
    };

    return Result.fromFuture(
      ref
          .read(BridgefyService.provider)
          .sendToDevice(deviceId: deviceId, data: syncData),
      onError: (error, stackTrace) {
        return error.toString();
      },
    );
  }

  PatientInfoService get _patientInfoRepository =>
      ref.read(patientInfoServiceProvider);

  PatientInfoModel get _patientInfo => _patientInfoRepository.patientInfoModel;

  TimeMetricsRepository get _timeMetricsRepository =>
      ref.read(timeMetricsRepositoryProvider);

  TimeMetricsModel get _timeMetrics =>
      _timeMetricsRepository.getTimeMetrics() ?? const TimeMetricsModel();
}

class SyncNotifyState extends Equatable {
  const SyncNotifyState({
    this.connectedPeers = const [],
    this.autosyncPeers = const [],
    this.patientInfo,
    this.timeMetrics,
  });

  final List<PeerUserData> connectedPeers;
  final List<PeerUserData> autosyncPeers;
  final PatientInfoModel? patientInfo;
  final TimeMetricsModel? timeMetrics;

  @override
  List<Object?> get props =>
      [connectedPeers, autosyncPeers, patientInfo, timeMetrics];
}
