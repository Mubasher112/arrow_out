import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/config/environment.dart';

void main() {
  group('AppConfig Environment Flags', () {
    test('production configuration contains production parameters and flags', () {
      const config = AppConfig.production;

      expect(config.environment, AppEnvironment.production);
      expect(config.appName, 'Arrow Path');
      expect(config.appId, 'com.arrowgo.puzzle.arrow_path');
      expect(config.privacyPolicyUrl, 'https://arrowgo.com/privacy');
      expect(config.termsOfServiceUrl, 'https://arrowgo.com/terms');

      expect(config.isFeatureEnabled('ads'), isTrue);
      expect(config.isFeatureEnabled('purchases'), isTrue);
      expect(config.isFeatureEnabled('leaderboards'), isTrue);
    });
  });
}
