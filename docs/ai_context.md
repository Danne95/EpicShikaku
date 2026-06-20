# AI Context

## Project Goals

Build a production-quality, offline Android-first Flutter game for Shikaku puzzles. The project should remain simple, explicit, easy to refactor, and easy for humans and AI agents to understand.

## Architecture Summary

The app uses layered feature architecture:

- `lib/app`: app shell and theme.
- `lib/core`: shared models, services, utilities, and constants.
- `lib/features/puzzle/domain`: puzzle data types and rules.
- `lib/features/puzzle/application`: game state controller.
- `lib/features/puzzle/presentation`: Flutter UI.
- `lib/features/puzzle/data`: asset-backed puzzle loading.

Dependency direction is `presentation -> application -> domain` and `data -> domain`. Keep domain logic independent from Flutter widgets.

## Coding Conventions

- Prefer small files with clear responsibilities.
- Add documentation comments to every public class.
- Keep methods short and named after behavior.
- Put puzzle rules in domain services, not widgets.
- Use constants instead of unexplained literals.
- Prefer immutable value objects in the domain layer.

## Naming Conventions

- Use `Puzzle` for a full puzzle definition.
- Use `Clue` for a numbered clue cell.
- Use `CellPosition` for grid coordinates.
- Use `PuzzleRegion` for an accepted rectangular region.
- Use `PuzzleController` for state used by the UI.
- Use `PuzzleValidator` for rule validation.

## Things To Avoid

- Do not add backend, cloud services, ads, analytics, or network dependencies.
- Do not put validation rules in UI widgets.
- Do not introduce complex state management without a documented reason.
- Do not create large files that mix unrelated responsibilities.
- Do not make generated puzzles before static puzzle gameplay is solid.
