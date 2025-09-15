import 'package:flutter/material.dart';
import '../../core/models/hymn.dart';
import '../../core/repositories/hymn_repository.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/midi_player_widget.dart';

class HymnDetailScreen extends StatefulWidget {
  final String hymnId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  Hymn? _hymn;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHymn();
  }

  Future<void> _loadHymn() async {
    try {
      final hymn = await HymnRepository().getHymnByNumber(widget.hymnId);
      setState(() {
        _hymn = hymn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading hymn: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Loading...' : 'Hymn ${_hymn?.number ?? widget.hymnId}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorite functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _hymn == null
              ? const Center(
                  child: Text(
                    'Hymn not found',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hymn header
                      _buildHymnHeader(),
                      const SizedBox(height: 24),
                      
                      // MIDI Player
                      MidiPlayerWidget(
                        hymnNumber: _hymn!.number,
                        hymnTitle: _hymn!.title,
                      ),
                      const SizedBox(height: 24),
                      
                      // Hymn details
                      _buildHymnDetails(),
                      const SizedBox(height: 24),
                      
                      // Lyrics
                      _buildLyricsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHymnHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hymn ${_hymn!.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _hymn!.style,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hymn!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_hymn!.author.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'by ${_hymn!.author}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (_hymn!.composer.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Music: ${_hymn!.composer}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHymnDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hymn Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Number', _hymn!.number),
          _buildDetailRow('Title', _hymn!.title),
          if (_hymn!.author.isNotEmpty)
            _buildDetailRow('Author', _hymn!.author),
          if (_hymn!.composer.isNotEmpty)
            _buildDetailRow('Composer', _hymn!.composer),
          _buildDetailRow('Style', _hymn!.style),
          _buildDetailRow('MIDI File', _hymn!.midiFile),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lyrics,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Lyrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _hymn!.lyrics,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
