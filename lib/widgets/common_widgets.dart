import 'package:flutter/material.dart';

import '../models/ble_models.dart';
import '../theme/app_theme.dart';

class ShoeCard extends StatelessWidget {
  final String title;
  final ShoeSideData? data;
  final BLEConnectionStatus connectionStatus;

  const ShoeCard({
    super.key,
    required this.title,
    required this.data,
    required this.connectionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = switch (connectionStatus) {
      BLEConnectionStatus.connected => 'Connected',
      BLEConnectionStatus.connecting => 'Connecting',
      BLEConnectionStatus.scanning => 'Scanning',
      BLEConnectionStatus.disconnected => 'Disconnected',
    };

    final battery = data?.battery ?? 0;
    final status = data?.status ?? 'normal';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.bluetooth, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.battery_full, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text('$battery%'),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(status.toUpperCase()),
              backgroundColor: status == 'normal'
                  ? Colors.green.shade100
                  : status == 'warning'
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
            ),
          ],
        ),
      ),
    );
  }
}

class PressureRow extends StatelessWidget {
  final String leg;
  final int front;
  final int heel;

  const PressureRow({
    super.key,
    required this.leg,
    required this.front,
    required this.heel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(leg)),
          Expanded(
            child: LinearProgressIndicator(
              value: front / 100,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text('$front')),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: heel / 100,
              backgroundColor: Colors.grey.shade200,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text('$heel')),
        ],
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  final ShoeAlerts alerts;

  const AlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    String text = 'Normal walking';
    Color color = Colors.green.shade100;
    IconData icon = Icons.check_circle;

    if (alerts.freezing) {
      text = 'Freezing detected';
      color = Colors.red.shade100;
      icon = Icons.warning;
    } else if (alerts.imbalance) {
      text = 'Balance issue detected';
      color = Colors.orange.shade100;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


