import 'package:flutter/services.dart';

class AudioService {
  AudioService._private();
  static final AudioService instance = AudioService._private();

  /// Lightweight fallback using platform `SystemSound`.
  /// This avoids plugin compatibility issues on some emulator/AGP setups.
  Future<void> playHit() async {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    // no delay for hit (instant)
  }

  Future<void> playScore() async {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    // give the system a short moment to play the sound before UI changes
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  Future<void> playWin() async {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    // give the system a short moment to play the sound before dialog/navigation
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> dispose() async {
    // nothing to dispose for SystemSound fallback
  }
}
