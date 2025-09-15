import 'package:flutter/foundation.dart';

import '../../../core/models/hymn.dart';
import '../../../core/services/audio_service.dart';

class AudioBloc extends ChangeNotifier {
  final AudioService _audioService = AudioService();

  Hymn? _currentHymn;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isLooping = false;

  // Getters
  Hymn? get currentHymn => _currentHymn;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isLooping => _isLooping;
  double get progress => _audioService.progress;

  AudioBloc() {
    _initializeAudioService();
  }

  Future<void> _initializeAudioService() async {
    await _audioService.initialize();

    // Listen to audio service changes
    _audioService.addListener(_onAudioServiceChanged);
  }

  void _onAudioServiceChanged() {
    _isPlaying = _audioService.isPlaying;
    _isPaused = _audioService.isPaused;
    _isLoading = _audioService.isLoading;
    _position = _audioService.position;
    _duration = _audioService.duration;
    _volume = _audioService.volume;
    _isLooping = _audioService.isLooping;

    notifyListeners();
  }

  Future<void> playHymn(Hymn hymn, {String? voiceType}) async {
    try {
      _currentHymn = hymn;
      _isLoading = true;
      notifyListeners();

      String audioFile;
      switch (voiceType) {
        case 'soprano':
          audioFile = hymn.sopranoFile;
          break;
        case 'alto':
          audioFile = hymn.altoFile;
          break;
        case 'tenor':
          audioFile = hymn.tenorFile;
          break;
        case 'bass':
          audioFile = hymn.bassFile;
          break;
        default:
          audioFile = hymn.sopranoFile; // Default to soprano
      }

      await _audioService.play(audioFile);
    } catch (e) {
      debugPrint('Error playing hymn: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> resume() async {
    await _audioService.resume();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentHymn = null;
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  Future<void> toggleLoop() async {
    await _audioService.toggleLoop();
  }

  String formatDuration(Duration duration) {
    return _audioService.formatDuration(duration);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    super.dispose();
  }
}
