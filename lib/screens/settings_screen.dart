import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Audio Cue'),
            value: settings.audioCue,
            onChanged: settings.setAudioCue,
          ),
          SwitchListTile(
            title: const Text('Phone Vibration'),
            value: settings.phoneVibration,
            onChanged: settings.setPhoneVibration,
          ),
          SwitchListTile(
            title: const Text('Visual Alert'),
            value: settings.visualAlert,
            onChanged: settings.setVisualAlert,
          ),
          SwitchListTile(
            title: const Text('Shoe Buzzer'),
            value: settings.shoeBuzzer,
            onChanged: settings.setShoeBuzzer,
          ),
          SwitchListTile(
            title: const Text('Shoe LED'),
            value: settings.shoeLed,
            onChanged: settings.setShoeLed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pressure Threshold',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: settings.pressureThreshold,
            min: 0,
            max: 100,
            divisions: 20,
            label: settings.pressureThreshold.toStringAsFixed(0),
            onChanged: settings.setPressureThreshold,
          ),
          const SizedBox(height: 8),
          const Text(
            'Freezing Detection Sensitivity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: settings.freezingSensitivity,
            min: 0,
            max: 1,
            divisions: 10,
            label: settings.freezingSensitivity.toStringAsFixed(1),
            onChanged: settings.setFreezingSensitivity,
          ),
        ],
      ),
    );
  }
}


