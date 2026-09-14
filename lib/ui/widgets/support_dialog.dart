import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../services/support_service.dart';
import '../theme/app_theme.dart';

class SupportDialog extends StatefulWidget {
  final SupportService supportService;
  final AudioService audioService;
  final int? currentLevelId;

  const SupportDialog({
    super.key,
    required this.supportService,
    required this.audioService,
    this.currentLevelId,
  });

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  String _selectedCategory = 'Gameplay issue';
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Gameplay issue',
    'Account issue',
    'Purchase issue',
    'Bug report',
    'Suggestion',
    'Other',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_descController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    widget.audioService.playSound(SoundType.buttonClick);

    await widget.supportService.submitTicket(
      category: _selectedCategory,
      description: _descController.text.trim(),
      levelId: widget.currentLevelId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support ticket submitted successfully! Thank you.'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
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
          crossAlignment: CrossAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Feedback & Support',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 16),

            const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: AppTheme.cardBg,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.bgDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),

            const SizedBox(height: 12),

            const Text('Description', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe your issue or suggestion...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppTheme.bgDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                icon: const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Submitting...' : 'SUBMIT TICKET', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
