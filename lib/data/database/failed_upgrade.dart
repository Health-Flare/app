import 'dart:convert';
import 'dart:io';

/// A data upgrade that failed, and how many times it has been tried on this
/// app version (#112). Kept as `.failed_upgrade` in the snapshots folder, so
/// it survives restoring the safety copy (a restore replaces the database,
/// not that folder). Spec: datastore.feature, "When an upgrade keeps
/// failing".
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

  /// Tried on the launch that failed and the next 2, then not again until
  /// a different app version is installed.
  static const maxAttempts = 3;

  static const fileName = '.failed_upgrade';

  /// Version and build of the app that tried. A different one resets
  /// [attempts].
  final String appVersion;

  /// Schema version before the first failed attempt.
  final int fromVersion;

  /// Schema version the data is on now: the steps before [failedStep] each
  /// committed on their own.
  final int reachedVersion;
  final int failedStep;
  final int targetVersion;
  final int attempts;

  /// One short line: [fromError].
  final String error;

  /// The safety copy from before the upgrade, or null if it's gone.
  final String? snapshotPath;
  final DateTime? snapshotTakenAt;

  bool get stopped => attempts >= maxAttempts;

  /// The error as one line of at most 200 characters. Exceptions from Isar
  /// and the migrations name types and steps, not records, but cut it short
  /// anyway: this is pasted into emails and issues.
  static String fromError(Object error) {
    final line = '${error.runtimeType}: $error'.split('\n').first.trim();
    return line.length <= 200 ? line : '${line.substring(0, 199)}…';
  }

  static File _file(String snapshotsDir) => File('$snapshotsDir/$fileName');

  /// The record in [snapshotsDir] (the snapshots folder), or null. The
  /// snapshot path is null when the file is no longer there.
  static FailedUpgrade? readFrom(String snapshotsDir) {
    final f = _file(snapshotsDir);
    if (!f.existsSync()) return null;
    try {
      final j = jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
      final copy = j['snapshot'] as String?;
      final copyPath = copy == null ? null : '$snapshotsDir/$copy';
      final exists = copyPath != null && File(copyPath).existsSync();
      final taken = j['snapshotTakenAt'] as String?;
      return FailedUpgrade(
        appVersion: j['appVersion']! as String,
        fromVersion: j['from']! as int,
        reachedVersion: j['reached']! as int,
        failedStep: j['failedStep']! as int,
        targetVersion: j['target']! as int,
        attempts: j['attempts']! as int,
        error: j['error']! as String,
        snapshotPath: exists ? copyPath : null,
        snapshotTakenAt: taken == null ? null : DateTime.parse(taken),
      );
    } catch (_) {
      // Unreadable: treat as no record, so the upgrade is tried again.
      return null;
    }
  }

  /// The record under [documentsDir]'s snapshots folder, or null.
  static FailedUpgrade? read(String documentsDir) =>
      readFrom('$documentsDir/snapshots');

  Future<void> writeTo(String snapshotsDir) async {
    await _file(snapshotsDir).writeAsString(
      jsonEncode({
        'appVersion': appVersion,
        'from': fromVersion,
        'reached': reachedVersion,
        'failedStep': failedStep,
        'target': targetVersion,
        'attempts': attempts,
        'error': error,
        'snapshot': snapshotPath?.split('/').last,
        'snapshotTakenAt': snapshotTakenAt?.toUtc().toIso8601String(),
      }),
    );
  }

  static Future<void> clear(String snapshotsDir) async {
    final f = _file(snapshotsDir);
    if (f.existsSync()) await f.delete();
  }
}

/// What "Copy details" puts on the clipboard: enough to tell which step
/// failed and why, and no health data.
String failedUpgradeDetails(FailedUpgrade f, {required String platform}) {
  String two(int n) => n.toString().padLeft(2, '0');
  final t = f.snapshotTakenAt?.toUtc();
  final taken = t == null
      ? 'none'
      : '${t.year}-${two(t.month)}-${two(t.day)} '
            '${two(t.hour)}:${two(t.minute)} UTC';
  return [
    'Health Flare ${f.appVersion}',
    'Platform: $platform',
    'Data version: ${f.reachedVersion} (updating from ${f.fromVersion} to '
        '${f.targetVersion})',
    'Failed step: ${f.failedStep}',
    'Attempts: ${f.attempts}',
    'Safety copy: $taken',
    'Error: ${f.error}',
  ].join('\n');
}
