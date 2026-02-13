import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool audioCue = true;
  bool phoneVibration = true;
  bool visualAlert = true;
  bool shoeBuzzer = true;
  bool shoeLed = true;

  double pressureThreshold = 50;
  double freezingSensitivity = 0.5;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    audioCue = prefs.getBool('audioCue') ?? audioCue;
    phoneVibration = prefs.getBool('phoneVibration') ?? phoneVibration;
    visualAlert = prefs.getBool('visualAlert') ?? visualAlert;
    shoeBuzzer = prefs.getBool('shoeBuzzer') ?? shoeBuzzer;
    shoeLed = prefs.getBool('shoeLed') ?? shoeLed;
    pressureThreshold = prefs.getDouble('pressureThreshold') ?? pressureThreshold;
    freezingSensitivity =
        prefs.getDouble('freezingSensitivity') ?? freezingSensitivity;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audioCue', audioCue);
    await prefs.setBool('phoneVibration', phoneVibration);
    await prefs.setBool('visualAlert', visualAlert);
    await prefs.setBool('shoeBuzzer', shoeBuzzer);
    await prefs.setBool('shoeLed', shoeLed);
    await prefs.setDouble('pressureThreshold', pressureThreshold);
    await prefs.setDouble('freezingSensitivity', freezingSensitivity);
  }

  void setAudioCue(bool value) {
    audioCue = value;
    _save();
    notifyListeners();
  }

  void setPhoneVibration(bool value) {
    phoneVibration = value;
    _save();
    notifyListeners();
  }

  void setVisualAlert(bool value) {
    visualAlert = value;
    _save();
    notifyListeners();
  }

  void setShoeBuzzer(bool value) {
    shoeBuzzer = value;
    _save();
    notifyListeners();
  }

  void setShoeLed(bool value) {
    shoeLed = value;
    _save();
    notifyListeners();
  }

  void setPressureThreshold(double value) {
    pressureThreshold = value;
    _save();
    notifyListeners();
  }

  void setFreezingSensitivity(double value) {
    freezingSensitivity = value;
    _save();
    notifyListeners();
  }
}


