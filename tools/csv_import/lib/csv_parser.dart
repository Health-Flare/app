import 'dart:io';
import 'package:csv/csv.dart';

/// Supported entry types.
enum CsvEntryType { journal, symptom }

/// A single parsed row from the CSV.
class CsvRow {
  final int lineNumber;
  final CsvEntryType type;
  final DateTime date;
  final String? title;
  final String? body;
  final int? severity; // symptom only, 1-10

  const CsvRow({
    required this.lineNumber,
    required this.type,
    required this.date,
    this.title,
    this.body,
    this.severity,
  });
}

/// Parses a CSV file into a list of [CsvRow]s.
///
/// Expected header (case-insensitive):
///   type, date, title, body, severity
///
/// - [type] is optional; defaults to "journal".
/// - [date] is required; accepts YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.
/// - Unknown types are skipped with a warning printed to stderr.
/// - Rows missing [date] are skipped with a warning.
List<CsvRow> parseCsv(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw ArgumentError('File not found: $filePath');
  }

  final raw = file.readAsStringSync();
  final rows = const CsvToListConverter(eol: '\n').convert(raw);

  if (rows.isEmpty) {
    throw FormatException('CSV file is empty: $filePath');
  }

  // Parse header row (case-insensitive).
  final header = rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
  final colType     = header.indexOf('type');
  final colDate     = header.indexOf('date');
  final colTitle    = header.indexOf('title');
  final colBody     = header.indexOf('body');
  final colSeverity = header.indexOf('severity');

  if (colDate == -1) {
    throw FormatException('CSV is missing required "date" column. '
        'Header row found: ${header.join(', ')}');
  }

  final results = <CsvRow>[];

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    final lineNum = i + 1;

    // Skip blank rows.
    if (row.every((c) => c.toString().trim().isEmpty)) continue;

    // --- type ---
    final typeRaw = colType != -1 && colType < row.length
        ? row[colType].toString().trim().toLowerCase()
        : 'journal';
    final CsvEntryType entryType;
    switch (typeRaw.isEmpty ? 'journal' : typeRaw) {
      case 'journal':
        entryType = CsvEntryType.journal;
      case 'symptom':
        entryType = CsvEntryType.symptom;
      default:
        stderr.writeln('  ⚠  Line $lineNum: unknown type "$typeRaw" — skipped.');
        continue;
    }

    // --- date ---
    final dateRaw = colDate < row.length ? row[colDate].toString().trim() : '';
    if (dateRaw.isEmpty) {
      stderr.writeln('  ⚠  Line $lineNum: missing date — skipped.');
      continue;
    }
    final date = _parseDate(dateRaw);
    if (date == null) {
      stderr.writeln('  ⚠  Line $lineNum: cannot parse date "$dateRaw" — skipped. '
          'Expected YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.');
      continue;
    }

    // --- optional fields ---
    String? title;
    if (colTitle != -1 && colTitle < row.length) {
      final t = row[colTitle].toString().trim();
      if (t.isNotEmpty) title = t;
    }

    String? body;
    if (colBody != -1 && colBody < row.length) {
      final b = row[colBody].toString().trim();
      if (b.isNotEmpty) body = b;
    }

    int? severity;
    if (entryType == CsvEntryType.symptom &&
        colSeverity != -1 &&
        colSeverity < row.length) {
      final s = int.tryParse(row[colSeverity].toString().trim());
      if (s != null) {
        severity = s.clamp(1, 10);
      }
    }

    // Validate required fields per type.
    if (entryType == CsvEntryType.journal && body == null && title == null) {
      stderr.writeln('  ⚠  Line $lineNum: journal row has no title or body — skipped.');
      continue;
    }
    if (entryType == CsvEntryType.symptom && title == null) {
      stderr.writeln('  ⚠  Line $lineNum: symptom row has no name (title column) — skipped.');
      continue;
    }

    results.add(CsvRow(
      lineNumber: lineNum,
      type: entryType,
      date: date,
      title: title,
      body: body,
      severity: severity,
    ));
  }

  return results;
}

DateTime? _parseDate(String s) {
  // Try YYYY-MM-DD HH:MM:SS
  final full = DateTime.tryParse(s);
  if (full != null) return full;
  // Try YYYY-MM-DD
  final dateOnly = DateTime.tryParse('${s}T00:00:00');
  return dateOnly;
}
