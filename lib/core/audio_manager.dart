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
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _initFuture = _init();
  }

  Future<void> _init() async {
    try {
      // SFX Player should be low latency
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);

      // Context for Music (Requests Focus, allows mixing)
      final musicContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );

      // Context for SFX (No Focus, never interrupts)
      final sfxContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none, // CRITICAL
        ),
      );

      await _musicPlayer.setAudioContext(musicContext);
      await _sfxPlayer.setAudioContext(sfxContext);
    } catch (e) {
      // Silently fail or log
    }
  }

  // Ensure init is done
  Future<void> ensureInitialized() async => await _initFuture;

  // Settings
  bool isMusicEnabled = true;
  bool isSfxEnabled = true;

  void toggleMusic() {
    playClick(); // Feedback for change
    isMusicEnabled = !isMusicEnabled;
    if (isMusicEnabled) {
      startMusic();
    } else {
      stopMusic();
    }
  }

  void toggleSfx() {
    isSfxEnabled = !isSfxEnabled;
    // Single feedback when turning ON
    if (isSfxEnabled) {
      playClick(); // Already includes HapticFeedback for ON state
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
    await ensureInitialized(); // Ensure contexts are set
    try {
      if (_musicPlayer.state != PlayerState.playing) {
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

  // Interaction sounds
  Future<void> playMove() async {
    if (!isSfxEnabled) return;
    await ensureInitialized();
    HapticFeedback.lightImpact();
    try {
      await _sfxPlayer.play(AssetSource(_moveSound));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> playBlock() async {
    if (!isSfxEnabled) return;
    await ensureInitialized();
    HapticFeedback.mediumImpact();
    try {
      await _sfxPlayer.play(AssetSource(_blockSound));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> playPowerup() async {
    if (!isSfxEnabled) return;
    HapticFeedback.mediumImpact();
  }

  Future<void> playWin() async {
    if (!isSfxEnabled) return;
    await ensureInitialized();
    HapticFeedback.heavyImpact();
    try {
      await _sfxPlayer.play(AssetSource(_winSound));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> playLose() async {
    if (!isSfxEnabled) return;
    HapticFeedback.heavyImpact();
  }

  Future<void> playClick() async {
    if (!isSfxEnabled) return;
    await ensureInitialized();
    HapticFeedback.lightImpact();
    try {
      // Avoid overlap stutter on fast clicks
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource(_clickSound));
    } catch (e) {
      // Ignore
    }
  }
}
