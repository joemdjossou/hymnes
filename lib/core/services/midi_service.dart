import 'dart:async';

import 'package:flutter/foundation.dart';

enum MidiPlayerState {
  stopped,
  loading,
  playing,
  paused,
  error,
}

enum VoiceTrack {
  all,
  soprano,
  alto,
  tenor,
  bass,
}

class MidiService extends ChangeNotifier {
  static final MidiService _instance = MidiService._internal();
  factory MidiService() => _instance;
  MidiService._internal();

  MidiPlayerState _state = MidiPlayerState.stopped;
  VoiceTrack _currentTrack = VoiceTrack.all;
  String? _currentMidiFile;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _positionTimer;
  bool _isInitialized = false;
  String? _lastError;
  bool _isPlaying = false;

  // Getters
  MidiPlayerState get state => _state;
  VoiceTrack get currentTrack => _currentTrack;
  String? get currentMidiFile => _currentMidiFile;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _state == MidiPlayerState.paused;
  bool get isLoading => _state == MidiPlayerState.loading;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // For now, we'll use a simulated approach
      // In a real implementation, you would initialize a MIDI library here
      _isInitialized = true;
      debugPrint('MIDI Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing MIDI Service: $e');
      _state = MidiPlayerState.error;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> playMidi(String midiFileName,
      {VoiceTrack track = VoiceTrack.all}) async {
    if (!_isInitialized) await initialize();

    try {
      _state = MidiPlayerState.loading;
      _currentTrack = track;
      _currentMidiFile = midiFileName;
      _lastError = null;
      notifyListeners();

      // Construct the MIDI file path
      final midiPath = 'assets/midi/$midiFileName.mid';

      debugPrint('Attempting to play MIDI: $midiPath');

      // For now, we'll simulate MIDI playback
      // In a real implementation, you would load and play the MIDI file here
      await _simulateMidiPlayback(midiPath, track);

      debugPrint('Playing MIDI: $midiPath with track: ${track.name}');
    } catch (e) {
      debugPrint('Error playing MIDI: $e');
      _state = MidiPlayerState.error;
      _lastError = e.toString();

      // Provide a fallback message
      if (e.toString().contains('Cannot Open') ||
          e.toString().contains('not found')) {
        _lastError = 'MIDI file not found or could not be loaded. '
            'Please ensure the MIDI file exists in the assets/midi/ directory.';
      }

      notifyListeners();
    }
  }

  Future<void> _simulateMidiPlayback(String midiPath, VoiceTrack track) async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));

    // Set a simulated duration based on the track
    switch (track) {
      case VoiceTrack.all:
        _duration = const Duration(minutes: 3, seconds: 30);
        break;
      case VoiceTrack.soprano:
        _duration = const Duration(minutes: 3, seconds: 15);
        break;
      case VoiceTrack.alto:
        _duration = const Duration(minutes: 3, seconds: 20);
        break;
      case VoiceTrack.tenor:
        _duration = const Duration(minutes: 3, seconds: 25);
        break;
      case VoiceTrack.bass:
        _duration = const Duration(minutes: 3, seconds: 10);
        break;
    }

    _position = Duration.zero;

    // Start position timer for simulation
    _startPositionTimer();

    _state = MidiPlayerState.playing;
    _isPlaying = true;
    notifyListeners();

    debugPrint('Simulated MIDI playback started for track: ${track.name}');
  }

  Future<void> playVoice(String midiFileName, VoiceTrack voice) async {
    await playMidi(midiFileName, track: voice);
  }

  Future<void> pause() async {
    try {
      _state = MidiPlayerState.paused;
      _isPlaying = false;
      _stopPositionTimer();
      notifyListeners();
      debugPrint('MIDI playback paused');
    } catch (e) {
      debugPrint('Error pausing MIDI: $e');
    }
  }

  Future<void> resume() async {
    try {
      _state = MidiPlayerState.playing;
      _isPlaying = true;
      _startPositionTimer();
      notifyListeners();
      debugPrint('MIDI playback resumed');
    } catch (e) {
      debugPrint('Error resuming MIDI: $e');
    }
  }

  Future<void> stop() async {
    try {
      _position = Duration.zero;
      _currentMidiFile = null;
      _lastError = null;
      _state = MidiPlayerState.stopped;
      _isPlaying = false;
      _stopPositionTimer();
      notifyListeners();
      debugPrint('MIDI playback stopped');
    } catch (e) {
      debugPrint('Error stopping MIDI: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      _position = position;
      notifyListeners();
      debugPrint('MIDI playback seeked to: ${position.inSeconds} seconds');
    } catch (e) {
      debugPrint('Error seeking MIDI: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // In a real implementation, you would set the volume here
      debugPrint('MIDI volume set to: ${(volume * 100).toInt()}%');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> toggleLoop() async {
    try {
      // In a real implementation, you would toggle loop mode here
      debugPrint('MIDI loop mode toggled');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling loop: $e');
    }
  }

  void _startPositionTimer() {
    _stopPositionTimer();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state == MidiPlayerState.playing) {
        _position = _position + const Duration(milliseconds: 100);
        if (_position >= _duration) {
          _state = MidiPlayerState.stopped;
          _isPlaying = false;
          _stopPositionTimer();
        }
        notifyListeners();
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  String getTrackDisplayName(VoiceTrack track) {
    switch (track) {
      case VoiceTrack.all:
        return 'All Voices';
      case VoiceTrack.soprano:
        return 'Soprano';
      case VoiceTrack.alto:
        return 'Alto';
      case VoiceTrack.tenor:
        return 'Tenor';
      case VoiceTrack.bass:
        return 'Bass';
    }
  }

  String getTrackIcon(VoiceTrack track) {
    switch (track) {
      case VoiceTrack.all:
        return '🎵';
      case VoiceTrack.soprano:
        return '🎤';
      case VoiceTrack.alto:
        return '🎼';
      case VoiceTrack.tenor:
        return '🎹';
      case VoiceTrack.bass:
        return '🎸';
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPositionTimer();
    super.dispose();
  }
}
