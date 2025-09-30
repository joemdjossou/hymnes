import 'package:flutter/material.dart';

class MIDINote {
  final int noteNumber; // 0-127 MIDI note number
  final String noteName; // "C4", "F#3", etc.
  final double startTime; // in seconds
  final double duration; // in seconds
  final int velocity; // 0-127
  final int channel; // MIDI channel (0-15)

  const MIDINote({
    required this.noteNumber,
    required this.noteName,
    required this.startTime,
    required this.duration,
    required this.velocity,
    required this.channel,
  });

  factory MIDINote.fromMidiEvent({
    required int noteNumber,
    required double startTime,
    required double duration,
    required int velocity,
    required int channel,
  }) {
    return MIDINote(
      noteNumber: noteNumber,
      noteName: _midiToNoteName(noteNumber),
      startTime: startTime,
      duration: duration,
      velocity: velocity,
      channel: channel,
    );
  }

  static String _midiToNoteName(int noteNumber) {
    const noteNames = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    ];
    final octave = (noteNumber / 12).floor() - 1;
    final noteIndex = noteNumber % 12;
    return '${noteNames[noteIndex]}$octave';
  }

  @override
  String toString() {
    return 'MIDINote(note: $noteName, start: ${startTime.toStringAsFixed(2)}s, duration: ${duration.toStringAsFixed(2)}s, velocity: $velocity)';
  }
}

class MIDIVoice {
  final String name; // "Soprano", "Alto", "Tenor", "Bass"
  final int channelNumber;
  final List<MIDINote> notes;
  final Color displayColor;
  bool isMuted;
  double volume;

  MIDIVoice({
    required this.name,
    required this.channelNumber,
    required this.notes,
    required this.displayColor,
    this.isMuted = false,
    this.volume = 1.0,
  });

  factory MIDIVoice.create({
    required String name,
    required int channelNumber,
    required List<MIDINote> notes,
  }) {
    return MIDIVoice(
      name: name,
      channelNumber: channelNumber,
      notes: notes,
      displayColor: _getVoiceColor(name),
      isMuted: false,
      volume: 1.0,
    );
  }

  static Color _getVoiceColor(String voiceName) {
    switch (voiceName.toLowerCase()) {
      case 'soprano':
        return Colors.pink;
      case 'alto':
        return Colors.blue;
      case 'tenor':
        return Colors.green;
      case 'bass':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
  }

  void setVolume(double newVolume) {
    volume = newVolume.clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'MIDIVoice(name: $name, channel: $channelNumber, notes: ${notes.length}, muted: $isMuted, volume: $volume)';
  }
}

class MIDISequence {
  final List<MIDIVoice> voices;
  final double totalDuration;
  final int ticksPerQuarter;
  final double tempo; // BPM
  final String fileName;

  const MIDISequence({
    required this.voices,
    required this.totalDuration,
    required this.ticksPerQuarter,
    required this.tempo,
    required this.fileName,
  });

  MIDIVoice? getVoiceByName(String name) {
    try {
      return voices.firstWhere((voice) => voice.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  MIDIVoice? getVoiceByChannel(int channel) {
    try {
      return voices.firstWhere((voice) => voice.channelNumber == channel);
    } catch (e) {
      return null;
    }
  }

  List<MIDINote> getAllNotesAtTime(double time) {
    final allNotes = <MIDINote>[];
    for (final voice in voices) {
      for (final note in voice.notes) {
        if (time >= note.startTime && time <= note.startTime + note.duration) {
          allNotes.add(note);
        }
      }
    }
    return allNotes;
  }

  @override
  String toString() {
    return 'MIDISequence(fileName: $fileName, duration: ${totalDuration.toStringAsFixed(2)}s, voices: ${voices.length}, tempo: $tempo BPM)';
  }
}
