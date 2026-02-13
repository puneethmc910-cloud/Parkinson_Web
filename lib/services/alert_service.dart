import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlertService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> triggerAlert({
    required String type,
    required String severity,
    required String message,
  }) async {
    // Simple tone vibration + audio beep
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    // Play a short beep (you can replace with an asset in assets/)
    try {
      await _player.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/beep_short.ogg',
        ),
      );
    } catch (_) {
      // Ignore audio errors in fallback mode
    }
  }
}


