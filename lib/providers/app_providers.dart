import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/alert_service.dart';
import '../services/bluetooth_service.dart';
import '../services/firebase_service.dart';
import 'ble_provider.dart';
import 'settings_provider.dart';
import 'session_provider.dart';

List<SingleChildWidget> buildAppProviders() {
  final firebaseService = FirebaseService();
  final bluetoothService = BluetoothService();
  final alertService = AlertService();

  return [
    Provider<FirebaseService>.value(value: firebaseService),
    Provider<BluetoothService>.value(value: bluetoothService),
    Provider<AlertService>.value(value: alertService),
    ChangeNotifierProvider<SessionProvider>(
      create: (_) => SessionProvider(firebaseService: firebaseService),
    ),
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(),
    ),
    ChangeNotifierProvider<BLEProvider>(
      create: (_) => BLEProvider(
        bluetoothService: bluetoothService,
        firebaseService: firebaseService,
        alertService: alertService,
      ),
    ),
  ];
}


