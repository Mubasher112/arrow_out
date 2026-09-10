import 'package:flutter/material.dart';
import '../../domain/models/chapter_definition.dart';
import '../theme/app_theme.dart';

class ChapterCompleteOverlay extends StatelessWidget {
  final ChapterDefinition chapter;
  final int totalStars;
  final VoidCallback onNextChapter;

  const ChapterCompleteOverlay({
    super.key,
    required this.chapter,
    required this.totalStars,
    required this.onNextChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.bgLight,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppTheme.goldStar, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 72, color: AppTheme.goldStar),
              const SizedBox(height: 12),
              Text(
                'CHAPTER ${chapter.id} COMPLETE!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.black,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                chapter.title,
                style: const TextStyle(fontSize: 16, color: AppTheme.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Stars: $totalStars / 1500',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'NEXT CHAPTER',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onNextChapter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
