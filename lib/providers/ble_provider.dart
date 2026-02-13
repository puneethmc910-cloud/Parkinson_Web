import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/ble_models.dart';
import '../services/alert_service.dart';
import '../services/bluetooth_service.dart';
import '../services/firebase_service.dart';

class BLEProvider extends ChangeNotifier {
  final BluetoothService bluetoothService;
  final FirebaseService firebaseService;
  final AlertService alertService;

  BLEConnectionStatus connectionStatus = BLEConnectionStatus.disconnected;
  ShoeData? latestData;
  bool mockMode = true;
  bool buzzerOn = false;
  bool ledOn = false;

  BLEProvider({
    required this.bluetoothService,
    required this.firebaseService,
    required this.alertService,
  }) {
    _init();
  }

  void _init() {
    bluetoothService.dataStream.listen((raw) {
      try {
        final jsonMap = json.decode(raw) as Map<String, dynamic>;
        latestData = ShoeData.fromJson(jsonMap);
        _handleAlerts(latestData!);
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to parse BLE JSON: $e');
        }
      }
    });

    bluetoothService.connectionStatusStream.listen((status) {
      connectionStatus = status;
      notifyListeners();
    });

    if (mockMode) {
      bluetoothService.startMockStream();
    }
  }

  Future<void> scanAndConnect() async {
    mockMode = false;
    await bluetoothService.scanAndConnect();
  }

  void enableMockMode() {
    mockMode = true;
    bluetoothService.startMockStream();
    notifyListeners();
  }

  void _handleAlerts(ShoeData data) {
    final alerts = data.alerts;
    if (alerts.freezing || alerts.imbalance) {
      buzzerOn = true;
      ledOn = true;
      final type = alerts.freezing ? 'Freezing' : 'Imbalance';
      final message =
          alerts.freezing ? 'Freezing of gait detected' : 'Balance issue';
      alertService.triggerAlert(
        type: type,
        severity: 'High',
        message: message,
      );
      firebaseService.logAlert(
        type: type,
        severity: 'High',
        message: message,
      );
    } else {
      buzzerOn = false;
      ledOn = false;
    }

    firebaseService.logSensorData(data);
    notifyListeners();
  }
}


