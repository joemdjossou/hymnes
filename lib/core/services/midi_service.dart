import 'dart:async';

import 'package:flutter/foundation.dart';
import 'midi_parser.dart';
import 'audio_synthesizer.dart';
import '../models/midi_models.dart';

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
  bool _isInitialized = false;
  String? _lastError;
  bool _isPlaying = false;
  
  // Real MIDI playback components
  final VoiceSynthesizer _synthesizer = VoiceSynthesizer();
  MIDISequence? _currentSequence;
  Map<String, List<MIDINote>> _currentActiveNotes = {};

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
      // Initialize the audio synthesizer
      _synthesizer.addListener(_onSynthesizerChanged);
      _isInitialized = true;
      debugPrint('MIDI Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing MIDI Service: $e');
      _state = MidiPlayerState.error;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  void _onSynthesizerChanged() {
    _isPlaying = _synthesizer.isPlaying;
    _position = Duration(milliseconds: (_synthesizer.currentTime * 1000).round());
    _currentActiveNotes = _synthesizer.getAllActiveNotes();
    notifyListeners();
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

      // Parse the MIDI file
      _currentSequence = await MIDIParser.parseMIDIFile(midiPath);
      _duration = Duration(milliseconds: (_currentSequence!.totalDuration * 1000).round());

      // Configure voice muting based on selected track
      _configureVoiceMuting(track);

      // Start synthesis
      await _synthesizer.startSynthesis(_currentSequence!);

      _state = MidiPlayerState.playing;
      _isPlaying = true;
      notifyListeners();

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

  void _configureVoiceMuting(VoiceTrack track) {
    // Unmute all voices first
    _synthesizer.setVoiceMute('Soprano', false);
    _synthesizer.setVoiceMute('Alto', false);
    _synthesizer.setVoiceMute('Tenor', false);
    _synthesizer.setVoiceMute('Bass', false);

    // Mute voices based on selected track
    switch (track) {
      case VoiceTrack.all:
        // All voices unmuted (already done above)
        break;
      case VoiceTrack.soprano:
        _synthesizer.setVoiceMute('Alto', true);
        _synthesizer.setVoiceMute('Tenor', true);
        _synthesizer.setVoiceMute('Bass', true);
        break;
      case VoiceTrack.alto:
        _synthesizer.setVoiceMute('Soprano', true);
        _synthesizer.setVoiceMute('Tenor', true);
        _synthesizer.setVoiceMute('Bass', true);
        break;
      case VoiceTrack.tenor:
        _synthesizer.setVoiceMute('Soprano', true);
        _synthesizer.setVoiceMute('Alto', true);
        _synthesizer.setVoiceMute('Bass', true);
        break;
      case VoiceTrack.bass:
        _synthesizer.setVoiceMute('Soprano', true);
        _synthesizer.setVoiceMute('Alto', true);
        _synthesizer.setVoiceMute('Tenor', true);
        break;
    }
  }


  Future<void> playVoice(String midiFileName, VoiceTrack voice) async {
    await playMidi(midiFileName, track: voice);
  }

  Future<void> pause() async {
    try {
      _synthesizer.pauseSynthesis();
      _state = MidiPlayerState.paused;
      _isPlaying = false;
      notifyListeners();
      debugPrint('MIDI playback paused');
    } catch (e) {
      debugPrint('Error pausing MIDI: $e');
    }
  }

  Future<void> resume() async {
    try {
      _synthesizer.resumeSynthesis();
      _state = MidiPlayerState.playing;
      _isPlaying = true;
      notifyListeners();
      debugPrint('MIDI playback resumed');
    } catch (e) {
      debugPrint('Error resuming MIDI: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _synthesizer.stopSynthesis();
      _position = Duration.zero;
      _currentMidiFile = null;
      _lastError = null;
      _state = MidiPlayerState.stopped;
      _isPlaying = false;
      _currentSequence = null;
      notifyListeners();
      debugPrint('MIDI playback stopped');
    } catch (e) {
      debugPrint('Error stopping MIDI: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      final timeSeconds = position.inMilliseconds / 1000.0;
      _synthesizer.seekTo(timeSeconds);
      _position = position;
      notifyListeners();
      debugPrint('MIDI playback seeked to: ${position.inSeconds} seconds');
    } catch (e) {
      debugPrint('Error seeking MIDI: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // Set volume for all voices
      _synthesizer.setVoiceVolume('Soprano', volume);
      _synthesizer.setVoiceVolume('Alto', volume);
      _synthesizer.setVoiceVolume('Tenor', volume);
      _synthesizer.setVoiceVolume('Bass', volume);
      debugPrint('MIDI volume set to: ${(volume * 100).toInt()}%');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> setVoiceVolume(String voiceName, double volume) async {
    try {
      _synthesizer.setVoiceVolume(voiceName, volume);
      debugPrint('Voice $voiceName volume set to: ${(volume * 100).toInt()}%');
    } catch (e) {
      debugPrint('Error setting voice volume: $e');
    }
  }

  Future<void> toggleVoiceMute(String voiceName) async {
    try {
      _synthesizer.toggleVoiceMute(voiceName);
      debugPrint('Voice $voiceName mute toggled');
    } catch (e) {
      debugPrint('Error toggling voice mute: $e');
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

  // Get currently active notes for visualization
  Map<String, List<MIDINote>> getCurrentActiveNotes() {
    return _currentActiveNotes;
  }

  // Check if a specific voice is currently playing
  bool isVoicePlaying(String voiceName) {
    return _synthesizer.isVoicePlaying(voiceName);
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
    _synthesizer.removeListener(_onSynthesizerChanged);
    _synthesizer.dispose();
    super.dispose();
  }
}
