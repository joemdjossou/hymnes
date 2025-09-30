import 'package:flutter/material.dart';

import 'lib/core/services/midi_parser.dart';
import 'lib/core/services/midi_service.dart';

/// Test script to verify voice playback functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🎵 Testing Voice Playback Functionality');
  print('=====================================');

  try {
    // Initialize MIDI service
    final midiService = MidiService();
    await midiService.initialize();
    print('✅ MIDI Service initialized');

    // Test parsing a sample MIDI file
    print('\n📁 Testing MIDI parsing...');
    final sequence = await MIDIParser.parseMIDIFile('assets/midi/h1.mid');
    print('✅ MIDI sequence parsed successfully');
    print('   - File: ${sequence.fileName}');
    print('   - Duration: ${sequence.totalDuration.toStringAsFixed(1)}s');
    print('   - Tempo: ${sequence.tempo} BPM');
    print('   - Voices: ${sequence.voices.length}');

    for (final voice in sequence.voices) {
      print('   - ${voice.name}: ${voice.notes.length} notes');
    }

    // Test voice playback
    print('\n🎤 Testing voice playback...');

    // Test all voices
    print('Playing all voices...');
    await midiService.playMidi('h1', track: VoiceTrack.all);
    await Future.delayed(Duration(seconds: 3));

    // Test individual voices
    for (final track in [
      VoiceTrack.soprano,
      VoiceTrack.alto,
      VoiceTrack.tenor,
      VoiceTrack.bass
    ]) {
      print('Playing ${midiService.getTrackDisplayName(track)}...');
      await midiService.playVoice('h1', track);
      await Future.delayed(Duration(seconds: 2));
    }

    // Test controls
    print('\n🎛️ Testing controls...');
    await midiService.pause();
    print('✅ Pause works');

    await midiService.resume();
    print('✅ Resume works');

    await midiService.stop();
    print('✅ Stop works');

    print('\n🎉 All tests completed successfully!');
    print('You should have heard different musical tones for each voice.');
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}
