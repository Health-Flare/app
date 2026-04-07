import 'dart:io';

import 'package:args/args.dart';

import 'package:health_flare_csv_import/csv_parser.dart';
import 'package:health_flare_csv_import/importer.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('profile',
        abbr: 'p',
        help: 'Profile name to import into (required, case-insensitive).')
    ..addOption('db',
        abbr: 'd',
        help: 'Path to healthflare.isar. Auto-detected on macOS if omitted.')
    ..addFlag('dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Preview what would be imported without writing anything.')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show this help message.');

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    _die('${e.message}\n\n${_usage(parser)}');
  }

  if (args['help'] as bool) {
    stdout.writeln(_usage(parser));
    exit(0);
  }

  final rest = args.rest;
  if (rest.isEmpty) {
    _die('Missing input CSV file.\n\n${_usage(parser)}');
  }
  if (rest.length > 1) {
    _die('Too many arguments — expected a single CSV file path.\n\n${_usage(parser)}');
  }

  final csvPath = rest.first;
  final profileName = args['profile'] as String?;
  if (profileName == null || profileName.isEmpty) {
    _die('--profile is required.\n\n${_usage(parser)}');
  }

  final dryRun = args['dry-run'] as bool;
  final dbPath = (args['db'] as String?) ?? _resolveDbPath();

  // ── Parse CSV ────────────────────────────────────────────────────────────
  stdout.writeln('');
  stdout.writeln('Health Flare CSV Import');
  stdout.writeln('──────────────────────────────');
  stdout.writeln('  CSV file  : $csvPath');
  stdout.writeln('  Database  : $dbPath');
  stdout.writeln('  Profile   : $profileName');
  if (dryRun) stdout.writeln('  Mode      : DRY RUN (no changes written)');
  stdout.writeln('');

  final List<CsvRow> rows;
  try {
    rows = parseCsv(csvPath);
  } on ArgumentError catch (e) {
    _die(e.message.toString());
  } on FormatException catch (e) {
    _die(e.message);
  }

  final journal = rows.where((r) => r.type == CsvEntryType.journal).length;
  final symptom = rows.where((r) => r.type == CsvEntryType.symptom).length;
  stdout.writeln('Parsed ${rows.length} rows  ($journal journal, $symptom symptom)');
  stdout.writeln('');

  if (rows.isEmpty) {
    stdout.writeln('Nothing to import.');
    exit(0);
  }

  // ── Import ───────────────────────────────────────────────────────────────
  final ImportResult result;
  try {
    result = await Importer.run(
      dbPath: dbPath,
      profileName: profileName,
      rows: rows,
      dryRun: dryRun,
    );
  } on ArgumentError catch (e) {
    _die(e.message.toString());
  } catch (e) {
    _die('Import failed: $e');
  }

  for (final w in result.warnings) {
    stderr.writeln('  ⚠  $w');
  }

  stdout.writeln('──────────────────────────────');
  if (dryRun) {
    stdout.writeln('DRY RUN — no changes written.');
    stdout.writeln('');
    stdout.writeln('  Would import : ${result.totalImported} records');
    stdout.writeln('    Journal    : ${result.journalImported}');
    stdout.writeln('    Symptom    : ${result.symptomImported}');
    stdout.writeln('  Duplicates   : ${result.skippedDuplicates} (already exist, would skip)');
  } else {
    stdout.writeln('Import complete.');
    stdout.writeln('');
    stdout.writeln('  Imported   : ${result.totalImported} records');
    stdout.writeln('    Journal  : ${result.journalImported}');
    stdout.writeln('    Symptom  : ${result.symptomImported}');
    stdout.writeln('  Skipped    : ${result.skippedDuplicates} duplicates');
  }
  stdout.writeln('');

  exit(0);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _usage(ArgParser parser) => '''
Usage: dart run bin/main.dart [options] <input.csv>

CSV format (header row required):
  type, date, title, body, severity

  type     optional  "journal" (default) or "symptom"
  date     required  YYYY-MM-DD or "YYYY-MM-DD HH:MM:SS"
  title    optional  Journal title / symptom name
  body     optional  Journal body text
  severity optional  Symptom severity 1-10

Examples:
  # Dry run to preview
  dart run bin/main.dart --profile "Sarah" --dry-run notes.csv

  # Real import (auto-detects macOS database path)
  dart run bin/main.dart --profile "Sarah" notes.csv

  # Specify database path explicitly
  dart run bin/main.dart --profile "Sarah" --db ~/mydata/healthflare.isar notes.csv

Options:
${parser.usage}''';

Never _die(String message) {
  stderr.writeln('Error: $message');
  exit(1);
}

String _resolveDbPath() {
  // macOS: sandboxed app stores data in its container.
  if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? '';
    final candidates = [
      '$home/Library/Containers/org.healthflare.app.healthflare/Data/Documents/healthflare.isar',
      '$home/Library/Application Support/org.healthflare.app.healthflare/healthflare.isar',
    ];
    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    stderr.writeln(
      'Warning: Could not auto-detect database path on macOS.\n'
      '  Tried:\n${candidates.map((c) => "    $c").join("\n")}\n'
      '  Pass --db <path> to specify the location manually.\n'
      '  Tip: run the app once on this Mac so the database is created,\n'
      '       then retry.',
    );
    exit(1);
  }

  // Other platforms: require explicit --db.
  stderr.writeln(
    'Error: --db is required on this platform.\n'
    'Pass the path to your healthflare.isar file.',
  );
  exit(1);
}
