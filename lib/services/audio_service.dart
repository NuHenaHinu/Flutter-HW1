import 'package:flutter/services.dart';

class AudioService {
  AudioService._private();
  static final AudioService instance = AudioService._private();

  /// Lightweight fallback using platform `SystemSound`.
  /// Replace with a full audio plugin when project dependencies are compatible.
  Future<void> playHit() async {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    await Future<void>.value();
  }

  Future<void> playScore() async {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    await Future<void>.value();
  }

  Future<void> playWin() async {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    await Future<void>.value();
  }
}
