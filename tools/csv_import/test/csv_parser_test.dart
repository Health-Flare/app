// Smoke test, run in CI (#177): catches a dependency bump that breaks the
// tool, or a parser that still compiles but reads the wrong fields.
import 'dart:io';

import 'package:health_flare_csv_import/csv_parser.dart';
import 'package:test/test.dart';

void main() {
  group('sample.csv', () {
    late List<CsvRow> rows;

    setUpAll(() => rows = parseCsv('sample.csv'));

    test('every data row is read', () {
      expect(rows, hasLength(9));
      expect(rows.where((r) => r.type == CsvEntryType.journal), hasLength(4));
      expect(rows.where((r) => r.type == CsvEntryType.symptom), hasLength(5));
    });

    test('journal fields', () {
      final first = rows.first;
      expect(first.date, DateTime(2024, 1, 15));
      expect(first.title, 'Rough day');
      expect(first.body, startsWith('Fatigue was really bad today.'));
    });

    test('symptom severities', () {
      expect(
        [
          for (final r in rows.where((r) => r.type == CsvEntryType.symptom))
            (r.title, r.severity),
        ],
        [
          ('Fatigue', 8),
          ('Headache', 5),
          ('Fatigue', 4),
          ('Fatigue', 10),
          ('Pain', 7),
        ],
      );
    });
  });

  test('Windows line endings and quoted commas', () {
    final dir = Directory.systemTemp.createTempSync('csv_import_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final f = File('${dir.path}/crlf.csv')
      ..writeAsStringSync(
        'type,date,title,body,severity\r\n'
        'journal,2024-02-01,A,"one, two",\r\n'
        'symptom,2024-02-01,Pain,,6\r\n',
      );
    final rows = parseCsv(f.path);
    expect(rows.first.body, 'one, two');
    expect(rows.last.severity, 6);
  });
}
