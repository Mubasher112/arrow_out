enum AppEnvironment {
  development,
  staging,
  production,
}

/// Central production environment configuration and feature flags container.
class AppConfig {
  final String appName;
  final String appId;
  final String version;
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final Map<String, bool> featureFlags;

  const AppConfig({
    required this.appName,
    required this.appId,
    required this.version,
    required this.environment,
    required this.apiBaseUrl,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.featureFlags,
  });

  bool isFeatureEnabled(String flag) => featureFlags[flag] ?? true;

  static const AppConfig production = AppConfig(
    appName: 'Arrow Path',
    appId: 'com.arrowgo.puzzle.arrow_path',
    version: '1.0.0+1',
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.arrowgo.com/v1',
    privacyPolicyUrl: 'https://arrowgo.com/privacy',
    termsOfServiceUrl: 'https://arrowgo.com/terms',
    featureFlags: {
      'ads': true,
      'rewardedAds': true,
      'purchases': true,
      'leaderboards': true,
      'friends': true,
      'events': true,
      'notifications': true,
      'analytics': true,
    },
  );

  static const AppConfig development = AppConfig(
    appName: 'Arrow Path [DEV]',
    appId: 'com.arrowgo.puzzle.arrow_path.dev',
    version: '1.0.0+1',
    environment: AppEnvironment.development,
    apiBaseUrl: 'https://dev-api.arrowgo.com/v1',
    privacyPolicyUrl: 'https://arrowgo.com/privacy',
    termsOfServiceUrl: 'https://arrowgo.com/terms',
    featureFlags: {
      'ads': true,
      'rewardedAds': true,
      'purchases': true,
      'leaderboards': true,
      'friends': true,
      'events': true,
      'notifications': true,
      'analytics': true,
    },
  );

  static const AppConfig defaultConfig = production;
}
