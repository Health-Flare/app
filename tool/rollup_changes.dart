// Rolls changelog fragments in `changes/` into CHANGELOG.md's Unreleased
// section.
//
// Why: every PR used to add a line at the end of the same Unreleased
// subsection, so each merge left every other open PR conflicting on
// CHANGELOG.md. Each PR now adds its own file, which can't conflict; the
// fragments are rolled up into CHANGELOG.md when cutting a release.
//
// It also keeps What's new (assets/whats_new/releases.json) in step with
// the changelog, so every release that changes the app says so in the app.
// Rules: docs/feature-releases.md.
//
// Usage (from the repo root):
//   dart run tool/rollup_changes.dart --check
//       Validate fragments and releases.json. CI runs the same checks.
//   dart run tool/rollup_changes.dart [--version X.Y.Z]
//       Preview the rolled-up Unreleased section (and the What's new draft
//       with --version). Changes nothing.
//   dart run tool/rollup_changes.dart --write --version X.Y.Z
//       Roll fragments into CHANGELOG.md, delete them, and draft the
//       What's new entry for X.Y.Z. Then write its highlights.
//   dart run tool/rollup_changes.dart --stamp X.Y.Z --date YYYY-MM-DD [--dry-run]
//       Used by scripts/release.sh: refuse to release X.Y.Z unless its
//       What's new entry is ready, then date it.
//
// Fragment format: see changes/README.md.

import 'dart:io';

import 'whats_new_release.dart';

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

/// What a change means for someone who already uses the app
/// (docs/feature-releases.md). The kind decides what ships with it.
enum ChangeKind {
  /// Something broken now works. Fragment only.
  fix,

  /// Something new, nothing existing moved. Fragment, and a highlight if
  /// it's worth knowing about.
  addition,

  /// An existing screen, control or default is somewhere else or does
  /// something else when tapped. Ships with a release guide.
  move,
}

/// Kind a section implies when the fragment doesn't say. `changed`,
/// `removed` and `deprecated` have no default: those are where moves hide,
/// so the author has to decide.
const _defaultKind = {
  'Added': ChangeKind.addition,
  'Fixed': ChangeKind.fix,
  'Security': ChangeKind.fix,
};

/// One entry from a fragment file.
class Fragment {
  Fragment(
    this.fileName,
    this.section,
    this.bullets, {
    this.kind = ChangeKind.addition,
    this.guide,
  });

  final String fileName;
  final String section;

  /// Each bullet's full text, including the leading "- " and any wrapped
  /// continuation lines.
  final List<String> bullets;

  final ChangeKind kind;

  /// Release guide id for a [ChangeKind.move]; null otherwise.
  final String? guide;
}

class FragmentError implements Exception {
  FragmentError(this.message);
  final String message;
  @override
  String toString() => message;
}

final _kindLine = RegExp(r'^<!--\s*kind\s*:', caseSensitive: false);
final _kindPattern = RegExp(
  r'^<!--\s*kind\s*:\s*([a-z]+)\s*(?:;\s*guide\s*:\s*([a-z0-9][a-z0-9-]*)\s*)?-->$',
);

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
  ChangeKind? kind;
  String? guide;
  for (final raw in content.split('\n')) {
    final line = raw.trimRight();
    if (_kindLine.hasMatch(line.trim())) {
      final k = _kindPattern.firstMatch(line.trim());
      final value = k == null
          ? null
          : ChangeKind.values.where((v) => v.name == k.group(1)).firstOrNull;
      if (k == null || value == null) {
        throw FragmentError(
          '$fileName: write the kind as <!-- kind: fix -->, '
          '<!-- kind: addition --> or <!-- kind: move; guide: <guide-id> -->',
        );
      }
      if (kind != null) {
        throw FragmentError('$fileName: kind is given more than once');
      }
      kind = value;
      guide = k.group(2);
      continue;
    }
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
  kind ??= _defaultKind[section];
  if (kind == null) {
    throw FragmentError(
      '$fileName: a ${section.toLowerCase()} fragment must say what kind of '
      'change it is, on its own line: <!-- kind: fix -->, '
      '<!-- kind: addition --> or <!-- kind: move; guide: <guide-id> -->. '
      'A move is anything someone who used the app yesterday would look '
      'for in the old place (docs/feature-releases.md).',
    );
  }
  if (kind == ChangeKind.move && guide == null) {
    throw FragmentError(
      '$fileName: a move ships with a release guide. Name it: '
      '<!-- kind: move; guide: <guide-id> -->. No guide yet? Keep the change '
      'behind its build flag, with no fragment, until there is one.',
    );
  }
  if (kind != ChangeKind.move && guide != null) {
    throw FragmentError(
      '$fileName: only a move has a guide. Drop "guide:", or make it '
      '<!-- kind: move; guide: $guide -->',
    );
  }
  return Fragment(fileName, section, bullets, kind: kind, guide: guide);
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

/// Value of `--name X` or `--name=X` in [args], or null.
String? option(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--$name' && i + 1 < args.length) return args[i + 1];
    if (args[i].startsWith('--$name=')) {
      return args[i].substring(name.length + 3);
    }
  }
  return null;
}

void _fail(String message) {
  stderr.writeln(message);
  exitCode = 1;
}

void main(List<String> args) {
  final write = args.contains('--write');
  final check = args.contains('--check');
  final dryRun = args.contains('--dry-run');
  final version = option(args, 'version');
  final stamp = option(args, 'stamp');
  final dir = Directory('changes');
  final changelogFile = File('CHANGELOG.md');
  final releasesFile = File(releasesJsonPath);

  final List<Fragment> fragments;
  try {
    fragments = loadFragments(dir);
  } on FragmentError catch (e) {
    _fail(e.message);
    return;
  }

  if (check) {
    final errors = validateReleases(
      releasesFile.readAsStringSync(),
      pubspecVersion: readPubspecVersion(
        File('pubspec.yaml').readAsStringSync(),
      ),
    );
    if (errors.isNotEmpty) {
      _fail('$releasesJsonPath:\n${errors.map((e) => '  $e').join('\n')}');
      return;
    }
    stdout.writeln(
      'ok: ${fragments.length} changelog fragment(s) valid, '
      '$releasesJsonPath valid',
    );
    return;
  }

  if (stamp != null) {
    final date = option(args, 'date');
    if (date == null) {
      _fail('--stamp needs --date YYYY-MM-DD');
      return;
    }
    if (fragments.isNotEmpty) {
      _fail(
        'changes/ still has ${fragments.length} fragment(s), so they are not '
        'in CHANGELOG.md or What\'s new yet. Run:\n'
        '  dart run tool/rollup_changes.dart --write --version $stamp\n'
        'then write the highlights, remove "draft", and commit.',
      );
      return;
    }
    try {
      final out = stampRelease(releasesFile.readAsStringSync(), stamp, date);
      if (!dryRun) releasesFile.writeAsStringSync(out);
      stdout.writeln(
        dryRun
            ? "ok: What's new for $stamp is ready"
            : "Dated What's new for $stamp: $date",
      );
    } on ReleaseError catch (e) {
      _fail(e.message);
    }
    return;
  }

  if (write && version == null) {
    _fail(
      '--write needs --version X.Y.Z: the fragments are deleted after the '
      "rollup, so What's new has to be drafted in the same step.",
    );
    return;
  }
  if (version != null && !isReleaseVersion(version)) {
    _fail('--version must look like 1.10.0, got "$version"');
    return;
  }

  if (fragments.isEmpty && version == null) {
    stdout.writeln('No fragments in changes/: nothing to roll up.');
    return;
  }

  final updated = rollUp(changelogFile.readAsStringSync(), fragments);
  String? releases;
  if (version != null) {
    releases = draftWhatsNew(
      releasesFile.readAsStringSync(),
      version: version,
      changes: changesFromUnreleased(updated),
      guides: {
        for (final f in fragments)
          if (f.guide != null) f.guide!,
      },
    );
  }

  if (!write) {
    stdout.writeln(unreleasedSection(updated));
    if (releases != null) {
      stdout.writeln("\nWhat's new draft for $version:");
      stdout.writeln(entryJson(releases, version!));
    }
    stdout.writeln('(preview: run with --write --version X.Y.Z to apply)');
    return;
  }

  changelogFile.writeAsStringSync(updated);
  releasesFile.writeAsStringSync(releases!);
  for (final f in fragments) {
    File('${dir.path}/${f.fileName}').deleteSync();
  }
  final moves = fragments.where((f) => f.kind == ChangeKind.move).toList();
  stdout.writeln(
    'Rolled ${fragments.length} fragment(s) into CHANGELOG.md and deleted '
    "them, and drafted What's new for $version in $releasesJsonPath.\n"
    '\n'
    'Next:\n'
    '  1. Read the Unreleased section of CHANGELOG.md.\n'
    '  2. In $releasesJsonPath, write 0 to 4 highlights for $version '
    '(none for a fix-only release), then delete the "draft" line.\n'
    '  3. bash scripts/whats_new.sh run upgrade shows the card; '
    'bash scripts/whats_new.sh check validates it.\n'
    '  4. Commit, then: bash scripts/release.sh $version'
    '${moves.isEmpty ? '' : '\n\nThis release moves things. Guides named: ${{for (final m in moves) m.guide}.join(', ')}.'}',
  );
}
