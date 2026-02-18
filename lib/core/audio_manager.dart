import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Future<void>? _initFuture;

  AudioManager._internal() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    try {
      // 1. Configure Global Context FIRST (Safe default for mixing)
      final globalContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // Default: no focus theft
        ),
      );

      await AudioPlayer.global.setAudioContext(globalContext);

      // 2. Music Player: Needs Focus & Media Content Type
      await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);

      await _musicPlayer.setAudioContext(globalContext.copyWith(
        android: globalContext.android.copyWith(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain, // Music wants focus
          stayAwake: true,
        ),
      ));

      // 3. SFX Player: Strictly NO focus, strictly mixing
      await _sfxPlayer.setPlayerMode(
          PlayerMode.mediaPlayer); // Avoid lowLatency bypass issues
      await _sfxPlayer.setAudioContext(globalContext.copyWith(
        android: globalContext.android.copyWith(
          audioFocus: AndroidAudioFocus.none, // CRITICAL: Never steal focus
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
    playClick(); // Tiny feedback

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
        await _musicPlayer.setVolume(1.0);
        await _musicPlayer.play(AssetSource(_themeMusic));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> playMove() async {
    if (!isSfxEnabled) return;
    HapticFeedback.lightImpact();
    _playSfx(_moveSound);
  }

  Future<void> playBlock() async {
    if (!isSfxEnabled) return;
    HapticFeedback.mediumImpact();
    _playSfx(_blockSound);
  }

  Future<void> playPowerup() async {
    if (!isSfxEnabled) return;
    HapticFeedback.mediumImpact();
  }

  Future<void> playWin() async {
    if (!isSfxEnabled) return;
    HapticFeedback.heavyImpact();
    _playSfx(_winSound);
  }

  Future<void> playLose() async {
    if (!isSfxEnabled) return;
    HapticFeedback.heavyImpact();
  }

  Future<void> playClick() async {
    if (!isSfxEnabled) return;
    HapticFeedback.lightImpact();
    _playSfx(_clickSound);
  }

  Future<void> _playSfx(String path) async {
    try {
      await ensureInitialized();
      // Ensure music is still playing (soft-resume if bumped)
      if (isMusicEnabled && _musicPlayer.state != PlayerState.playing) {
        _musicPlayer.resume();
      }
      await _sfxPlayer
          .stop(); // Clean stop before play to reset focus state for this player
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      // Ignore
    }
  }
}
