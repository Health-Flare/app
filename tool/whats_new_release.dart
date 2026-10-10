// What's new release checks and drafting (#140). Pure functions over file
// contents so the unit tests can drive them; tool/rollup_changes.dart does
// the file I/O. Rules: docs/feature-releases.md.

import 'dart:convert';

const releasesJsonPath = 'assets/whats_new/releases.json';

const _maxHighlights = 4;
const _keys = {'version', 'date', 'draft', 'highlights', 'changes', 'guideId'};

final _version = RegExp(r'^\d+\.\d+\.\d+$');
final _date = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _guideId = RegExp(r'^[a-z0-9][a-z0-9-]*$');

class ReleaseError implements Exception {
  ReleaseError(this.message);
  final String message;
  @override
  String toString() => message;
}

/// True for `X.Y.Z` with no build number or suffix.
bool isReleaseVersion(String v) => _version.hasMatch(v);

/// `1.9.1` from pubspec.yaml's `version: 1.9.1+13`.
String readPubspecVersion(String pubspec) {
  final m = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+)',
    multiLine: true,
  ).firstMatch(pubspec);
  if (m == null) throw ReleaseError('pubspec.yaml has no version: X.Y.Z line');
  return m.group(1)!;
}

int _compare(String a, String b) {
  final pa = a.split('.').map(int.parse).toList();
  final pb = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final c = pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return 0;
}

/// Every bullet in CHANGELOG.md's Unreleased section, as plain one-line
/// text for "All changes": no leading "- ", wrapped lines joined, Markdown
/// bold and code marks removed. Placeholders are skipped.
List<String> changesFromUnreleased(String changelog) {
  final lines = changelog.split('\n');
  final start = lines.indexWhere((l) => l.trim() == '## [Unreleased]');
  if (start < 0) return const [];
  var end = lines.indexWhere((l) => l.startsWith('## ['), start + 1);
  if (end < 0) end = lines.length;

  final bullets = <String>[];
  for (final line in lines.sublist(start + 1, end)) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    if (t.startsWith('- ')) {
      bullets.add(t.substring(2));
    } else if (bullets.isNotEmpty) {
      bullets[bullets.length - 1] = '${bullets.last} $t';
    }
  }
  return [
    for (final b in bullets)
      if (b != '_Nothing yet._')
        b.replaceAll('**', '').replaceAll('`', '').trim(),
  ];
}

Map<String, Object?> _decode(String releasesJson) =>
    jsonDecode(releasesJson) as Map<String, Object?>;

List<Map<String, Object?>> _entries(Map<String, Object?> root) =>
    (root['releases'] as List).cast<Map<String, Object?>>();

/// Same layout as the committed file: 2-space indent, trailing newline.
String _encode(Map<String, Object?> root) =>
    '${const JsonEncoder.withIndent('  ').convert(root)}\n';

/// [releasesJson] with an entry for [version] that has `"draft": true`,
/// its `changes` set to [changes] and `guideId` set from [guides]. Highlights
/// already written for [version] are kept. The entry goes in newest-first
/// order.
String draftWhatsNew(
  String releasesJson, {
  required String version,
  required List<String> changes,
  required Set<String> guides,
}) {
  if (guides.length > 1) {
    throw ReleaseError(
      'This release moves things for ${guides.length} guides '
      '(${guides.join(', ')}). A release has one guide: give its fragments '
      'the same guide id, and cover every move as steps in that guide.',
    );
  }
  final root = _decode(releasesJson);
  final entries = _entries(root);
  final i = entries.indexWhere((e) => e['version'] == version);
  final old = i < 0 ? const <String, Object?>{} : entries[i];

  final guide = guides.isEmpty ? old['guideId'] as String? : guides.single;
  final entry = <String, Object?>{
    'version': version,
    'date': null,
    'draft': true,
    'highlights': old['highlights'] ?? <Object?>[],
    'changes': changes,
    'guideId': ?guide,
  };

  if (i >= 0) entries.removeAt(i);
  final at = entries.indexWhere(
    (e) =>
        e['version'] is String &&
        isReleaseVersion(e['version']! as String) &&
        _compare(e['version']! as String, version) < 0,
  );
  entries.insert(at < 0 ? entries.length : at, entry);
  return _encode(root);
}

/// Everything wrong with [releasesJson], or an empty list. With
/// [pubspecVersion], also checks that version is ready to ship: it has an
/// entry, the entry isn't a draft, and it has a date.
List<String> validateReleases(String releasesJson, {String? pubspecVersion}) {
  final Map<String, Object?> root;
  try {
    root = _decode(releasesJson);
  } on FormatException catch (e) {
    return ['not valid JSON: ${e.message}'];
  } on TypeError {
    return ['must be an object: {"releases": [...]}'];
  }
  final list = root['releases'];
  if (list is! List) return ['must be an object: {"releases": [...]}'];

  final errors = <String>[];
  final seen = <String>{};
  String? previous;
  for (final (n, raw) in list.indexed) {
    if (raw is! Map) {
      errors.add('entry ${n + 1} is not an object');
      continue;
    }
    final v = raw['version'];
    final at = v is String ? v : 'entry ${n + 1}';
    for (final k in raw.keys) {
      if (!_keys.contains(k)) {
        errors.add('$at: unknown key "$k" (allowed: ${_keys.join(', ')})');
      }
    }
    if (v is! String || !isReleaseVersion(v)) {
      errors.add('$at: "version" must look like 1.10.0');
      continue;
    }
    if (!seen.add(v)) errors.add('$v: listed twice');
    if (previous != null && _compare(v, previous) >= 0) {
      errors.add('$v: entries must be newest first ($v is after $previous)');
    }
    previous = v;

    final date = raw['date'];
    if (date != null && (date is! String || !_date.hasMatch(date))) {
      errors.add('$v: "date" must be YYYY-MM-DD or null');
    }
    final draft = raw['draft'];
    if (draft != null && draft != true) {
      errors.add('$v: "draft" is either true or left out');
    }

    final highlights = raw['highlights'] ?? const <Object?>[];
    if (highlights is! List) {
      errors.add('$v: "highlights" must be a list');
    } else {
      if (highlights.length > _maxHighlights) {
        errors.add(
          '$v: ${highlights.length} highlights; keep it to $_maxHighlights '
          'or fewer. The rest belong in "changes".',
        );
      }
      for (final h in highlights) {
        if (h is! Map ||
            h.keys.toSet().difference({'title', 'body'}).isNotEmpty ||
            h['title'] is! String ||
            h['body'] is! String ||
            (h['title'] as String).trim().isEmpty ||
            (h['body'] as String).trim().isEmpty) {
          errors.add(
            '$v: each highlight is {"title": "...", "body": "..."}, '
            'both filled in',
          );
          break;
        }
      }
    }

    final changes = raw['changes'] ?? const <Object?>[];
    if (changes is! List ||
        changes.any((c) => c is! String || c.trim().isEmpty)) {
      errors.add('$v: "changes" must be a list of non-empty strings');
    }

    final guide = raw['guideId'];
    if (guide != null && (guide is! String || !_guideId.hasMatch(guide))) {
      errors.add(
        '$v: "guideId" must be lowercase words joined by hyphens, '
        'e.g. track-and-care',
      );
    }
  }

  if (pubspecVersion != null) {
    final ready = list.whereType<Map>().where(
      (e) => e['version'] == pubspecVersion,
    );
    if (ready.isEmpty) {
      errors.add(
        "$pubspecVersion has no entry, but it's the version in pubspec.yaml. "
        'Run: dart run tool/rollup_changes.dart --write --version '
        '$pubspecVersion (an entry with no highlights is fine for a '
        'fix-only release).',
      );
    } else {
      final e = ready.first;
      if (e['draft'] == true) {
        errors.add(
          '$pubspecVersion is still a draft, and pubspec.yaml says it is '
          'shipping. Write its highlights (0 to 4), then delete "draft".',
        );
      }
      if (e['date'] == null) {
        errors.add(
          '$pubspecVersion has no date, and pubspec.yaml says it is '
          'shipping. scripts/release.sh sets it.',
        );
      }
    }
    // Shipped versions below the current one need dates too.
    for (final e in list.whereType<Map>()) {
      final v = e['version'];
      if (v is String &&
          isReleaseVersion(v) &&
          _compare(v, pubspecVersion) < 0 &&
          (e['date'] == null || e['draft'] == true)) {
        errors.add(
          '$v is older than pubspec.yaml but still undated or a draft',
        );
      }
    }
  }
  return errors;
}

/// [releasesJson] with [version]'s entry dated [date]. Throws
/// [ReleaseError], saying what to do, unless the entry exists, isn't a
/// draft, and the file is otherwise valid.
String stampRelease(String releasesJson, String version, String date) {
  if (!_date.hasMatch(date)) {
    throw ReleaseError('--date must be YYYY-MM-DD, got "$date"');
  }
  final errors = validateReleases(releasesJson);
  if (errors.isNotEmpty) {
    throw ReleaseError('$releasesJsonPath:\n  ${errors.join('\n  ')}');
  }
  final root = _decode(releasesJson);
  final entry = _entries(
    root,
  ).where((e) => e['version'] == version).firstOrNull;
  if (entry == null) {
    throw ReleaseError(
      "What's new has no entry for $version. Run:\n"
      '  dart run tool/rollup_changes.dart --write --version $version\n'
      'then write its highlights (none for a fix-only release), delete '
      '"draft", and commit.',
    );
  }
  if (entry['draft'] == true) {
    throw ReleaseError(
      "What's new for $version is still a draft. In $releasesJsonPath, "
      'write 0 to 4 highlights for it (none for a fix-only release), delete '
      'the "draft" line, and commit. Preview it with: '
      'bash scripts/whats_new.sh run upgrade',
    );
  }
  entry['date'] = date;
  return _encode(root);
}

/// The JSON for one entry, for previews.
String entryJson(String releasesJson, String version) {
  final e = _entries(
    _decode(releasesJson),
  ).firstWhere((e) => e['version'] == version);
  return const JsonEncoder.withIndent('  ').convert(e);
}
