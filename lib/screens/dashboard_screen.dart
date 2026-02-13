import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ble_models.dart';
import '../providers/ble_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/common_widgets.dart';
import 'analytics_screen.dart';
import 'daily_help_screen.dart';
import 'history_screen.dart';
import 'patient_profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BLEProvider>();
    final session = context.watch<SessionProvider>();
    final data = ble.latestData ??
        ShoeData(
          left: ShoeSideData(
            frontPressure: 0,
            heelPressure: 0,
            battery: 0,
            status: 'normal',
          ),
          right: ShoeSideData(
            frontPressure: 0,
            heelPressure: 0,
            battery: 0,
            status: 'normal',
          ),
          alerts: ShoeAlerts(freezing: false, imbalance: false),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(
              context,
              PatientProfileScreen.routeName,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ShoeCard(
                    title: 'Left Shoe',
                    data: data.left,
                    connectionStatus: ble.connectionStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShoeCard(
                    title: 'Right Shoe',
                    data: data.right,
                    connectionStatus: ble.connectionStatus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pressure (Front / Heel)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PressureRow(
                      leg: 'Left',
                      front: data.left.frontPressure,
                      heel: data.left.heelPressure,
                    ),
                    PressureRow(
                      leg: 'Right',
                      front: data.right.frontPressure,
                      heel: data.right.heelPressure,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AlertBanner(alerts: data.alerts),
            const SizedBox(height: 16),
            if (ble.buzzerOn || ble.ledOn)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ble.buzzerOn) const Chip(label: Text('Buzzer ON')),
                  const SizedBox(width: 8),
                  if (ble.ledOn) const Chip(label: Text('LED ON')),
                ],
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ble.scanAndConnect(),
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Scan & Connect'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AnalyticsScreen.routeName),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Analytics'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, HistoryScreen.routeName),
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, DailyHelpScreen.routeName),
              child: const Text('Daily Help & Tips'),
            ),
          ],
        ),
      ),
    );
  }
}


