import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../domain/repositories/game_repository.dart';
import '../theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  final AudioService audioService;
  final GameRepository repository;
  final VoidCallback? onDataReset;

  const SettingsDialog({
    super.key,
    required this.audioService,
    required this.repository,
    this.onDataReset,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _sound;
  late bool _music;
  late bool _vibration;

  @override
  void initState() {
    super.initState() ;
    _sound = widget.audioService.soundEnabled;
    _music = widget.audioService.musicEnabled;
    _vibration = widget.audioService.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppTheme.bgLight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            SwitchListTile(
              title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
              secondary: Icon(
                _sound ? Icons.volume_up : Icons.volume_off,
                color: AppTheme.secondary,
              ),
              value: _sound,
              activeColor: AppTheme.secondary,
              onChanged: (val) async {
                await widget.audioService.toggleSound();
                setState(() => _sound = widget.audioService.soundEnabled);
              },
            ),
            SwitchListTile(
              title: const Text('Music', style: TextStyle(color: Colors.white)),
              secondary: Icon(
                _music ? Icons.music_note : Icons.music_off,
                color: AppTheme.primaryLight,
              ),
              value: _music,
              activeColor: AppTheme.primaryLight,
              onChanged: (val) async {
                await widget.audioService.toggleMusic();
                setState(() => _music = widget.audioService.musicEnabled);
              },
            ),
            SwitchListTile(
              title: const Text('Haptics', style: TextStyle(color: Colors.white)),
              secondary: Icon(
                _vibration ? Icons.vibration : Icons.smartphone,
                color: AppTheme.goldStar,
              ),
              value: _vibration,
              activeColor: AppTheme.goldStar,
              onChanged: (val) async {
                await widget.audioService.toggleVibration();
                setState(() => _vibration = widget.audioService.vibrationEnabled);
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accent),
              label: const Text(
                'Reset All Progress',
                style: TextStyle(color: AppTheme.accent),
              ),
              onPressed: () => _confirmReset(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgLight,
        title: const Text('Reset Progress?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to reset all unlocked levels and stars? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Reset'),
            onPressed: () async {
              await widget.repository.clearAllData();
              widget.audioService.playSound(SoundType.buttonClick);
              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                widget.onDataReset?.call();
              }
            },
          ),
        ],
      ),
    );
  }
}
