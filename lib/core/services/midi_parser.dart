import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/midi_models.dart';

class MIDIParser {
  static const Map<int, String> _voiceNames = {
    0: 'Soprano',
    1: 'Alto',
    2: 'Tenor',
    3: 'Bass',
  };

  /// Parse a MIDI file from assets and extract the first 4 channels as SATB voices
  static Future<MIDISequence> parseMIDIFile(String assetPath) async {
    try {
      debugPrint('Parsing real MIDI file: $assetPath');

      // Load the actual MIDI file
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Parse the MIDI file structure
      final midiData = _parseBasicMIDI(bytes);

      // Create voices based on actual MIDI data
      final List<MIDIVoice> voices = [];

      for (int i = 0; i < 4; i++) {
        final voiceName = _voiceNames[i] ?? 'Voice ${i + 1}';
        final channelNotes = midiData['channels'][i] ?? <MIDINote>[];

        voices.add(MIDIVoice.create(
          name: voiceName,
          channelNumber: i,
          notes: channelNotes,
        ));
      }

      return MIDISequence(
        voices: voices,
        totalDuration: midiData['duration'] ?? 120.0, // Use actual duration
        ticksPerQuarter: midiData['ticksPerQuarter'] ?? 480,
        tempo: midiData['tempo'] ?? 120.0,
        fileName: assetPath.split('/').last,
      );
    } catch (e) {
      debugPrint('Error parsing MIDI file: $e');
      // Fallback to sample data if parsing fails
      return _createFallbackSequence(assetPath);
    }
  }

  /// Create fallback sequence if MIDI parsing fails
  static MIDISequence _createFallbackSequence(String assetPath) {
    final List<MIDIVoice> voices = [];

    for (int i = 0; i < 4; i++) {
      final voiceName = _voiceNames[i] ?? 'Voice ${i + 1}';
      voices.add(MIDIVoice.create(
        name: voiceName,
        channelNumber: i,
        notes: _createSampleNotes(i, 60 - (i * 12), 72 - (i * 12)),
      ));
    }

    return MIDISequence(
      voices: voices,
      totalDuration: 30.0,
      ticksPerQuarter: 480,
      tempo: 120.0,
      fileName: assetPath.split('/').last,
    );
  }

  /// Parse basic MIDI file structure
  static Map<String, dynamic> _parseBasicMIDI(Uint8List bytes) {
    try {
      // Check for MIDI header
      if (bytes.length < 14 ||
          String.fromCharCodes(bytes.sublist(0, 4)) != 'MThd') {
        throw Exception('Invalid MIDI file header');
      }

      // Read header information
      final headerLength = _readInt32(bytes, 4);
      final format = _readInt16(bytes, 8);
      final trackCount = _readInt16(bytes, 10);
      final ticksPerQuarter = _readInt16(bytes, 12);

      debugPrint(
          'MIDI: Format=$format, Tracks=$trackCount, TPQ=$ticksPerQuarter');

      // Parse tracks to find notes and calculate duration
      final tracks = <int, List<MIDINote>>{};
      final channels = <int, List<MIDINote>>{};
      double maxDuration = 0.0;
      double currentTempo = 120.0; // Default tempo

      int offset = 14; // Start after header

      for (int trackIndex = 0;
          trackIndex < trackCount && offset < bytes.length - 8;
          trackIndex++) {
        if (String.fromCharCodes(bytes.sublist(offset, offset + 4)) == 'MTrk') {
          final trackLength = _readInt32(bytes, offset + 4);
          final trackData = bytes.sublist(offset + 8, offset + 8 + trackLength);

          final trackResult =
              _parseTrack(trackData, ticksPerQuarter, currentTempo, trackIndex);

          // Store notes by track index for SATB mapping
          if (trackResult['notes'].isNotEmpty) {
            tracks[trackIndex] = trackResult['notes'] as List<MIDINote>;
          }

          // Also merge by channel for fallback
          for (final entry in trackResult['channelNotes'].entries) {
            final channel = entry.key as int;
            final notes = entry.value as List<MIDINote>;
            channels[channel] = (channels[channel] ?? [])..addAll(notes);
          }

          // Update tempo and max duration
          currentTempo = trackResult['tempo'] ?? currentTempo;
          maxDuration = max(maxDuration, trackResult['duration'] ?? 0.0);

          offset += 8 + trackLength;
        } else {
          break;
        }
      }

      // Map tracks to SATB voices (skip track 0 which is often tempo/meta)
      final voiceTracks = <int, List<MIDINote>>{};
      int voiceIndex = 0;
      for (int trackIndex = 1;
          trackIndex <= 4 && voiceIndex < 4;
          trackIndex++) {
        if (tracks[trackIndex]?.isNotEmpty == true) {
          voiceTracks[voiceIndex] = tracks[trackIndex]!;
          voiceIndex++;
        }
      }

      // Fallback to channel-based mapping if track-based doesn't work
      if (voiceTracks.length < 4) {
        for (int channel = 0; channel < 4 && voiceIndex < 4; channel++) {
          if (channels[channel]?.isNotEmpty == true &&
              !voiceTracks.containsValue(channels[channel])) {
            voiceTracks[voiceIndex] = channels[channel]!;
            voiceIndex++;
          }
        }
      }

      return {
        'channels': voiceTracks, // Use voice tracks instead of channels
        'duration': maxDuration > 0
            ? maxDuration
            : 120.0, // Default to 2 minutes if no duration found
        'ticksPerQuarter': ticksPerQuarter,
        'tempo': currentTempo,
      };
    } catch (e) {
      debugPrint('Error in basic MIDI parsing: $e');
      return {
        'channels': <int, List<MIDINote>>{},
        'duration': 120.0,
        'ticksPerQuarter': 480,
        'tempo': 120.0,
      };
    }
  }

  /// Parse a single MIDI track
  static Map<String, dynamic> _parseTrack(Uint8List trackData,
      int ticksPerQuarter, double baseTempo, int trackIndex) {
    final channelNotes = <int, List<MIDINote>>{};
    final trackNotes = <MIDINote>[];
    final activeNotes =
        <int, Map<int, double>>{}; // channel -> note -> startTime

    double currentTime = 0.0;
    double tempo = baseTempo;
    double maxTime = 0.0;

    int offset = 0;

    try {
      while (offset < trackData.length) {
        // Read variable length delta time
        final deltaResult = _readVariableLength(trackData, offset);
        final deltaTime = deltaResult['value'] as int;
        offset = deltaResult['offset'] as int;

        if (offset >= trackData.length) break;

        // Convert delta time to seconds
        currentTime += (deltaTime / ticksPerQuarter) * (60.0 / tempo);

        final eventType = trackData[offset];

        if (eventType >= 0x80 && eventType <= 0xEF) {
          // MIDI channel message
          final channel = eventType & 0x0F;
          final messageType = (eventType & 0xF0) >> 4;

          if (messageType == 0x9 && offset + 2 < trackData.length) {
            // Note On
            final note = trackData[offset + 1];
            final velocity = trackData[offset + 2];

            if (velocity > 0 && channel < 4) {
              // Only track first 4 channels
              activeNotes[channel] ??= {};
              activeNotes[channel]![note] = currentTime;
            }
            offset += 3;
          } else if (messageType == 0x8 && offset + 2 < trackData.length) {
            // Note Off
            final note = trackData[offset + 1];

            if (channel < 4 &&
                activeNotes[channel]?.containsKey(note) == true) {
              final startTime = activeNotes[channel]![note]!;
              final duration = currentTime - startTime;

              if (duration > 0.1) {
                // Only add notes longer than 100ms
                final midiNote = MIDINote.fromMidiEvent(
                  noteNumber: note,
                  startTime: startTime,
                  duration: duration,
                  velocity: 80,
                  channel: channel,
                );

                // Add to both collections
                channelNotes[channel] ??= [];
                channelNotes[channel]!.add(midiNote);
                trackNotes.add(midiNote);
              }

              activeNotes[channel]!.remove(note);
            }
            offset += 3;
          } else {
            offset += 3; // Skip other channel messages
          }
        } else if (eventType == 0xFF) {
          // Meta event
          if (offset + 1 < trackData.length) {
            final metaType = trackData[offset + 1];
            final lengthResult = _readVariableLength(trackData, offset + 2);
            final length = lengthResult['value'] as int;
            offset = lengthResult['offset'] as int;

            if (metaType == 0x51 &&
                length == 3 &&
                offset + 3 <= trackData.length) {
              // Tempo change
              final microsecondsPerQuarter = (trackData[offset] << 16) |
                  (trackData[offset + 1] << 8) |
                  trackData[offset + 2];
              tempo = 60000000.0 / microsecondsPerQuarter;
            }

            offset += length;
          } else {
            break;
          }
        } else {
          offset++; // Skip unknown events
        }

        maxTime = max(maxTime, currentTime);
      }
    } catch (e) {
      debugPrint('Error parsing track: $e');
    }

    return {
      'notes': trackNotes,
      'channelNotes': channelNotes,
      'duration': maxTime,
      'tempo': tempo,
    };
  }

  /// Read a 32-bit big-endian integer
  static int _readInt32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  /// Read a 16-bit big-endian integer
  static int _readInt16(Uint8List bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  /// Read a variable length quantity from MIDI
  static Map<String, int> _readVariableLength(Uint8List bytes, int offset) {
    int value = 0;
    int currentOffset = offset;

    while (currentOffset < bytes.length) {
      final byte = bytes[currentOffset++];
      value = (value << 7) | (byte & 0x7F);

      if ((byte & 0x80) == 0) break;
    }

    return {'value': value, 'offset': currentOffset};
  }

  /// Create sample notes for testing
  static List<MIDINote> _createSampleNotes(
      int channel, int startNote, int endNote) {
    final List<MIDINote> notes = [];
    final int noteCount = 6;
    final double noteDuration = 1.5; // 1.5 seconds per note
    final double noteSpacing = 2.0; // 2 seconds between notes

    for (int i = 0; i < noteCount; i++) {
      final int noteNumber = startNote + (i * 2) % (endNote - startNote);
      final double startTime = i * noteSpacing;

      notes.add(MIDINote.fromMidiEvent(
        noteNumber: noteNumber,
        startTime: startTime,
        duration: noteDuration,
        velocity: 80,
        channel: channel,
      ));
    }

    return notes;
  }

  /// Get available MIDI files from assets
  static Future<List<String>> getAvailableMIDIFiles() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap =
          const JsonDecoder().convert(manifestContent) as Map<String, dynamic>;

      return manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/midi/') && key.endsWith('.mid'))
          .map((String key) => key.split('/').last.replaceAll('.mid', ''))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Parse a MIDI file and return only specific voice
  static Future<MIDIVoice?> parseVoiceFromMIDI(
      String assetPath, String voiceName) async {
    try {
      final sequence = await parseMIDIFile(assetPath);
      return sequence.getVoiceByName(voiceName);
    } catch (e) {
      return null;
    }
  }
}
