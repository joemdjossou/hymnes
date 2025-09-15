import 'package:flutter/foundation.dart';
import '../../../core/services/midi_service.dart';

class MidiBloc extends ChangeNotifier {
  final MidiService _midiService = MidiService();

  // Getters
  MidiPlayerState get state => _midiService.state;
  VoiceTrack get currentTrack => _midiService.currentTrack;
  String? get currentMidiFile => _midiService.currentMidiFile;
  Duration get position => _midiService.position;
  Duration get duration => _midiService.duration;
  bool get isPlaying => _midiService.isPlaying;
  bool get isPaused => _midiService.isPaused;
  bool get isLoading => _midiService.isLoading;
  String? get lastError => _midiService.lastError;

  MidiBloc() {
    _midiService.addListener(_onMidiServiceChanged);
  }

  void _onMidiServiceChanged() {
    notifyListeners();
  }

  Future<void> initialize() async {
    await _midiService.initialize();
  }

  Future<void> playMidi(String midiFileName, {VoiceTrack track = VoiceTrack.all}) async {
    await _midiService.playMidi(midiFileName, track: track);
  }

  Future<void> playVoice(String midiFileName, VoiceTrack voice) async {
    await _midiService.playVoice(midiFileName, voice);
  }

  Future<void> pause() async {
    await _midiService.pause();
  }

  Future<void> resume() async {
    await _midiService.resume();
  }

  Future<void> stop() async {
    await _midiService.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _midiService.seekTo(position);
  }

  Future<void> setVolume(double volume) async {
    await _midiService.setVolume(volume);
  }

  Future<void> toggleLoop() async {
    await _midiService.toggleLoop();
  }

  void clearError() {
    _midiService.clearError();
  }

  String getTrackDisplayName(VoiceTrack track) {
    return _midiService.getTrackDisplayName(track);
  }

  String getTrackIcon(VoiceTrack track) {
    return _midiService.getTrackIcon(track);
  }

  @override
  void dispose() {
    _midiService.removeListener(_onMidiServiceChanged);
    super.dispose();
  }
}
