import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();

  // Settings (Could be moved to a SettingsService later)
  bool isSoundEnabled = true;
  bool isHapticsEnabled = true;

  // Sound Files (Assumes files exist in assets/audio/)
  static const String _moveSound = 'audio/move.mp3';
  static const String _blockSound = 'audio/block.mp3';
  static const String _powerupSound = 'audio/powerup.mp3';
  static const String _winSound = 'audio/win.mp3';
  static const String _loseSound = 'audio/lose.mp3';

  Future<void> playMove() async {
    if (isHapticsEnabled) await HapticFeedback.lightImpact();
    if (isSoundEnabled) {
      try {
        await _player.play(AssetSource(_moveSound.replaceFirst('assets/', '')));
      } catch (e) {
        // Ignore errors if file not found (common during dev)
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playBlock() async {
    if (isHapticsEnabled) await HapticFeedback.mediumImpact();
    if (isSoundEnabled) {
      try {
        await _player
            .play(AssetSource(_blockSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playPowerup() async {
    if (isHapticsEnabled) await HapticFeedback.mediumImpact();
    if (isSoundEnabled) {
      try {
        await _player
            .play(AssetSource(_powerupSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playWin() async {
    if (isHapticsEnabled) await HapticFeedback.heavyImpact();
    if (isSoundEnabled) {
      try {
        await _player.play(AssetSource(_winSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playLose() async {
    if (isHapticsEnabled) await HapticFeedback.heavyImpact();
    if (isSoundEnabled) {
      try {
        await _player.play(AssetSource(_loseSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  // Test method to verify integration without files
  void testHaptic() {
    HapticFeedback.vibrate();
  }
}
