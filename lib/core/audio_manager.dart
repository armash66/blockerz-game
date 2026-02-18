import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  AudioManager._internal() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Settings (Could be moved to a SettingsService later)
  bool isSoundEnabled = true;
  bool isMusicEnabled = true;
  bool isHapticsEnabled = true;

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }

  void toggleMusic() {
    isMusicEnabled = !isMusicEnabled;
    if (isMusicEnabled) {
      startMusic();
    } else {
      stopMusic();
    }
  }

  void toggleHaptics() {
    isHapticsEnabled = !isHapticsEnabled;
    if (isHapticsEnabled) HapticFeedback.mediumImpact();
  }

  // Sound Files (Assumes files exist in assets/audio/)
  // static const String _moveSound = 'audio/move.mp3';
  static const String _blockSound = 'audio/block.mp3';
  // static const String _winSound = 'audio/win.mp3';
  // static const String _loseSound = 'audio/lose.mp3';
  static const String _clickSound = 'audio/click.mp3';
  static const String _themeMusic = 'audio/theme.mp3';

  Future<void> startMusic() async {
    if (isMusicEnabled) {
      try {
        if (_musicPlayer.state != PlayerState.playing) {
          await _musicPlayer
              .play(AssetSource(_themeMusic.replaceFirst('assets/', '')));
        }
      } catch (e) {
        // print('Error playing music: $e');
      }
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      // print('Error stopping music: $e');
    }
  }

  Future<void> playMove() async {
    if (isHapticsEnabled) await HapticFeedback.lightImpact();
    if (isSoundEnabled) {
      try {
        // await _player.play(AssetSource(_moveSound.replaceFirst('assets/', '')));
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
        // await _player
        //     .play(AssetSource(_powerupSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playWin() async {
    if (isHapticsEnabled) await HapticFeedback.heavyImpact();
    if (isSoundEnabled) {
      try {
        // await _player.play(AssetSource(_winSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playLose() async {
    if (isHapticsEnabled) await HapticFeedback.heavyImpact();
    if (isSoundEnabled) {
      try {
        // await _player.play(AssetSource(_loseSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playClick() async {
    if (isHapticsEnabled) await HapticFeedback.lightImpact();
    if (isSoundEnabled) {
      try {
        await _player
            .play(AssetSource(_clickSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }
}
