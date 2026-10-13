// Release review contact sheet (#171).
//
// The review test (integration_test/release_review_test.dart) names each
// screenshot `<variant>__NN_step`. scripts/release_review.sh moves them to
// screenshots/release_review/<device>/<variant>/NN_step.png and calls this
// to write index.html: one row per step, every device and variant side by
// side, so a change can be read across light/dark and normal/large text in
// one look.
//
//   dart run tool/release_review_sheet.dart screenshots/release_review
import 'dart:convert';
import 'dart:io';

/// Light and dark, at 100% and 200% text, in the order shown.
const reviewVariants = ['light-100', 'dark-100', 'light-200', 'dark-200'];

class ReviewShot {
  const ReviewShot(this.variant, this.step, this.name);

  final String variant;
  final int step;

  /// Snake case, as in the test: `show_me_outlined`.
  final String name;

  String get fileName => '${step.toString().padLeft(2, '0')}_$name.png';

  /// "07 · Show me outlined"
  String get label {
    final words = name.replaceAll('_', ' ');
    return '${step.toString().padLeft(2, '0')} · '
        '${words[0].toUpperCase()}${words.substring(1)}';
  }
}

final _pattern = RegExp(r'^([a-z]+-\d+)__(\d+)_([a-z0-9_]+)$');

/// The shot named [driverName] by the review test, or null for anything
/// else.
ReviewShot? parseShot(String driverName) {
  final m = _pattern.firstMatch(driverName);
  if (m == null || !reviewVariants.contains(m.group(1))) return null;
  return ReviewShot(m.group(1)!, int.parse(m.group(2)!), m.group(3)!);
}

const _esc = HtmlEscape();

/// The contact sheet for [byDevice] (device folder name to its shots).
String contactSheet(
  Map<String, List<ReviewShot>> byDevice, {
  required String title,
}) {
  final steps = <int, String>{};
  for (final shots in byDevice.values) {
    for (final s in shots) {
      steps.putIfAbsent(s.step, () => s.label);
    }
  }
  final ordered = steps.keys.toList()..sort();
  final have = {
    for (final MapEntry(key: device, value: shots) in byDevice.entries)
      for (final s in shots) '$device/${s.variant}/${s.step}',
  };
  final files = {
    for (final MapEntry(key: device, value: shots) in byDevice.entries)
      for (final s in shots) '$device/${s.variant}/${s.step}': s.fileName,
  };

  final b = StringBuffer()
    ..writeln('<!doctype html><meta charset="utf-8">')
    ..writeln('<title>${_esc.convert(title)}</title>')
    ..writeln(
      '<style>body{font:14px system-ui;margin:16px}h2{margin:28px 0 8px}'
      '.row{display:flex;gap:12px;overflow-x:auto}figure{margin:0;'
      'flex:none}img{width:180px;border:1px solid #ccc;border-radius:8px}'
      'figcaption{font-size:12px;color:#555}.missing{width:180px;height:'
      '120px;display:grid;place-items:center;border:1px dashed #c00;'
      'color:#c00;border-radius:8px}</style>',
    )
    ..writeln('<h1>${_esc.convert(title)}</h1>');
  for (final MapEntry(key: device, value: shots) in byDevice.entries) {
    if (shots.isEmpty) {
      b.writeln(
        '<p><strong>${_esc.convert(device)}: no screenshots.</strong> '
        'See the run log for why.</p>',
      );
    }
  }
  for (final step in ordered) {
    b
      ..writeln('<h2>${_esc.convert(steps[step]!)}</h2>')
      ..writeln('<div class="row">');
    for (final device in byDevice.keys) {
      if (byDevice[device]!.isEmpty) continue;
      for (final v in reviewVariants) {
        final key = '$device/$v/$step';
        final caption = _esc.convert('$device · $v');
        if (have.contains(key)) {
          final src = '$device/$v/${files[key]}';
          b.writeln(
            '<figure><a href="$src"><img src="$src" loading="lazy"></a>'
            '<figcaption>$caption</figcaption></figure>',
          );
        } else {
          b.writeln(
            '<figure><div class="missing">missing</div>'
            '<figcaption>$caption</figcaption></figure>',
          );
        }
      }
    }
    b.writeln('</div>');
  }
  return b.toString();
}

/// Moves the raw driver output in `<root>/<device>/raw/` into
/// `<root>/<device>/<variant>/`, then writes `<root>/index.html`.
void main(List<String> args) {
  final root = Directory(args.isEmpty ? 'screenshots/release_review' : args[0]);
  final title = args.length > 1 ? args[1] : 'Health Flare release review';
  final byDevice = <String, List<ReviewShot>>{};
  for (final d
      in root.listSync().whereType<Directory>().toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
    final device = d.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final shots = <ReviewShot>[];
    final raw = Directory('${d.path}/raw');
    if (raw.existsSync()) {
      for (final f in raw.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (!name.endsWith('.png')) continue;
        final s = parseShot(name.substring(0, name.length - 4));
        if (s == null) continue;
        final dest = Directory('${d.path}/${s.variant}')
          ..createSync(recursive: true);
        f.renameSync('${dest.path}/${s.fileName}');
      }
      raw.deleteSync(recursive: true);
    }
    for (final v in reviewVariants) {
      final vd = Directory('${d.path}/$v');
      if (!vd.existsSync()) continue;
      for (final f in vd.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (!name.endsWith('.png')) continue;
        final s = parseShot('${v}__${name.substring(0, name.length - 4)}');
        if (s != null) shots.add(s);
      }
    }
    byDevice[device] = shots;
  }
  File(
    '${root.path}/index.html',
  ).writeAsStringSync(contactSheet(byDevice, title: title));
  final count = byDevice.values.fold(0, (n, s) => n + s.length);
  stdout.writeln('${root.path}/index.html: $count screenshots');
}
