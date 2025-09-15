import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/midi_service.dart';
import '../../features/midi/bloc/midi_bloc.dart';
import '../constants/app_colors.dart';

class MidiPlayerWidget extends StatelessWidget {
  final String hymnNumber;
  final String hymnTitle;

  const MidiPlayerWidget({
    super.key,
    required this.hymnNumber,
    required this.hymnTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MidiBloc>(
      builder: (context, midiBloc, child) {
        final isCurrentHymn = midiBloc.currentMidiFile == 'h$hymnNumber';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentHymn
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentHymn ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hymn info
              Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hymn $hymnNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          hymnTitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error message display
              if (isCurrentHymn && midiBloc.lastError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          midiBloc.lastError!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => midiBloc.clearError(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Voice track selection
              if (isCurrentHymn) ...[
                Text(
                  'Voice Selection:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VoiceTrack.values.map((track) {
                    final isSelected = midiBloc.currentTrack == track;
                    return GestureDetector(
                      onTap: () => midiBloc.playVoice('h$hymnNumber', track),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              midiBloc.getTrackIcon(track),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              midiBloc.getTrackDisplayName(track),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Progress bar
              if (isCurrentHymn && midiBloc.duration > Duration.zero) ...[
                Column(
                  children: [
                    Slider(
                      value: midiBloc.position.inMilliseconds.toDouble(),
                      max: midiBloc.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        midiBloc.seekTo(Duration(milliseconds: value.toInt()));
                      },
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(midiBloc.position),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(midiBloc.duration),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play/All Voices button
                  _buildControlButton(
                    context,
                    midiBloc,
                    icon: Icons.play_arrow,
                    label: 'All Voices',
                    onTap: () => midiBloc.playMidi('h$hymnNumber'),
                    isActive: isCurrentHymn &&
                        midiBloc.currentTrack == VoiceTrack.all,
                  ),

                  // Soprano button
                  _buildControlButton(
                    context,
                    midiBloc,
                    icon: Icons.mic,
                    label: 'Soprano',
                    onTap: () =>
                        midiBloc.playVoice('h$hymnNumber', VoiceTrack.soprano),
                    isActive: isCurrentHymn &&
                        midiBloc.currentTrack == VoiceTrack.soprano,
                  ),

                  // Alto button
                  _buildControlButton(
                    context,
                    midiBloc,
                    icon: Icons.music_note,
                    label: 'Alto',
                    onTap: () =>
                        midiBloc.playVoice('h$hymnNumber', VoiceTrack.alto),
                    isActive: isCurrentHymn &&
                        midiBloc.currentTrack == VoiceTrack.alto,
                  ),

                  // Tenor button
                  _buildControlButton(
                    context,
                    midiBloc,
                    icon: Icons.piano,
                    label: 'Tenor',
                    onTap: () =>
                        midiBloc.playVoice('h$hymnNumber', VoiceTrack.tenor),
                    isActive: isCurrentHymn &&
                        midiBloc.currentTrack == VoiceTrack.tenor,
                  ),

                  // Bass button
                  _buildControlButton(
                    context,
                    midiBloc,
                    icon: Icons.music_note,
                    label: 'Bass',
                    onTap: () =>
                        midiBloc.playVoice('h$hymnNumber', VoiceTrack.bass),
                    isActive: isCurrentHymn &&
                        midiBloc.currentTrack == VoiceTrack.bass,
                  ),
                ],
              ),

              // Play/Pause/Stop controls
              if (isCurrentHymn) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: midiBloc.isPlaying
                          ? () => midiBloc.pause()
                          : () => midiBloc.resume(),
                      icon: Icon(
                        midiBloc.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => midiBloc.stop(),
                      icon: Icon(
                        Icons.stop,
                        color: AppColors.error,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    MidiBloc midiBloc, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
