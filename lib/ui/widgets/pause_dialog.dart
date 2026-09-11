import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../services/monetization_service.dart';
import '../theme/app_theme.dart';

class PauseDialog extends StatefulWidget {
  final int levelNumber;
  final AudioService audioService;
  final MonetizationService? monetizationService;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onLevelSelect;

  const PauseDialog({
    super.key,
    required this.levelNumber,
    required this.audioService,
    this.monetizationService,
    required this.onResume,
    required this.onRestart,
    required this.onLevelSelect,
  });

  @override
  State<PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends State<PauseDialog> {
  late bool _sound;
  late bool _music;

  @override
  void initState() {
    super.initState();
    _sound = widget.audioService.soundEnabled;
    _music = widget.audioService.musicEnabled;
  }

  void _confirmRestart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restart level?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your current progress on this level will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Restart'),
            onPressed: () {
              widget.audioService.playSound(SoundType.buttonClick);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              widget.onRestart();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppTheme.bgLight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME PAUSED - LEVEL ${widget.levelNumber}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.white24, height: 24),

            // Sound & Music Toggles
            SwitchListTile(
              title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
              secondary: Icon(_sound ? Icons.volume_up : Icons.volume_off, color: AppTheme.secondary),
              value: _sound,
              activeColor: AppTheme.secondary,
              onChanged: (val) async {
                await widget.audioService.toggleSound();
                setState(() => _sound = widget.audioService.soundEnabled);
              },
            ),
            SwitchListTile(
              title: const Text('Music', style: TextStyle(color: Colors.white)),
              secondary: Icon(_music ? Icons.music_note : Icons.music_off, color: AppTheme.primaryLight),
              value: _music,
              activeColor: AppTheme.primaryLight,
              onChanged: (val) async {
                await widget.audioService.toggleMusic();
                setState(() => _music = widget.audioService.musicEnabled);
              },
            ),

            const SizedBox(height: 16),

            // Resume
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  widget.audioService.playSound(SoundType.buttonClick);
                  Navigator.of(context).pop();
                  widget.onResume();
                },
              ),
            ),

            const SizedBox(height: 10),

            // Restart
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart Level'),
                onPressed: () => _confirmRestart(context),
              ),
            ),

            const SizedBox(height: 10),

            // Level Select
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Level Select'),
                onPressed: () {
                  widget.audioService.playSound(SoundType.buttonClick);
                  Navigator.of(context).pop();
                  widget.onLevelSelect();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
