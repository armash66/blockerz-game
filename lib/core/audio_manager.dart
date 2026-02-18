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
    _configureAudioContext();
  }

  Future<void> _configureAudioContext() async {
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus
            .none, // Prevent SFX from stopping background music
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  // Settings
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
    if (isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  // Sound Files
  static const String _moveSound = 'audio/click.mp3';
  static const String _blockSound = 'audio/block.mp3';
  static const String _winSound = 'audio/win.mp3';
  static const String _clickSound = 'audio/click.mp3';
  static const String _themeMusic = 'audio/theme.mp3';

  Future<void> startMusic() async {
    if (isMusicEnabled) {
      try {
        if (_musicPlayer.state != PlayerState.playing) {
          await _musicPlayer.setReleaseMode(ReleaseMode.loop);
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

  // Helper for Web/Android focus wake-up
  Future<void> _ensureMusicPlaying() async {
    if (isMusicEnabled && _musicPlayer.state != PlayerState.playing) {
      try {
        await _musicPlayer.resume();
        if (_musicPlayer.state != PlayerState.playing) {
          await startMusic();
        }
      } catch (e) {
        await startMusic();
      }
    }
  }

  Future<void> playMove() async {
    _ensureMusicPlaying();
    if (isHapticsEnabled) await HapticFeedback.lightImpact();
    if (isSoundEnabled) {
      try {
        await _player.play(AssetSource(_moveSound.replaceFirst('assets/', '')));
      } catch (e) {
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
        // await _player.play(AssetSource(_powerupSound.replaceFirst('assets/', '')));
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
        // await _player.play(AssetSource(_loseSound.replaceFirst('assets/', '')));
      } catch (e) {
        // print('Error playing sound: $e');
      }
    }
  }

  Future<void> playClick() async {
    if (isHapticsEnabled) await HapticFeedback.lightImpact();
    _ensureMusicPlaying();
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
