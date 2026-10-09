// Rolls changelog fragments in `changes/` into CHANGELOG.md's Unreleased
// section, and drafts the release's What's new entry in
// assets/whats_new/releases.json.
//
// Why: every PR used to add a line at the end of the same Unreleased
// subsection, so each merge left every other open PR conflicting on
// CHANGELOG.md. Each PR now adds its own file, which can't conflict; the
// fragments are rolled up into CHANGELOG.md when cutting a release.
//
// Usage (from the repo root):
//   dart run tool/rollup_changes.dart           # preview, changes nothing
//   dart run tool/rollup_changes.dart --check   # validate fragments and
//                                               # What's new (CI runs this
//                                               # through the unit tests)
//   dart run tool/rollup_changes.dart --write   # update CHANGELOG.md, draft
//                                               # What's new, delete the
//                                               # fragments
//
// `--version X.Y.Z` names the release. With --write it's the What's new
// entry to draft (default: the release being written, the newest entry with
// no date). With --check it's the version to check (default: pubspec.yaml's).
//
// Fragment format: see changes/README.md. Change kinds and What's new rules:
// docs/feature-releases.md.

import 'dart:convert';
import 'dart:io';

/// Keep a Changelog subsections, in the order they appear in the file.
const sections = [
  'Added',
  'Changed',
  'Deprecated',
  'Removed',
  'Fixed',
  'Security',
];

/// Sections that only ever hold fixes. A release with entries in no other
/// section, and no fragment of another kind, is fix-only.
const _fixSections = {'Fixed', 'Security'};

const _placeholder = '- _Nothing yet._';

/// What a change means for someone who used the app yesterday
/// (docs/feature-releases.md). Decides what has to ship with it.
enum ChangeKind {
  /// Something that was wrong now works. Changelog only.
  fix,

  /// Something new. Worth a highlight if it's worth knowing about.
  addition,

  /// An existing screen, control or default is somewhere else or does
  /// something else. Never ships without a guide.
  move,
}

/// One entry from a fragment file.
class Fragment {
  Fragment(this.fileName, this.section, this.bullets, {required this.kind});

  final String fileName;
  final String section;
  final ChangeKind kind;

  /// Each bullet's full text, including the leading "- " and any wrapped
  /// continuation lines.
  final List<String> bullets;
}

class FragmentError implements Exception {
  FragmentError(this.message);
  final String message;
  @override
  String toString() => message;
}

final _namePattern = RegExp(
  r'^([a-z0-9][a-z0-9-]*)\.(added|changed|deprecated|removed|fixed|security)'
  r'\.(fix|addition|move)\.md$',
);

/// Parses one fragment. [fileName] decides the section and kind; [content]
/// holds one or more Markdown bullets ("- "). Lines that don't start a
/// bullet continue the previous one.
Fragment parseFragment(String fileName, String content) {
  final m = _namePattern.firstMatch(fileName);
  if (m == null) {
    throw FragmentError(
      '$fileName: name must be <issue>-<slug>.<section>.<kind>.md, where '
      'section is one of ${sections.map((s) => s.toLowerCase()).join(', ')} '
      'and kind is one of ${ChangeKind.values.map((k) => k.name).join(', ')} '
      '(see docs/feature-releases.md)',
    );
  }
  final section = sections.firstWhere((s) => s.toLowerCase() == m.group(2));
  final kind = ChangeKind.values.byName(m.group(3)!);

  final bullets = <String>[];
  for (final raw in content.split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty || line.trimLeft().startsWith('<!--')) continue;
    if (line.startsWith('- ')) {
      bullets.add(line);
    } else if (bullets.isEmpty) {
      throw FragmentError(
        '$fileName: entries must be Markdown bullets starting with "- "',
      );
    } else {
      bullets[bullets.length - 1] = '${bullets.last}\n  ${line.trim()}';
    }
  }
  if (bullets.isEmpty) {
    throw FragmentError('$fileName: has no entries');
  }
  return Fragment(fileName, section, bullets, kind: kind);
}

/// Returns [changelog] with [fragments] added to the end of their
/// subsections under `## [Unreleased]`, replacing "_Nothing yet._".
/// Missing subsections are created in Keep a Changelog order.
String rollUp(String changelog, List<Fragment> fragments) {
  final lines = changelog.split('\n');
  final start = lines.indexWhere((l) => l.trim() == '## [Unreleased]');
  if (start < 0) {
    throw FragmentError('CHANGELOG.md has no "## [Unreleased]" heading');
  }
  var end = lines.indexWhere((l) => l.startsWith('## ['), start + 1);
  if (end < 0) end = lines.length;

  // Parse Unreleased into subsections, keeping their existing bullets.
  final existing = <String, List<String>>{};
  String? current;
  for (final line in lines.sublist(start + 1, end)) {
    final h = RegExp(r'^### (\w+)').firstMatch(line);
    if (h != null) {
      current = h.group(1);
      existing.putIfAbsent(current!, () => []);
    } else if (current != null && line.trim().isNotEmpty) {
      if (line.trim() == _placeholder) continue;
      existing[current]!.add(line);
    }
  }

  final byName = [...fragments]
    ..sort((a, b) => a.fileName.compareTo(b.fileName));
  for (final f in byName) {
    existing.putIfAbsent(f.section, () => []).addAll(f.bullets);
  }

  // Standard subsections first, in order, then any non-standard ones the
  // file already had, so nothing is dropped.
  final order = [
    ...sections,
    ...existing.keys.where((k) => !sections.contains(k)),
  ];
  final out = <String>['## [Unreleased]', ''];
  for (final s in order) {
    out.add('### $s');
    final items = existing[s] ?? const <String>[];
    out.addAll(items.isEmpty ? [_placeholder] : items);
    out.add('');
  }

  return [...lines.sublist(0, start), ...out, ...lines.sublist(end)].join('\n');
}

/// The `## [Unreleased]` section of [changelog], up to the next release
/// heading. Matches whole lines, so a mention of the heading inside the
/// header comment isn't mistaken for the section itself.
String unreleasedSection(String changelog) {
  final lines = changelog.split('\n');
  final start = lines.indexWhere((l) => l.trim() == '## [Unreleased]');
  if (start < 0) return '';
  var end = lines.indexWhere((l) => l.startsWith('## ['), start + 1);
  if (end < 0) end = lines.length;
  return lines.sublist(start, end).join('\n').trimRight();
}

// ---------------------------------------------------------------------------
// What's new (assets/whats_new/releases.json, docs/feature-releases.md)
// ---------------------------------------------------------------------------

const releasesPath = 'assets/whats_new/releases.json';

/// Marks text a person still has to write. The draft puts it where a
/// highlight or guide is needed; the release check refuses to ship it.
const todo = 'TODO';

bool _isTodo(Object? value) => value is String && value.startsWith(todo);

/// The app version in [pubspec] (`version: 1.9.1+13` gives `1.9.1`).
String appVersion(String pubspec) {
  final m = RegExp(
    r'^version:\s*([^\s+]+)',
    multiLine: true,
  ).firstMatch(pubspec);
  if (m == null) throw FragmentError('pubspec.yaml has no version');
  return m.group(1)!;
}

List<Map<String, dynamic>> _releases(String releasesJson) {
  try {
    final root = jsonDecode(releasesJson) as Map<String, dynamic>;
    return (root['releases'] as List).cast<Map<String, dynamic>>();
  } on Object catch (e) {
    throw FragmentError('$releasesPath could not be read: $e');
  }
}

String _encodeReleases(List<Map<String, dynamic>> releases) =>
    '${const JsonEncoder.withIndent('  ').convert({'releases': releases})}\n';

/// The release being written: the newest entry, if it has no date yet.
/// Fragments in changes/ are headed for it.
String? pendingVersion(String releasesJson) {
  final releases = _releases(releasesJson);
  if (releases.isEmpty || releases.first['date'] != null) return null;
  return releases.first['version'] as String;
}

/// Every entry in [changelog]'s Unreleased section, one line each, in
/// section order. This is the What's new "All changes" list.
List<String> unreleasedChanges(String changelog) => [
  for (final bullets in _unreleasedBullets(changelog).values)
    for (final b in bullets)
      b.substring(2).split('\n').map((l) => l.trim()).join(' '),
];

/// Unreleased bullets by section, without the "Nothing yet" placeholder.
/// Wrapped lines stay joined to their bullet.
Map<String, List<String>> _unreleasedBullets(String changelog) {
  final bySection = <String, List<String>>{};
  String? current;
  for (final line in unreleasedSection(changelog).split('\n').skip(1)) {
    final h = RegExp(r'^### (\w+)').firstMatch(line);
    if (h != null) {
      current = h.group(1);
      bySection.putIfAbsent(current!, () => []);
    } else if (current == null ||
        line.trim().isEmpty ||
        line.trim() == _placeholder) {
      continue;
    } else if (line.startsWith('- ')) {
      bySection[current]!.add(line);
    } else if (bySection[current]!.isNotEmpty) {
      final list = bySection[current]!;
      list[list.length - 1] = '${list.last}\n${line.trim()}';
    }
  }
  return bySection;
}

/// Whether the release needs highlights: anything that isn't a fix, either
/// in [fragments] or already in [changelog]'s Unreleased section (entries
/// from before fragments had a kind).
bool needsHighlights(String changelog, List<Fragment> fragments) {
  if (fragments.any((f) => f.kind != ChangeKind.fix)) return true;
  return _unreleasedBullets(
    changelog,
  ).entries.any((e) => !_fixSections.contains(e.key) && e.value.isNotEmpty);
}

/// Returns [releasesJson] with the entry for [version] drafted for release.
///
/// The entry is dated [date]. Anything a person already wrote in it is
/// kept; otherwise [changes] fill "All changes", [highlights] adds a TODO
/// highlight and [guide] (a move ships) a TODO guideId. A new entry goes on
/// top. Drafting a version that already has a date is refused.
String draftWhatsNew(
  String releasesJson, {
  required String version,
  required String date,
  required List<String> changes,
  required bool highlights,
  required bool guide,
}) {
  final releases = _releases(releasesJson);
  var entry = releases.where((r) => r['version'] == version).firstOrNull;
  if (entry != null && entry['date'] != null) {
    throw FragmentError(
      '$releasesPath: $version is already released (${entry['date']}). '
      'Pass --version with the version being released.',
    );
  }
  if (entry == null) {
    entry = <String, dynamic>{'version': version};
    releases.insert(0, entry);
  }
  entry['date'] = date;
  if ((entry['highlights'] as List? ?? const []).isEmpty) {
    entry['highlights'] = [
      if (highlights)
        {
          'title': todo,
          'body':
              '$todo: 2 to 4 highlights, plain language '
              '(docs/feature-releases.md). Delete this one if the release has '
              'nothing worth a dashboard card.',
        },
    ];
  }
  if ((entry['changes'] as List? ?? const []).isEmpty) {
    entry['changes'] = changes;
  }
  if (guide && entry['guideId'] == null) entry['guideId'] = todo;
  entry.putIfAbsent('guideId', () => null);
  return _encodeReleases(releases);
}

/// Problems that stop [version] shipping, each naming what to fix. Empty
/// when it's fine.
///
/// - [version] needs a What's new entry. A fix-only release can leave its
///   highlights empty.
/// - Nothing released (the [version] entry, or any dated entry) can hold a
///   TODO.
/// - A move fragment needs the release being written to name its guide.
List<String> checkWhatsNew({
  required String releasesJson,
  required String version,
  required List<Fragment> fragments,
}) {
  final List<Map<String, dynamic>> releases;
  try {
    releases = _releases(releasesJson);
  } on FragmentError catch (e) {
    return [e.message];
  }
  final problems = <String>[];

  if (!releases.any((r) => r['version'] == version)) {
    problems.add(
      '$releasesPath has no entry for $version, the version in '
      'pubspec.yaml. Run `dart run tool/rollup_changes.dart --write` to '
      'draft it (highlights may be empty for a fix-only release).',
    );
  }

  for (final r in releases) {
    if (r['version'] != version && r['date'] == null) continue;
    final highlights = (r['highlights'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    if (highlights.any((h) => _isTodo(h['title']) || _isTodo(h['body'])) ||
        _isTodo(r['guideId'])) {
      problems.add(
        '$releasesPath: ${r['version']} still has a $todo. Write its '
        'highlights (or delete the placeholder for a fix-only release) and '
        'name its guide.',
      );
    }
  }

  final moves = fragments.where((f) => f.kind == ChangeKind.move);
  if (moves.isNotEmpty) {
    final pending = releases.firstOrNull;
    final guideId = pending != null && pending['date'] == null
        ? pending['guideId']
        : null;
    if (guideId == null || _isTodo(guideId)) {
      for (final f in moves) {
        problems.add(
          'changes/${f.fileName} is a move, and no move ships without a '
          'guide. Name it in guideId on the release being written (the '
          'newest entry in $releasesPath, with "date": null), or keep the '
          'change behind its flag.',
        );
      }
    }
  }
  return problems;
}

/// Loads and validates every fragment in [dir], ignoring README.md.
List<Fragment> loadFragments(Directory dir) {
  if (!dir.existsSync()) return [];
  final errors = <String>[];
  final fragments = <Fragment>[];
  for (final f in dir.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (name == 'README.md' || name.startsWith('.')) continue;
    try {
      fragments.add(parseFragment(name, f.readAsStringSync()));
    } on FragmentError catch (e) {
      errors.add(e.message);
    }
  }
  if (errors.isNotEmpty) throw FragmentError(errors.join('\n'));
  return fragments;
}

/// The value after `--version`, as `--version X` or `--version=X`.
String? _versionArg(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i].startsWith('--version=')) return args[i].substring(10);
    if (args[i] == '--version' && i + 1 < args.length) return args[i + 1];
  }
  return null;
}

void main(List<String> args) {
  final write = args.contains('--write');
  final check = args.contains('--check');
  final dir = Directory('changes');
  final changelogFile = File('CHANGELOG.md');
  final releasesFile = File(releasesPath);

  try {
    final fragments = loadFragments(dir);
    final releases = releasesFile.readAsStringSync();

    if (check) {
      final problems = checkWhatsNew(
        releasesJson: releases,
        version:
            _versionArg(args) ??
            appVersion(File('pubspec.yaml').readAsStringSync()),
        fragments: fragments,
      );
      if (problems.isNotEmpty) throw FragmentError(problems.join('\n'));
      stdout.writeln(
        "ok: ${fragments.length} changelog fragment(s) valid, What's new "
        'ready',
      );
      return;
    }
    if (fragments.isEmpty) {
      stdout.writeln('No fragments in changes/: nothing to roll up.');
      return;
    }

    final changelog = changelogFile.readAsStringSync();
    final updated = rollUp(changelog, fragments);
    final version = _versionArg(args) ?? pendingVersion(releases);
    if (version == null) {
      throw FragmentError(
        'No release being written in $releasesPath (an entry with '
        '"date": null). Pass --version X.Y.Z for the release.',
      );
    }
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final drafted = draftWhatsNew(
      releases,
      version: version,
      date: today,
      changes: unreleasedChanges(updated),
      highlights: needsHighlights(changelog, fragments),
      guide: fragments.any((f) => f.kind == ChangeKind.move),
    );

    if (!write) {
      stdout.writeln(unreleasedSection(updated));
      stdout.writeln();
      stdout.writeln("What's new for $version:");
      stdout.writeln(
        const JsonEncoder.withIndent('  ').convert(
          _releases(drafted).firstWhere((r) => r['version'] == version),
        ),
      );
      stdout.writeln('(preview: run with --write to apply)');
      return;
    }

    changelogFile.writeAsStringSync(updated);
    releasesFile.writeAsStringSync(drafted);
    for (final f in fragments) {
      File('${dir.path}/${f.fileName}').deleteSync();
    }
    stdout.writeln(
      'Rolled ${fragments.length} fragment(s) into CHANGELOG.md, drafted '
      "What's new for $version and deleted the fragments. Write anything "
      'marked $todo in $releasesPath, review the diff, then release with '
      'scripts/release.sh.',
    );
  } on FragmentError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  }
}
