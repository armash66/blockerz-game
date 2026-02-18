import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Future<void>? _initFuture;
  bool _isMusicLooping = false;

  AudioManager._internal() {
    _initFuture = _init();

    // Self-healing: if music stops unexpectedly (e.g. system focus theft), resume it
    _musicPlayer.onPlayerStateChanged.listen((state) {
      if (isMusicEnabled && state == PlayerState.paused && _isMusicLooping) {
        // System likely paused us. Wait a beat and resume.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (isMusicEnabled && _musicPlayer.state == PlayerState.paused) {
            _musicPlayer.resume();
          }
        });
      }
    });
  }

  Future<void> _init() async {
    try {
      // 1. Music Player Configuration (Gain focus, allow mixing)
      await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);

      await _musicPlayer.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));

      // 2. SFX Player Configuration (DUCK instead of interrupting)
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _sfxPlayer.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus:
              AndroidAudioFocus.gainTransientMayDuck, // DUCK! No full pause.
        ),
      ));
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> ensureInitialized() async => await _initFuture;

  // Settings
  bool isMusicEnabled = true;
  bool isSfxEnabled = true;

  void toggleMusic() {
    isMusicEnabled = !isMusicEnabled;
    if (isMusicEnabled) {
      startMusic();
    } else {
      stopMusic();
    }
  }

  void toggleSfx() {
    isSfxEnabled = !isSfxEnabled;
    if (isSfxEnabled) {
      HapticFeedback.mediumImpact();
      playClick();
    }
  }

  // Sound Files
  static const String _moveSound = 'audio/click.mp3';
  static const String _blockSound = 'audio/block.mp3';
  static const String _winSound = 'audio/win.mp3';
  static const String _clickSound = 'audio/click.mp3';
  static const String _themeMusic = 'audio/theme.mp3';

  Future<void> startMusic() async {
    if (!isMusicEnabled) return;
    await ensureInitialized();
    try {
      if (_musicPlayer.state != PlayerState.playing) {
        _isMusicLooping = true;
        await _musicPlayer.setVolume(1.0);
        await _musicPlayer.play(AssetSource(_themeMusic));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> stopMusic() async {
    _isMusicLooping = false;
    try {
      await _musicPlayer.stop();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> playMove() async {
    if (!isSfxEnabled) return;
    HapticFeedback.lightImpact();
    _playLocalSfx(_moveSound);
  }

  Future<void> playBlock() async {
    if (!isSfxEnabled) return;
    HapticFeedback.mediumImpact();
    _playLocalSfx(_blockSound);
  }

  Future<void> playPowerup() async {
    if (!isSfxEnabled) return;
    HapticFeedback.mediumImpact();
  }

  Future<void> playWin() async {
    if (!isSfxEnabled) return;
    HapticFeedback.heavyImpact();
    _playLocalSfx(_winSound);
  }

  Future<void> playLose() async {
    if (!isSfxEnabled) return;
    HapticFeedback.heavyImpact();
  }

  Future<void> playClick() async {
    if (!isSfxEnabled) return;
    HapticFeedback.lightImpact();
    _playLocalSfx(_clickSound);
  }

  // Improved SFX helper with state-aware music management
  Future<void> _playLocalSfx(String path) async {
    try {
      await ensureInitialized();

      // On some buggy Android implementations, playing a second stream
      // might bypass the "duck" configuration. We check music state just in case.
      await _sfxPlayer.play(AssetSource(path));

      // Post-play check to recover music if the OS force-stopped it
      if (isMusicEnabled && _musicPlayer.state != PlayerState.playing) {
        _musicPlayer.resume();
      }
    } catch (e) {
      // Ignore
    }
  }
}
