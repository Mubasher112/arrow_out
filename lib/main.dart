import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/local_game_repository.dart';
import 'services/audio_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation as required for primary mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final repository = LocalGameRepository();
  final audioService = AudioService(repository: repository);
  await audioService.init();

  runApp(ArrowPathApp(
    repository: repository,
    audioService: audioService,
  ));
}

class ArrowPathApp extends StatelessWidget {
  final LocalGameRepository repository;
  final AudioService audioService;

  const ArrowPathApp({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(
        repository: repository,
        audioService: audioService,
      ),
    );
  }
}
