# Flutter MIDI Four-Voice Player Development Prompt

## Project Objective

Create a Flutter mobile application that parses .mid files, extracts and sequences the various MIDI channels, partitions the first 4 channels into SATB (Soprano, Alto, Tenor, Bass) voices, and provides individual playback control for each voice.

## Core Requirements

### 1. MIDI File Processing

- **Parse .mid files** using a Flutter-compatible MIDI parsing library
- **Extract all available channels** from the MIDI file (0-15)
- **Sequence events** chronologically with precise timing
- **Separate the first 4 channels** and map them to:
  - Channel 0 → Soprano
  - Channel 1 → Alto
  - Channel 2 → Tenor
  - Channel 3 → Bass
- **Handle edge cases** where fewer than 4 channels exist

### 2. Data Structure Design

Create data models for:

```dart
class MIDIVoice {
  String name; // "Soprano", "Alto", "Tenor", "Bass"
  int channelNumber;
  List<MIDINote> notes;
  Color displayColor;
  bool isMuted;
  double volume;
}

class MIDINote {
  int noteNumber; // 0-127 MIDI note number
  String noteName; // "C4", "F#3", etc.
  double startTime; // in seconds
  double duration; // in seconds
  int velocity; // 0-127
}

class MIDISequence {
  List<MIDIVoice> voices;
  double totalDuration;
  int ticksPerQuarter;
  double tempo; // BPM
}
```

### 3. Audio Synthesis & Playback

- **Individual voice control**: Each voice can be played/paused/muted independently
- **Real-time synthesis**: Generate audio for each voice using different timbres
- **Synchronization**: All voices stay in sync when playing together
- **Volume control**: Individual volume sliders for each voice
- **Tempo control**: Global playback speed adjustment

### 4. User Interface Components

- **File picker** for selecting .mid files from device storage
- **Four-voice display** with visual note representation
- **Transport controls**: Play, Pause, Stop, Seek
- **Voice controls**: Individual mute/unmute, volume sliders
- **Timeline visualization** showing notes for each voice
- **Current playback position** indicator

### 5. Technical Implementation Details

#### Required Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  dart_midi: ^1.0.0 # For MIDI file parsing
  flutter_sound: ^9.2.13 # For audio playback/synthesis
  file_picker: ^5.2.5 # For file selection
  provider: ^6.0.5 # For state management
```

#### Key Classes to Implement

1. **MIDIParser**: Parse .mid files and extract channel data
2. **VoiceSequencer**: Convert MIDI events to timed note sequences
3. **AudioSynthesizer**: Generate audio for each voice
4. **PlaybackController**: Manage synchronized playback
5. **VoiceVisualization**: Display notes on timeline

### 6. Detailed Implementation Steps

#### Step 1: MIDI File Parsing

```dart
class MIDIParser {
  static Future<MIDISequence> parseMIDIFile(String filePath) async {
    // Parse .mid file using dart_midi
    // Extract channels 0-3
    // Convert MIDI events to MIDINote objects
    // Calculate precise timing in seconds
    // Return structured MIDISequence
  }
}
```

#### Step 2: Audio Synthesis Setup

```dart
class VoiceSynthesizer {
  late List<FlutterSoundPlayer> voicePlayers;

  Future<void> initializeSynthesizers() async {
    // Create 4 different synthesizer instances
    // Assign different timbres: sine, triangle, square, sawtooth
    // Set up individual volume controls
  }

  Future<void> playVoice(int voiceIndex, MIDINote note) async {
    // Convert MIDI note number to frequency
    // Trigger note with correct timing and duration
  }
}
```

#### Step 3: Synchronized Playback

```dart
class PlaybackController extends ChangeNotifier {
  Timer? playbackTimer;
  double currentTime = 0.0;
  bool isPlaying = false;

  Future<void> play() async {
    // Start synchronized playback of all unmuted voices
    // Update currentTime regularly for UI updates
    // Schedule note events with precise timing
  }

  void seekTo(double timeSeconds) {
    // Jump to specific time position
    // Update all voice players accordingly
  }
}
```

#### Step 4: Voice Visualization Widget

```dart
class VoiceTimelineWidget extends StatelessWidget {
  final MIDIVoice voice;
  final double currentTime;
  final double totalDuration;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VoiceTimelinePainter(
        voice: voice,
        currentTime: currentTime,
        totalDuration: totalDuration,
      ),
    );
  }
}
```

### 7. Advanced Features to Include

#### Musical Intelligence

- **Note name conversion**: MIDI numbers to musical notation (C4, F#3, etc.)
- **Key signature detection**: Identify the key of the piece
- **Chord analysis**: Show harmony when voices play together
- **Tempo change handling**: Support for variable tempo throughout piece

#### User Experience Enhancements

- **Waveform visualization**: Show audio waveform for each voice
- **Note highlighting**: Highlight currently playing notes
- **Loop sections**: Allow looping specific measures
- **Export functionality**: Save individual voices as separate audio files

#### Performance Optimizations

- **Lazy loading**: Load only visible portion of long pieces
- **Background processing**: Parse MIDI files without blocking UI
- **Memory management**: Efficiently handle large MIDI files
- **Audio buffering**: Smooth playback without glitches

### 8. Error Handling & Edge Cases

- **Invalid MIDI files**: Graceful error messages
- **Missing channels**: Handle files with fewer than 4 channels
- **Large files**: Progress indicators for parsing
- **Audio permissions**: Request microphone/audio permissions properly
- **Platform differences**: iOS vs Android audio handling

### 9. Testing Strategy

- **Unit tests**: MIDI parsing accuracy
- **Integration tests**: Audio synthesis functionality
- **Widget tests**: UI component behavior
- **Performance tests**: Large file handling
- **Device tests**: Multiple Android/iOS devices

### 10. Deliverables

1. **Complete Flutter project** with all source code
2. **Detailed documentation** explaining the architecture
3. **Example .mid files** for testing
4. **User manual** with screenshots
5. **Performance benchmarks** and optimization notes

## Success Criteria

- Successfully parse and display any standard .mid file
- Independently control playback of 4 separate voices
- Smooth, synchronized audio playback on mobile devices
- Intuitive UI that musicians can use effectively
- Stable performance with files up to 10MB
- Works on both iOS and Android platforms

## Optional Enhancements

- **MIDI recording**: Record new MIDI sequences
- **Voice editing**: Modify individual notes
- **Sharing functionality**: Share arrangements with others
- **Cloud storage**: Save/load from cloud services
- **Multiple file support**: Handle multiple MIDI files in a playlist

This prompt should provide a comprehensive roadmap for developing your Flutter MIDI four-voice player application.
