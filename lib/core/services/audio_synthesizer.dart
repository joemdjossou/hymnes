import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../models/midi_models.dart';

class VoiceSynthesizer extends ChangeNotifier {
  final Map<String, List<AudioNote>> _activeNotes = {};
  final Map<String, double> _voiceVolumes = {};
  final Map<String, bool> _voiceMuted = {};

  Timer? _synthesisTimer;
  bool _isPlaying = false;
  double _currentTime = 0.0;
  double _playbackSpeed = 1.0;

  // Single Flutter Sound player for all voices
  FlutterSoundPlayer? _player;
  bool _isInitialized = false;
  Timer? _audioTimer;

  // Getters
  bool get isPlaying => _isPlaying;
  double get currentTime => _currentTime;
  double get playbackSpeed => _playbackSpeed;

  Map<String, double> get voiceVolumes => Map.unmodifiable(_voiceVolumes);
  Map<String, bool> get voiceMuted => Map.unmodifiable(_voiceMuted);

  VoiceSynthesizer() {
    _initializeVoices();
  }

  void _initializeVoices() {
    const voices = ['Soprano', 'Alto', 'Tenor', 'Bass'];
    for (final voice in voices) {
      _voiceVolumes[voice] = 1.0;
      _voiceMuted[voice] = false;
      _activeNotes[voice] = [];
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isInitialized = true;
      debugPrint('VoiceSynthesizer initialized successfully');
    } catch (e) {
      debugPrint('Error initializing VoiceSynthesizer: $e');
    }
  }

  /// Start synthesizing audio for the given MIDI sequence
  Future<void> startSynthesis(MIDISequence sequence) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isPlaying) {
      await stopSynthesis();
    }

    _isPlaying = true;
    _currentTime = 0.0;

    // Schedule all notes for playback
    _scheduleNotes(sequence);

    // Start the synthesis timer
    _startSynthesisTimer();

    notifyListeners();
  }

  /// Schedule all notes from the sequence for playback
  void _scheduleNotes(MIDISequence sequence) {
    for (final voice in sequence.voices) {
      _activeNotes[voice.name] = voice.notes
          .map((note) => AudioNote(
                note: note,
                startTime: note.startTime,
                endTime: note.startTime + note.duration,
                isActive: false,
              ))
          .toList();
    }
  }

  /// Start the synthesis timer
  void _startSynthesisTimer() {
    _synthesisTimer?.cancel();
    _synthesisTimer = Timer.periodic(
      Duration(milliseconds: 50), // Check every 50ms for smoother playback
      (timer) {
        if (_isPlaying) {
          _updateActiveNotes();
          _currentTime += 0.05 * _playbackSpeed;
          notifyListeners();
        }
      },
    );

    // Start audio generation timer
    _startAudioGeneration();
  }

  /// Start generating mixed audio
  void _startAudioGeneration() {
    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(
      Duration(
          milliseconds:
              800), // Generate audio every 800ms for better performance
      (timer) {
        if (_isPlaying) {
          _generateAndPlayMixedAudio();
        }
      },
    );
  }

  /// Update which notes are currently active
  void _updateActiveNotes() {
    for (final voiceName in _activeNotes.keys) {
      for (final audioNote in _activeNotes[voiceName]!) {
        final isNoteActive = _currentTime >= audioNote.startTime &&
            _currentTime <= audioNote.endTime;
        audioNote.isActive = isNoteActive;
      }
    }
  }

  /// Generate and play mixed audio for all active notes
  Future<void> _generateAndPlayMixedAudio() async {
    if (_player == null) return;

    try {
      // Get all currently active notes
      final activeNotes = <String, List<MIDINote>>{};
      for (final voiceName in _activeNotes.keys) {
        if (_voiceMuted[voiceName] == true) continue;

        final notes = _activeNotes[voiceName]!
            .where((audioNote) => audioNote.isActive)
            .map((audioNote) => audioNote.note)
            .toList();

        if (notes.isNotEmpty) {
          activeNotes[voiceName] = notes;
        }
      }

      if (activeNotes.isEmpty) {
        // Stop player if no notes are active
        await _player!.stopPlayer();
        return;
      }

      // Only restart if the active notes have changed significantly
      if (!_player!.isPlaying || _hasNotesChanged(activeNotes)) {
        await _player!.stopPlayer();

        // Generate shorter audio chunks (1 second for better performance)
        final mixedAudio = _generateContinuousAudio(activeNotes, 1.0);

        // Play the mixed audio
        await _player!.startPlayer(
          fromDataBuffer: mixedAudio,
          codec: Codec.pcm16,
          numChannels: 1,
          sampleRate: 22050, // Match the reduced sample rate
        );
      }
    } catch (e) {
      debugPrint('Error generating mixed audio: $e');
    }
  }

  /// Check if the active notes have changed significantly
  bool _hasNotesChanged(Map<String, List<MIDINote>> newActiveNotes) {
    // Simple implementation - in production, you'd compare note frequencies
    return true; // For now, always regenerate
  }

  /// Generate continuous mixed audio from all active notes (optimized)
  Uint8List _generateContinuousAudio(
      Map<String, List<MIDINote>> activeNotes, double duration) {
    const sampleRate = 22050; // Reduced sample rate for better performance
    final samples = (duration * sampleRate).round();
    final bytes = Uint8List(samples * 2);

    // Pre-calculate constants for optimization
    final sampleRateInv = 1.0 / sampleRate;
    final twoPi = 2 * pi;

    // Initialize with silence
    for (int i = 0; i < samples * 2; i++) {
      bytes[i] = 128; // Silence for unsigned 8-bit
    }

    // Mix all active notes directly to bytes (more efficient)
    for (final voiceName in activeNotes.keys) {
      final voiceVolume = _voiceVolumes[voiceName] ?? 1.0;

      for (final note in activeNotes[voiceName]!) {
        final frequency = midiToFrequency(note.noteNumber);
        final noteVolume = voiceVolume * (note.velocity / 127.0) * 0.2;

        // Pre-calculate phase increment for efficiency
        final phaseIncrement = twoPi * frequency * sampleRateInv;

        // Generate optimized sine wave
        for (int i = 0; i < samples; i++) {
          final time = i * sampleRateInv;

          // Simplified envelope (linear fade)
          double envelope = 1.0;
          if (time < 0.05) {
            envelope = time * 20; // Linear fade in
          } else if (time > duration - 0.05) {
            envelope = (duration - time) * 20; // Linear fade out
          }

          // Generate sine wave sample
          final phase = i * phaseIncrement;
          final amplitude = sin(phase) * noteVolume * envelope;

          // Convert to 8-bit unsigned and mix
          final sampleValue = (amplitude * 127).round().clamp(-127, 127);
          final currentSample = bytes[i * 2] - 128;
          final mixedSample =
              (currentSample + sampleValue).clamp(-127, 127) + 128;

          bytes[i * 2] = mixedSample;
          bytes[i * 2 + 1] = mixedSample; // Duplicate for 16-bit compatibility
        }
      }
    }

    return bytes;
  }

  /// Legacy method for backward compatibility
  Uint8List _generateMixedAudio(Map<String, List<MIDINote>> activeNotes) {
    return _generateContinuousAudio(activeNotes, 0.2);
  }

  /// Stop synthesis
  Future<void> stopSynthesis() async {
    _isPlaying = false;
    _synthesisTimer?.cancel();
    _synthesisTimer = null;
    _audioTimer?.cancel();
    _audioTimer = null;
    _currentTime = 0.0;

    // Stop player
    if (_player != null) {
      try {
        await _player!.stopPlayer();
      } catch (e) {
        debugPrint('Error stopping player: $e');
      }
    }

    // Clear all active notes
    for (final notes in _activeNotes.values) {
      for (final note in notes) {
        note.isActive = false;
      }
    }

    notifyListeners();
  }

  /// Pause synthesis
  void pauseSynthesis() {
    _isPlaying = false;
    _synthesisTimer?.cancel();
    notifyListeners();
  }

  /// Resume synthesis
  void resumeSynthesis() {
    if (!_isPlaying) {
      _isPlaying = true;
      _startSynthesisTimer();
      notifyListeners();
    }
  }

  /// Seek to a specific time
  void seekTo(double time) {
    _currentTime = time.clamp(0.0, double.infinity);
    _updateActiveNotes();
    notifyListeners();
  }

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed.clamp(0.1, 4.0);
  }

  /// Set volume for a specific voice
  void setVoiceVolume(String voiceName, double volume) {
    _voiceVolumes[voiceName] = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Mute/unmute a specific voice
  void toggleVoiceMute(String voiceName) {
    _voiceMuted[voiceName] = !(_voiceMuted[voiceName] ?? false);
    notifyListeners();
  }

  /// Set mute state for a specific voice
  void setVoiceMute(String voiceName, bool muted) {
    _voiceMuted[voiceName] = muted;
    notifyListeners();
  }

  /// Get currently active notes for a voice
  List<MIDINote> getActiveNotesForVoice(String voiceName) {
    final notes = _activeNotes[voiceName] ?? [];
    return notes
        .where((audioNote) => audioNote.isActive)
        .map((audioNote) => audioNote.note)
        .toList();
  }

  /// Get all currently active notes across all voices
  Map<String, List<MIDINote>> getAllActiveNotes() {
    final result = <String, List<MIDINote>>{};
    for (final voiceName in _activeNotes.keys) {
      result[voiceName] = getActiveNotesForVoice(voiceName);
    }
    return result;
  }

  /// Check if a voice is currently playing
  bool isVoicePlaying(String voiceName) {
    final notes = _activeNotes[voiceName] ?? [];
    return notes.any((audioNote) => audioNote.isActive);
  }

  /// Get the current frequency for a MIDI note number
  static double midiToFrequency(int noteNumber) {
    // A4 (MIDI note 69) = 440 Hz
    return 440.0 * pow(2, (noteNumber - 69) / 12);
  }

  /// Generate a simple sine wave for a note
  static List<double> generateSineWave(
      double frequency, double duration, int sampleRate) {
    final int samples = (duration * sampleRate).round();
    final List<double> wave = [];

    for (int i = 0; i < samples; i++) {
      final double time = i / sampleRate;
      final double amplitude = sin(2 * pi * frequency * time);
      wave.add(amplitude);
    }

    return wave;
  }

  /// Generate a triangle wave for a note
  static List<double> generateTriangleWave(
      double frequency, double duration, int sampleRate) {
    final int samples = (duration * sampleRate).round();
    final List<double> wave = [];

    for (int i = 0; i < samples; i++) {
      final double time = i / sampleRate;
      final double period = 1.0 / frequency;
      final double phase = (time % period) / period;

      double amplitude;
      if (phase < 0.5) {
        amplitude = 4 * phase - 1;
      } else {
        amplitude = 3 - 4 * phase;
      }

      wave.add(amplitude);
    }

    return wave;
  }

  /// Generate a square wave for a note
  static List<double> generateSquareWave(
      double frequency, double duration, int sampleRate) {
    final int samples = (duration * sampleRate).round();
    final List<double> wave = [];

    for (int i = 0; i < samples; i++) {
      final double time = i / sampleRate;
      final double period = 1.0 / frequency;
      final double phase = (time % period) / period;

      final double amplitude = phase < 0.5 ? 1.0 : -1.0;
      wave.add(amplitude);
    }

    return wave;
  }

  /// Generate a sawtooth wave for a note
  static List<double> generateSawtoothWave(
      double frequency, double duration, int sampleRate) {
    final int samples = (duration * sampleRate).round();
    final List<double> wave = [];

    for (int i = 0; i < samples; i++) {
      final double time = i / sampleRate;
      final double period = 1.0 / frequency;
      final double phase = (time % period) / period;

      final double amplitude = 2 * phase - 1;
      wave.add(amplitude);
    }

    return wave;
  }

  @override
  void dispose() {
    _synthesisTimer?.cancel();
    _audioTimer?.cancel();

    // Close player
    if (_player != null) {
      _player!.closePlayer();
    }

    super.dispose();
  }
}

/// Helper class to track audio notes during playback
class AudioNote {
  final MIDINote note;
  final double startTime;
  final double endTime;
  bool isActive;

  AudioNote({
    required this.note,
    required this.startTime,
    required this.endTime,
    this.isActive = false,
  });
}
