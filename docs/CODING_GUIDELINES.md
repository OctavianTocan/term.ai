# Coding Guidelines

These rules apply to every change in this repository. They exist to keep the code base small, sharp, and easy to reason about.

## Function Design

- Each function does one job and nothing else. If you have to say "and" while describing it, split it.
- Keep bodies tight: 5-10 lines is ideal, 20 is the hard ceiling.
- Stick to a single level of abstraction per function. Reading the file should feel like stepping down a staircase, one level at a time.
- Blocks inside functions (`if`, `else`, `while`, etc.) should be one line that delegates to a helper.
- Avoid nested indents deeper than two levels. If you hit that, refactor.

## Parameters and Data Flow

- Zero parameters is best, one is acceptable, two is tolerable, three is the cap. No boolean flags.
- Return data instead of mutating caller state. Pure functions beat hidden side effects.
- When arguments belong together, wrap them in a dedicated object.

## Separation of Concerns

- Break work into clear layers: lookup, extraction, persistence, orchestration.
- Isolate side effects (I/O, logging, editor hooks). Keep them explicit.
- Follow command-query separation: functions either do something or answer something, never both.

## Naming and Readability

- Name functions after what they do, not how they do it.
- Reuse vocabulary consistently (e.g., `Get*`, `Find*`, `Save*`).
- Arrange functions in step-down order: high-level orchestration first, helpers immediately below.

## Dependencies and APIs

- Make dependencies explicit in signatures. No hidden globals.
- Prefer composition over big procedural blobs.
- Keep public surface area small. Default to private/internal scope.
- Preserve backward compatibility whenever possible. Add new helpers instead of breaking old ones.

## Documentation and Comments

- Code should explain itself. Comments are last resort.
- When comments are required, limit them to intent, warnings, TODOs, legal notices, or third-party quirks.
- Do not comment out code. Delete it. Git remembers.
- Follow Doxygen standards for any functions that need reference docs. Treat stale comments as bugs.

## Testing Mindset

- Design functions so they can be unit tested in isolation.
- Keep mocks minimal by avoiding unnecessary dependencies.
- Remember there are hidden tests. Assume anything brittle will break.

## Tooling Notes

- Stay on current SDK and API versions. Verify calls against documentation before writing code.
- Update `.gitignore` only when necessary for this project. Untrack files before ignoring them.

Stick to these rules. Clean, predictable functions keep the AI assistant useful and the project maintainable.
