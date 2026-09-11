import 'package:flutter/material.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/monetization_service.dart';
import '../theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  final AudioService audioService;
  final GameRepository repository;
  final MonetizationService? monetizationService;
  final VoidCallback? onDataReset;

  const SettingsDialog({
    super.key,
    required this.audioService,
    required this.repository,
    this.monetizationService,
    this.onDataReset,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _sound;
  late bool _music;
  late bool _vibration;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _sound = widget.audioService.soundEnabled;
    _music = widget.audioService.musicEnabled;
    _vibration = widget.audioService.vibrationEnabled;
  }

  Future<void> _handleRemoveAds() async {
    final service = widget.monetizationService;
    if (service == null) return;

    setState(() => _isPurchasing = true);
    widget.audioService.playSound(SoundType.buttonClick);

    final success = await service.purchaseRemoveAds();
    if (mounted) {
      setState(() => _isPurchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Purchase Complete! Ads removed.' : 'Purchase failed.'),
          backgroundColor: success ? AppTheme.primary : AppTheme.accent,
        ),
      );
    }
  }

  Future<void> _handleRestorePurchases() async {
    final service = widget.monetizationService;
    if (service == null) return;

    setState(() => _isPurchasing = true);
    widget.audioService.playSound(SoundType.buttonClick);

    final success = await service.restorePurchases();
    if (mounted) {
      setState(() => _isPurchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Purchases restored successfully!' : 'No purchases found.'),
          backgroundColor: AppTheme.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.monetizationService;
    final adsRemoved = service?.adsRemoved ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppTheme.bgLight,
      child: SingleChildScrollView(
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
            const Divider(color: Colors.white24, height: 20),

            // Toggles
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
            SwitchListTile(
              title: const Text('Haptics', style: TextStyle(color: Colors.white)),
              secondary: Icon(_vibration ? Icons.vibration : Icons.smartphone, color: AppTheme.goldStar),
              value: _vibration,
              activeColor: AppTheme.goldStar,
              onChanged: (val) async {
                await widget.audioService.toggleVibration();
                setState(() => _vibration = widget.audioService.vibrationEnabled);
              },
            ),

            const Divider(color: Colors.white24, height: 20),

            // Remove Ads & Purchases Section
            if (!adsRemoved && service != null)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldStar, foregroundColor: Colors.black),
                  icon: const Icon(Icons.block_rounded, size: 20),
                  label: Text(_isPurchasing ? 'Processing...' : 'Remove Ads (\$1.99)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _isPurchasing ? null : _handleRemoveAds,
                ),
              )
            else if (adsRemoved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondary),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 18),
                    SizedBox(width: 8),
                    Text('Ads Removed (Ad-Free Active)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Restore Purchases & Privacy
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.restore_rounded, size: 18, color: Colors.white70),
                  label: const Text('Restore Purchases', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  onPressed: _isPurchasing ? null : _handleRestorePurchases,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.privacy_tip_rounded, size: 18, color: Colors.white70),
                  label: const Text('Privacy', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy: No personal ad data is collected or shared.')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accent),
              label: const Text('Reset All Progress', style: TextStyle(color: AppTheme.accent)),
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
