# AI Context

## Project Goals

Build a production-quality, offline Android-first Flutter game for Shikaku puzzles. The project should remain simple, explicit, easy to refactor, and easy for humans and AI agents to understand.

## Architecture Summary

The app uses layered feature architecture:

- `lib/app`: app shell and theme.
- `lib/app/application`: app-level controllers such as settings.
- `lib/app/data`: app-level persistence and services such as settings storage and direct APK update checks.
- `lib/core`: shared models, services, utilities, and constants.
- `lib/features/puzzle/domain`: puzzle data types and rules.
- `lib/features/puzzle/application`: game state controller.
- `lib/features/puzzle/presentation`: Flutter UI.
- `lib/features/puzzle/data`: generated and asset-backed puzzle loading.
- `lib/features/settings/presentation`: settings UI.

Dependency direction is `presentation -> application -> domain` and `data -> domain`. Keep domain logic independent from Flutter widgets.

## Coding Conventions

- Prefer small files with clear responsibilities.
- Add documentation comments to every public class.
- Keep methods short and named after behavior.
- Put puzzle rules in domain services, not widgets.
- Keep app-wide settings in `SettingsController`, not feature-specific controllers.
- Keep puzzle board palettes in PuzzleUiConstants using explicit board color schemes.
- Use constants instead of unexplained literals.
- Prefer immutable value objects in the domain layer.

## Naming Conventions

- Use `Puzzle` for a full puzzle definition.
- Use `Clue` for a numbered clue cell.
- Use `CellPosition` for grid coordinates.
- Use `PuzzleRegion` for an accepted rectangular region.
- Use `PuzzleController` for state used by the UI.
- Use `PuzzleValidator` for rule validation.
- Use `PuzzleGenerator` to create locally solvable boards from rectangle partitions.
- Use `GeneratedPuzzleRepository` for the current gameplay source; keep `AssetPuzzleRepository` for future curated packs.
- Use `SettingsController` for theme, vibration, and sound preferences.
- Use `SettingsController.boardSize` for the selected square generated-board size.
- Settings are opened from the app bar cog, not bottom navigation.
- Tapping an accepted puzzle region removes that region.
- Light mode uses black clue text with a light region palette.
- Dark mode uses white clue text with a darker region palette.
- Generated boards currently support square sizes from 4 to 12.
- Generated clue areas must stay between 2 and 12, and clue placement should prefer non-adjacent cells.
- Completion uses an in-screen confetti effect and a New puzzle button, not a modal dialog.
- Accepted regions are outlined over the cell grid to distinguish adjacent groups with matching fill colors.
- Direct APK updates are user-initiated from Settings, check public GitHub Releases, accept `EpicShikaku.apk` or `app-release.apk` release assets, and hand off installation to Android's package installer.
- Public APK releases must be signed with the stable release keystore from GitHub Actions secrets. Debug-signed APKs are for local testing only and cannot be relied on for in-place updates.
- Patch notes are customer-facing release notes. Include only changes players need to know about; keep technical, generic, internal, and implementation-only details out of the visible patch notes.

## Things To Avoid

- Do not add backend, cloud services, ads, analytics, or network dependencies beyond the explicit user-initiated GitHub Releases update check.
- Do not put validation rules in UI widgets.
- Do not introduce complex state management without a documented reason.
- Do not add network-backed settings or accounts.
- Do not create large files that mix unrelated responsibilities.
- Do not add server-side puzzle generation, background network features, or a completion modal.
- Do not use visible patch notes as developer notes or a technical changelog.
- Do not commit Android keystores, key passwords, or signing property files.
