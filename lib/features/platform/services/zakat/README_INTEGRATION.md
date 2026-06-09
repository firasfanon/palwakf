# Pwf Zakat Feature (Integration)

## What you get
- A self-contained feature under `lib/features/platform/services/zakat/`
- Riverpod legacy StateNotifier (per platform rules)
- RTL-first UI + i18n-ready (no hardcoded strings)
- No DB/RLS/SQL changes

## Install
1) Copy folder:
- Copy `lib/features/platform/services/zakat/` into your platform project in the same path.

2) Merge l10n keys:
- Merge `l10n_snippets/app_ar.additions.json` into `lib/l10n/app_ar.arb`
- Merge `l10n_snippets/app_en.additions.json` into `lib/l10n/app_en.arb`

3) Regenerate localizations
- Run your usual l10n generation command (example: `flutter gen-l10n`)

4) Add route (where you keep routes today)
- Point your route to `const PwfZakatCalculatorScreen()`

## Notes
- Printing works on Web via `window.print()` (conditional import). On non-web it safely no-ops.
- UI is responsive and avoids unbounded sizing issues on Web first paint.
