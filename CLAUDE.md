# CLAUDE.md

This repository is the `Nursery Full App` monorepo on the
`backend-integration-with-mobile` branch. The admin app lives at the root, the
parent Flutter app lives in `mobile/`, and the shared package lives in
`packages/nursery_shared/`. Read the root `AGENTS.md` when it is available
before touching code
here — this file is just the pointer and the app-specific TL;DR.

## This app

Admin dashboard, desktop-oriented (1440×900 design reference). Depends on
`packages/nursery_shared` via a local path dependency for models, the API
client, and enums — see root `AGENTS.md` §2 and §7 before adding any
networking or data-model code here directly.

## Commands

- Get dependencies: `flutter pub get`
- Analyze: `flutter analyze`
- Unit tests: `flutter test`
- Single test file: `flutter test test/path/to_test.dart`
- Run a flavor: `flutter run --flavor dev --target lib/main_dev.dart --dart-define=API_BASE_URL=... --dart-define=ENV_NAME=dev`

## Non-negotiables (see root `AGENTS.md` for full detail)

- **Zero hardcoded user-facing strings** — every string goes through
  `easy_localization`'s `.tr()`, keys in `assets/translations/en.json` and
  `ar.json` (§4).
- **Every Cubit gets a `bloc_test` test file** (§3).
- **No raw `Dio` in feature code** — go through `nursery_shared`'s
  `ApiClient` (§7).
- **`AppColors` for colour, `.sp` for text, `AppSpacing.of(context)` for
  layout** — never a hardcoded `Color(0xFF...)` or a bare pixel value in a
  widget (§6).
- **No AI co-author trailer on commits** (§10).
- **Plan first** for any non-trivial feature — save to
  `../docs/superpowers/plans/YYYY-MM-DD-<name>.md` before writing code (§9).

If anything here conflicts with root `AGENTS.md`, `AGENTS.md` wins.
