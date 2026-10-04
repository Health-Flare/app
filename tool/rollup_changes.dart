// Rolls changelog fragments in `changes/` into CHANGELOG.md's Unreleased
// section.
//
// Why: every PR used to add a line at the end of the same Unreleased
// subsection, so each merge left every other open PR conflicting on
// CHANGELOG.md. Each PR now adds its own file, which can't conflict; the
// fragments are rolled up into CHANGELOG.md when cutting a release.
//
// Usage (from the repo root):
//   dart run tool/rollup_changes.dart           # preview, changes nothing
//   dart run tool/rollup_changes.dart --check   # validate fragments only
//   dart run tool/rollup_changes.dart --write   # update CHANGELOG.md and
//                                               # delete the fragments
//
// Fragment format: see changes/README.md.

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

const _placeholder = '- _Nothing yet._';

/// One entry from a fragment file.
class Fragment {
  Fragment(this.fileName, this.section, this.bullets);

  final String fileName;
  final String section;

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
  r'^([a-z0-9][a-z0-9-]*)\.(added|changed|deprecated|removed|fixed|security)\.md$',
);

/// Parses one fragment. [fileName] decides the section; [content] holds one
/// or more Markdown bullets ("- ..."). Lines that don't start a bullet
/// continue the previous one.
Fragment parseFragment(String fileName, String content) {
  final m = _namePattern.firstMatch(fileName);
  if (m == null) {
    throw FragmentError(
      '$fileName: name must be <issue>-<slug>.<section>.md, where section '
      'is one of ${sections.map((s) => s.toLowerCase()).join(', ')}',
    );
  }
  final section = sections.firstWhere((s) => s.toLowerCase() == m.group(2));

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
  return Fragment(fileName, section, bullets);
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

void main(List<String> args) {
  final write = args.contains('--write');
  final check = args.contains('--check');
  final dir = Directory('changes');
  final changelogFile = File('CHANGELOG.md');

  final List<Fragment> fragments;
  try {
    fragments = loadFragments(dir);
  } on FragmentError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
    return;
  }

  if (check) {
    stdout.writeln('ok: ${fragments.length} changelog fragment(s) valid');
    return;
  }
  if (fragments.isEmpty) {
    stdout.writeln('No fragments in changes/: nothing to roll up.');
    return;
  }

  final updated = rollUp(changelogFile.readAsStringSync(), fragments);
  if (!write) {
    final start = updated.indexOf('## [Unreleased]');
    final end = updated.indexOf('\n## [', start + 1);
    stdout.writeln(updated.substring(start, end < 0 ? updated.length : end));
    stdout.writeln('(preview: run with --write to apply)');
    return;
  }

  changelogFile.writeAsStringSync(updated);
  for (final f in fragments) {
    File('${dir.path}/${f.fileName}').deleteSync();
  }
  stdout.writeln(
    'Rolled ${fragments.length} fragment(s) into CHANGELOG.md and deleted '
    'them. Review the diff, then rename Unreleased for the release.',
  );
}
