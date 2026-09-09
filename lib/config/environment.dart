enum Environment {
  debug,
  release,
}

class AppConfig {
  final String appName;
  final String appId;
  final String version;
  final Environment environment;

  const AppConfig({
    required this.appName,
    required this.appId,
    required this.version,
    required this.environment,
  });

  static const AppConfig defaultConfig = AppConfig(
    appName: 'Arrow Path',
    appId: 'com.arrowgo.puzzle.arrow_path',
    version: '1.0.0+1',
    environment: Environment.debug,
  );
}
