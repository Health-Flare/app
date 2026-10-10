<!-- kind: fix -->
- CSV exports now say whether each dose was taken, skipped or missed, with
  the reason and how well it worked when you recorded them, e.g. "500 mg ·
  Missed · Forgot". Before, every dose looked taken, so a missed dose was
  counted as taken by anyone reading the file. Amounts no longer show a
  stray ".0" ("500 mg", not "500.0 mg").
