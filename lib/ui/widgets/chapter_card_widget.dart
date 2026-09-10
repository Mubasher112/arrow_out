import 'package:flutter/material.dart';
import '../../domain/models/chapter_definition.dart';
import '../theme/app_theme.dart';

class ChapterCardWidget extends StatelessWidget {
  final ChapterDefinition chapter;
  final int completedInChapter;
  final int starsInChapter;

  const ChapterCardWidget({
    super.key,
    required this.chapter,
    required this.completedInChapter,
    required this.starsInChapter,
  });

  @override
  Widget build(BuildContext context) {
    final totalLevels = chapter.endLevel - chapter.startLevel + 1;
    final progressRatio = (completedInChapter / totalLevels).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withAlpha(220),
            AppTheme.secondary.withAlpha(220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: Alignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAPTER ${chapter.id}: ${chapter.title.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.black,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppTheme.goldStar, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$starsInChapter / 150',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            chapter.description,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: Colors.black26,
              color: AppTheme.goldStar,
            ),
          ),
        ],
      ),
    );
  }
}
