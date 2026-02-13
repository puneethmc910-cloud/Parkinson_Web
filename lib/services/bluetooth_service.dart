import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/ble_models.dart';

// TODO: Replace these with your actual nRF52840 service/characteristic UUIDs.
const Guid smartShoeServiceUuid =
    Guid('0000FFFF-0000-1000-8000-00805F9B34FB');
const Guid smartShoeNotifyCharUuid =
    Guid('0000FF01-0000-1000-8000-00805F9B34FB');

class BluetoothService {
  final _dataController = StreamController<String>.broadcast();
  final _statusController =
      StreamController<BLEConnectionStatus>.broadcast();

  Stream<String> get dataStream => _dataController.stream;
  Stream<BLEConnectionStatus> get connectionStatusStream =>
      _statusController.stream;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  Timer? _mockTimer;

  Future<void> scanAndConnect() async {
    _statusController.add(BLEConnectionStatus.scanning);

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );

    final results = await FlutterBluePlus.scanResults.firstWhere(
      (list) => list.isNotEmpty,
      orElse: () => [],
    );

    await FlutterBluePlus.stopScan();

    if (results.isEmpty) {
      _statusController.add(BLEConnectionStatus.disconnected);
      return;
    }

    _statusController.add(BLEConnectionStatus.connecting);
    final device = results.first.device;

    await device.connect(autoConnect: true).catchError((_) {});
    _connectedDevice = device;

    _connSub?.cancel();
    _connSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        _statusController.add(BLEConnectionStatus.connected);
      } else if (state == BluetoothConnectionState.disconnecting ||
          state == BluetoothConnectionState.disconnected) {
        _statusController.add(BLEConnectionStatus.disconnected);
      }
    });

    await _discoverAndListen(device);
  }

  Future<void> _discoverAndListen(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid == smartShoeServiceUuid) {
        for (final c in service.characteristics) {
          if (c.uuid == smartShoeNotifyCharUuid) {
            _notifyChar = c;
            await c.setNotifyValue(true);
            c.onValueReceived.listen((value) {
              if (value.isEmpty) return;
              final jsonString = utf8.decode(value);
              _dataController.add(jsonString);
            });
            return;
          }
        }
      }
    }
  }

  void startMockStream() {
    _mockTimer?.cancel();
    final rand = Random();
    _statusController.add(BLEConnectionStatus.connected);
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final jsonPayload = {
        'left': {
          'front_pressure': 25 + rand.nextInt(20),
          'heel_pressure': 30 + rand.nextInt(20),
          'battery': 80,
          'status': 'normal',
        },
        'right': {
          'front_pressure': 25 + rand.nextInt(20),
          'heel_pressure': 30 + rand.nextInt(20),
          'battery': 78,
          'status': 'warning',
        },
        'alerts': {
          'freezing': rand.nextInt(20) == 0,
          'imbalance': rand.nextInt(15) == 0,
        },
      };
      _dataController.add(jsonEncode(jsonPayload));
    });
  }

  void dispose() {
    _mockTimer?.cancel();
    _connSub?.cancel();
    _dataController.close();
    _statusController.close();
  }
}


