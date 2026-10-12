// TODO(#112): stubs.
class FailedUpgrade {
  const FailedUpgrade({
    required this.appVersion,
    required this.fromVersion,
    required this.reachedVersion,
    required this.failedStep,
    required this.targetVersion,
    required this.attempts,
    required this.error,
    this.snapshotPath,
    this.snapshotTakenAt,
  });

  static const maxAttempts = 3;

  final String appVersion;
  final int fromVersion;
  final int reachedVersion;
  final int failedStep;
  final int targetVersion;
  final int attempts;
  final String error;
  final String? snapshotPath;
  final DateTime? snapshotTakenAt;

  static FailedUpgrade? read(String documentsDir) => throw UnimplementedError();

  static String fromError(Object error) => throw UnimplementedError();
}

String failedUpgradeDetails(FailedUpgrade f, {required String platform}) =>
    throw UnimplementedError();
