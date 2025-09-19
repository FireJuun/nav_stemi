import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bridgefy/bridgefy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class BridgefyService with BridgefyDelegate {
  BridgefyService({required Bridgefy bridgefy}) : _bridgefy = bridgefy;

  static final provider = Provider<BridgefyService>(
    (ref) => throw UnimplementedError(),
  );

  static final eventsProvider = StreamProvider.autoDispose<BridgefyEvent>((
    ref,
  ) {
    ref.onDispose(() {
      ref.watch(provider)._events.close();
    });

    return ref.watch(provider)._events.stream;
  });

  static final connectedPeersProvider =
      FutureProvider.autoDispose<List<String>>((ref) {
        ref.listen(
          eventsProvider.select((event) {
            return event is BridgefyDidConnect ||
                event is BridgefyDidDisconnect;
          }),
          (_, _) => ref.invalidateSelf(),
        );
        return ref.watch(provider).connectedPeers;
      });

  final _events = StreamController<BridgefyEvent>();

  // Getters
  Future<bool> get isInitialized => _bridgefy.isInitialized;
  Future<bool> get isStarted => _bridgefy.isStarted;

  Future<List<String>> get connectedPeers => _bridgefy.connectedPeers;

  /// Get current user ID
  Future<String> get currentUserId => _bridgefy.currentUserID;

  final Bridgefy _bridgefy;

  /// Initialize the Bridgefy SDK
  Future<void> initialize({required String apiKey}) async {
    try {
      final isInitialized = await _bridgefy.isInitialized;
      debugPrint('BridgefyService: Bridgefy isInitialized: $isInitialized');
      if (isInitialized) {
        await _bridgefy.destroySession();

        debugPrint(
          'BridgefyService: Cannot initialize - Bridgefy already initialized',
        );
      }

      await _requestPermissions();
      await _bridgefy.initialize(
        apiKey: apiKey,
        delegate: this,
        verboseLogging: kDebugMode,
      );

      debugPrint('BridgefyService: Bridgefy initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('BridgefyService: Failed to initialize Bridgefy: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Start the Bridgefy service with permission checks
  Future<bool> startService({String? userId}) async {
    try {
      var isInitialized = await _bridgefy.isInitialized;

      if (!isInitialized) {
        debugPrint('BridgefyService: Cannot start - service not initialized');
        return false;
      }

      if (await isStarted) {
        debugPrint('BridgefyService: Service already started');
        return true;
      }

      // Check permissions first
      var hasPermissions = await _hasPermissions();
      if (!hasPermissions) {
        debugPrint('BridgefyService: Requesting Bluetooth permissions...');
        hasPermissions = await _requestPermissions();

        if (!hasPermissions) {
          debugPrint(
            'BridgefyService: Cannot start - Bluetooth permissions denied',
          );
          return false;
        }
      }

      debugPrint('BridgefyService: Verifying Bridgefy is initialized...');

      isInitialized = await _bridgefy.isInitialized;

      if (!isInitialized) {
        debugPrint('BridgefyService: Cannot start - Bridgefy not initialized');
        return false;
      }

      debugPrint('BridgefyService: Starting Bridgefy service...');

      await _bridgefy.start(
        userId: userId,
        propagationProfile: BridgefyPropagationProfile.sparseNetwork,
      );

      debugPrint('BridgefyService: Bridgefy started successfully');
      return true;
    } catch (e) {
      debugPrint('BridgefyService: Failed to start Bridgefy: $e');
      return false;
    }
  }

  /// Stop the Bridgefy service
  Future<bool> stopService() async {
    if (!await isStarted) {
      debugPrint('BridgefyService: Service already stopped');
      return true;
    }

    try {
      await _bridgefy.stop();

      debugPrint('BridgefyService: Bridgefy stopped successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('BridgefyService: Failed to stop Bridgefy: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Send data to a specific device
  Future<String?> sendToDevice({
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    if (!await isStarted) {
      throw Exception('BridgefyService must be started before sending data');
    }

    try {
      final jsonData = jsonEncode(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonData));

      final messageId = await _bridgefy.send(
        data: bytes,
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.p2p,
          uuid: deviceId,
        ),
      );

      debugPrint(
        'BridgefyService: Sent data to device $deviceId with message ID: $messageId',
      );
      return messageId;
    } catch (e) {
      debugPrint(
        'BridgefyService: Failed to send data to device $deviceId: $e',
      );
      rethrow;
    }
  }

  /// Broadcast data to all connected devices
  Future<String?> broadcastData({required Map<String, dynamic> data}) async {
    if (!await isStarted) {
      throw Exception(
        'BridgefyService must be started before broadcasting data',
      );
    }

    try {
      final jsonData = jsonEncode(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonData));

      final messageId = await _bridgefy.send(
        data: bytes,
        transmissionMode: BridgefyTransmissionMode(
          type: BridgefyTransmissionModeType.broadcast,
          uuid: await _bridgefy.currentUserID,
        ),
      );

      debugPrint(
        'BridgefyService: Broadcasted data with message ID: $messageId',
      );
      return messageId;
    } catch (e) {
      debugPrint('BridgefyService: Failed to broadcast data: $e');
      rethrow;
    }
  }

  // BridgefyDelegate implementation
  @override
  void bridgefyDidConnect({required String userID}) {
    debugPrint('BridgefyService: Device connected: $userID');
    _events.add(BridgefyDidConnect(userID));
  }

  @override
  void bridgefyDidDisconnect({required String userID}) {
    debugPrint('BridgefyService: Device disconnected: $userID');
    _events.add(BridgefyDidDisconnect(userID));
  }

  @override
  void bridgefyDidReceiveData({
    required Uint8List data,
    required String messageId,
    required BridgefyTransmissionMode transmissionMode,
  }) {
    try {
      final jsonString = utf8.decode(data);
      final receivedData = jsonDecode(jsonString) as Map<String, dynamic>;

      debugPrint('BridgefyService: Received data: $receivedData');

      _events.add(BridgefyDidReceiveData(data, messageId, transmissionMode));
    } catch (e) {
      debugPrint('BridgefyService: Failed to parse received data: $e');
    }
  }

  @override
  void bridgefyDidSendMessage({required String messageID}) {
    debugPrint('BridgefyService: Message sent successfully: $messageID');

    _events.add(BridgefyDidSendMessage(messageID));
  }

  @override
  void bridgefyDidFailSendingMessage({
    required String messageID,
    BridgefyError? error,
  }) {
    debugPrint('BridgefyService: Failed to send message $messageID: $error');

    _events.add(
      BridgefyDidFailSendingMessage(
        messageID,
        error ?? BridgefyError(type: BridgefyErrorType.unknownException),
      ),
    );
  }

  @override
  void bridgefyDidStop() {
    debugPrint('BridgefyService: Bridgefy stopped');
    _events.add(BridgefyDidStop());
  }

  @override
  void bridgefyDidFailToStart({BridgefyError? error}) {
    debugPrint('BridgefyService: Failed to start Bridgefy: $error');
    _events.add(
      BridgefyDidFailToStart(
        error ?? BridgefyError(type: BridgefyErrorType.unknownException),
      ),
    );
  }

  @override
  void bridgefyDidFailToStop({BridgefyError? error}) {
    debugPrint('BridgefyService: Failed to stop Bridgefy: $error');
    _events.add(
      BridgefyDidFailToStop(
        error ?? BridgefyError(type: BridgefyErrorType.unknownException),
      ),
    );
  }

  @override
  void bridgefyDidDestroySession() {
    debugPrint('BridgefyService: Bridgefy session destroyed');
    _events.add(const BridgefyDidDestroySession());
  }

  @override
  void bridgefyDidFailToDestroySession() {
    debugPrint('BridgefyService: Failed to destroy Bridgefy session');
    _events.add(const BridgefyDidFailToDestroySession());
  }

  @override
  void bridgefyDidEstablishSecureConnection({required String userID}) {
    debugPrint(
      'BridgefyService: Established secure connection for user ID: $userID',
    );
    _events.add(BridgefyDidEstablishSecureConnection(userID));
  }

  @override
  void bridgefyDidFailToEstablishSecureConnection({
    required String userID,
    required BridgefyError error,
  }) {
    debugPrint(
      'BridgefyService: Failed to establish secure connection for user ID: $userID, error: $error',
    );
    _events.add(BridgefyDidFailToEstablishSecureConnection(userID, error));
  }

  @override
  void bridgefyDidSendDataProgress({
    required String messageID,
    required int position,
    required int of,
  }) {
    debugPrint('BridgefyService: Sending data progress: $position/$of');
  }

  @override
  void bridgefyDidStart({required String currentUserID}) {
    debugPrint(
      'BridgefyService: Bridgefy started with user ID: $currentUserID',
    );
    _events.add(BridgefyDidStart(currentUserID));
  }

  /// Check if all required Bluetooth permissions are granted
  Future<bool> _hasPermissions() async {
    final bluetoothStatus = await Permission.bluetooth.status;
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    final bluetoothAdvertiseStatus = await Permission.bluetoothAdvertise.status;
    final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    return bluetoothStatus.isGranted &&
        bluetoothScanStatus.isGranted &&
        bluetoothAdvertiseStatus.isGranted &&
        bluetoothConnectStatus.isGranted &&
        locationStatus.isGranted;
  }

  /// Request all required Bluetooth permissions
  Future<bool> _requestPermissions() async {
    debugPrint('BridgefyService: Requesting Bluetooth permissions...');

    try {
      // Request permissions one by one for better control
      final statuses = await [
        if (Platform.isIOS) ...[Permission.bluetooth],
        if (Platform.isAndroid) ...[
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
        ],
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      var allGranted = true;
      statuses.forEach((permission, status) {
        debugPrint('BridgefyService: $permission - $status');
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (allGranted) {
        debugPrint('BridgefyService: All Bluetooth permissions granted');
      } else {
        debugPrint('BridgefyService: Some Bluetooth permissions were denied');
      }

      return allGranted;
    } catch (e) {
      debugPrint('BridgefyService: Error requesting permissions: $e');
      return false;
    }
  }
}

sealed class BridgefyEvent {
  const BridgefyEvent();
}

final class BridgefyDidConnect extends BridgefyEvent {
  const BridgefyDidConnect(this.userID);
  final String userID;
}

final class BridgefyDidDisconnect extends BridgefyEvent {
  const BridgefyDidDisconnect(this.userID);
  final String userID;
}

final class BridgefyDidReceiveData extends BridgefyEvent {
  const BridgefyDidReceiveData(
    this.data,
    this.messageId,
    this.transmissionMode,
  );
  final Uint8List data;
  final String messageId;
  final BridgefyTransmissionMode transmissionMode;
}

final class BridgefyDidSendMessage extends BridgefyEvent {
  const BridgefyDidSendMessage(this.messageId);
  final String messageId;
}

final class BridgefyDidFailSendingMessage extends BridgefyEvent {
  const BridgefyDidFailSendingMessage(this.messageId, this.error);
  final String messageId;
  final BridgefyError error;
}

final class BridgefyDidStop extends BridgefyEvent {}

final class BridgefyDidFailToStart extends BridgefyEvent {
  const BridgefyDidFailToStart(this.error);
  final BridgefyError error;
}

final class BridgefyDidFailToStop extends BridgefyEvent {
  const BridgefyDidFailToStop(this.error);
  final BridgefyError error;
}

final class BridgefyDidDestroySession extends BridgefyEvent {
  const BridgefyDidDestroySession();
}

final class BridgefyDidFailToDestroySession extends BridgefyEvent {
  const BridgefyDidFailToDestroySession();
}

final class BridgefyDidEstablishSecureConnection extends BridgefyEvent {
  const BridgefyDidEstablishSecureConnection(this.userID);
  final String userID;
}

final class BridgefyDidFailToEstablishSecureConnection extends BridgefyEvent {
  const BridgefyDidFailToEstablishSecureConnection(this.userID, this.error);
  final String userID;
  final BridgefyError error;
}

final class BridgefyDidStart extends BridgefyEvent {
  const BridgefyDidStart(this.currentUserID);
  final String currentUserID;
}
