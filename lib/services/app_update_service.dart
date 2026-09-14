enum UpdateRequirement {
  none,
  optional,
  mandatory,
  maintenance,
}

/// Service checking update requirements and maintenance mode status.
class AppUpdateService {
  final String minimumSupportedVersion;
  final String currentAppVersion;
  final bool isMaintenanceMode;

  AppUpdateService({
    this.minimumSupportedVersion = '1.0.0',
    this.currentAppVersion = '1.0.0',
    this.isMaintenanceMode = false,
  });

  UpdateRequirement checkUpdateRequirement() {
    if (isMaintenanceMode) {
      return UpdateRequirement.maintenance;
    }
    // Version check logic
    if (currentAppVersion.compareTo(minimumSupportedVersion) < 0) {
      return UpdateRequirement.mandatory;
    }
    return UpdateRequirement.none;
  }
}
