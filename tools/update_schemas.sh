#!/usr/bin/env bash
# tools/update_schemas.sh
#
# Syncs Isar model files from the main Flutter project into the CSV import
# CLI tool. Run this whenever a new Isar collection is added or an existing
# schema changes (after running ./scripts/generate_isar.sh).
#
# Usage:
#   bash tools/update_schemas.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_MODELS="$REPO_ROOT/lib/data/models"
SRC_DB="$REPO_ROOT/lib/data/database"
DST="$REPO_ROOT/tools/csv_import/lib/isar_models"

echo "Syncing Isar models to tools/csv_import/lib/isar_models/ ..."

python3 << PYEOF
import os, shutil, re

src_models = '$SRC_MODELS'
src_db     = '$SRC_DB'
dst        = '$DST'

def strip_dart(content):
    lines = content.splitlines()
    out = []
    skip = False
    brace_depth = 0
    paren_depth = 0
    skip_brace = None
    skip_paren = None
    saw_terminator = False

    for line in lines:
        if re.match(r"^import 'package:health_flare/", line):
            continue

        stripped = line.strip()

        if not skip:
            is_conversion = re.match(r'// ── Conversion', stripped)
            is_toDomain   = re.search(r'\btoDomain\s*\(', stripped)
            is_fromDomain = re.search(r'\bfromDomain\s*\(', stripped)

            if is_conversion or is_toDomain or is_fromDomain:
                skip = True
                skip_brace = brace_depth
                skip_paren = paren_depth
                saw_terminator = False
                brace_depth += line.count('{') - line.count('}')
                paren_depth += line.count('(') - line.count(')')
                if ';' in line:
                    saw_terminator = True
                continue

        brace_depth += line.count('{') - line.count('}')
        paren_depth += line.count('(') - line.count(')')
        if ';' in line:
            saw_terminator = True

        if skip:
            at_depth = brace_depth <= skip_brace and paren_depth <= skip_paren
            if at_depth and saw_terminator:
                skip = False
                skip_brace = None
                skip_paren = None
                if stripped == '}' and brace_depth == 0:
                    out.append(line)
            continue

        out.append(line)

    result = '\n'.join(out)
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result.rstrip() + '\n'

for fname in sorted(os.listdir(src_models)):
    path = os.path.join(src_models, fname)
    if fname.endswith('.g.dart'):
        shutil.copy(path, os.path.join(dst, fname))
        print(f'  copied  {fname}')
    elif fname.endswith('.dart'):
        with open(path) as f:
            content = f.read()
        with open(os.path.join(dst, fname), 'w') as f:
            f.write(strip_dart(content))
        print(f'  stripped {fname}')

for fname in ['app_settings.dart', 'app_settings.g.dart']:
    src = os.path.join(src_db, fname)
    with open(src) as f:
        content = f.read()
    if fname.endswith('.g.dart'):
        with open(os.path.join(dst, fname), 'w') as f:
            f.write(content)
        print(f'  copied  {fname}')
    else:
        with open(os.path.join(dst, fname), 'w') as f:
            f.write(strip_dart(content))
        print(f'  stripped {fname}')
PYEOF

echo "Done. Run 'cd tools/csv_import && dart pub get' to refresh dependencies."
