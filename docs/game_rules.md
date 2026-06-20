# Game Rules

## What Shikaku Is

Shikaku is a logic puzzle played on a rectangular grid. Some cells contain number clues. The player divides the full grid into non-overlapping rectangles.

Each rectangle must contain exactly one clue. The area of the rectangle must equal the clue number inside it.

## Win Conditions

The puzzle is complete when:

- Every cell on the board is covered by a rectangle.
- Every rectangle contains exactly one clue.
- Every rectangle area equals its clue number.
- No rectangles overlap.

## Validation Rules

When a player selects a rectangle, it is accepted only if:

- The rectangle is inside the puzzle bounds.
- The rectangle contains exactly one clue.
- The rectangle area equals the clue value.
- The rectangle does not overlap an existing accepted region.

Invalid selections are rejected and do not change the board.
