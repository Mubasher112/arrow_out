/// Immutable model representing a Chapter/World containing 50 puzzle levels.
class ChapterDefinition {
  final int id;
  final String title;
  final String description;
  final int startLevel;
  final int endLevel;

  const ChapterDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.startLevel,
    required this.endLevel,
  });

  /// Pre-defined list of 10 chapters for levels 1 to 500.
  static const List<ChapterDefinition> allChapters = [
    ChapterDefinition(
      id: 1,
      title: 'First Steps',
      description: 'Learn the core arrow extraction mechanics.',
      startLevel: 1,
      endLevel: 50,
    ),
    ChapterDefinition(
      id: 2,
      title: 'Getting Tricky',
      description: 'Introduce multi-arrow blocking scenarios.',
      startLevel: 51,
      endLevel: 100,
    ),
    ChapterDefinition(
      id: 3,
      title: 'Think Ahead',
      description: 'Plan your sequence before tapping.',
      startLevel: 101,
      endLevel: 150,
    ),
    ChapterDefinition(
      id: 4,
      title: 'Brain Twist',
      description: 'Deeper dependency chains on 6x6 grids.',
      startLevel: 151,
      endLevel: 200,
    ),
    ChapterDefinition(
      id: 5,
      title: 'Path Finder',
      description: 'Find narrow exit rays through dense clusters.',
      startLevel: 201,
      endLevel: 250,
    ),
    ChapterDefinition(
      id: 6,
      title: 'Grid Master',
      description: 'Challenging 6x6 & 7x7 puzzles.',
      startLevel: 251,
      endLevel: 300,
    ),
    ChapterDefinition(
      id: 7,
      title: 'Arrow Logic',
      description: 'Intricate multi-step extraction rules.',
      startLevel: 301,
      endLevel: 350,
    ),
    ChapterDefinition(
      id: 8,
      title: 'Maze Solver',
      description: 'Navigate complex arrow interlocks.',
      startLevel: 351,
      endLevel: 400,
    ),
    ChapterDefinition(
      id: 9,
      title: 'Expert Extraction',
      description: 'Large 7x7 & 8x8 dense grids.',
      startLevel: 401,
      endLevel: 450,
    ),
    ChapterDefinition(
      id: 10,
      title: 'Mastermind',
      description: 'The ultimate 50 expert puzzles.',
      startLevel: 451,
      endLevel: 500,
    ),
  ];

  /// Get chapter by level number.
  static ChapterDefinition getChapterForLevel(int levelNumber) {
    return allChapters.firstWhere(
      (c) => levelNumber >= c.startLevel && levelNumber <= c.endLevel,
      orElse: () => allChapters.first,
    );
  }
}
