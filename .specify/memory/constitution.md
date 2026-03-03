<!--
Sync Impact Report
- Version change: N/A → 1.0.0
- Added principles:
  - I. Publication Readiness
  - II. Code Quality & Correctness
  - III. Comprehensive Documentation
  - IV. Clean Public API Design
  - V. Reliability & Edge-Case Handling
- Added sections:
  - pub.dev Compliance Requirements
  - Development Workflow
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (aligned with Constitution Check)
  - .specify/templates/spec-template.md ✅ (scope/requirements compatible)
  - .specify/templates/tasks-template.md ✅ (task categories compatible)
- Follow-up TODOs: None
-->

# Animated OTP Field Constitution

## Core Principles

### I. Publication Readiness

Every release artifact MUST satisfy pub.dev publishing requirements before
merge to the main branch.

- `pubspec.yaml` MUST contain a meaningful `description` (60–180 chars),
  valid `homepage` or `repository` URL, and a properly bumped `version`.
- `LICENSE` MUST contain a recognized OSS license (MIT recommended).
- `CHANGELOG.md` MUST document every user-facing change per version,
  following Keep-a-Changelog conventions.
- `README.md` MUST include a short description, feature list, installation
  instructions, at least one usage example, and a screenshot/GIF when
  visual behavior is involved.
- `example/` MUST contain a runnable, self-explanatory demo app that
  exercises the primary widget API.
- `dart pub publish --dry-run` MUST pass with zero warnings before any
  release.

*Rationale*: pub.dev scores packages on completeness; missing metadata or
documentation results in lower scores and reduced discoverability.

### II. Code Quality & Correctness

All library code MUST follow Dart/Flutter best practices and be free of
known bugs before release.

- All public members MUST use `const` constructors where possible.
- Widget state MUST be properly initialized in `initState` and cleaned up
  in `dispose`; no leaked listeners, controllers, or timers.
- Naming MUST follow Dart conventions: `lowerCamelCase` for members,
  `UpperCamelCase` for types, no abbreviations that reduce clarity.
- Known typos in public API identifiers (e.g., `fieldFocusNod` instead of
  `fieldFocusNode`) MUST be corrected and marked as breaking changes.
- `flutter analyze` MUST report zero issues at the `info` level or above.
- Third-party dependencies MUST be justified; prefer Flutter SDK widgets
  over external packages when the overhead is trivial.

*Rationale*: A published package becomes a public API contract; defects
and inconsistencies erode trust and create breaking-change churn later.

### III. Comprehensive Documentation

Every public symbol exported from the package MUST have dartdoc
documentation.

- Every public class, constructor, property, method, and typedef MUST have
  a `///` doc comment explaining purpose, parameters, defaults, and usage.
- Doc comments MUST include at least one `/// ```dart` code example for
  each primary widget and callback.
- The `example/` app MUST be fully commented, demonstrating common
  customization scenarios (custom decoration, server-side validation,
  cursor customization, RTL support).
- Internal (`_`-prefixed) classes and methods SHOULD have doc comments
  when their behavior is non-obvious.

*Rationale*: Documentation is the first thing developers evaluate when
choosing a package; it directly impacts the pub.dev "documentation" score.

### IV. Clean Public API Design

The public API surface MUST be minimal, intuitive, and consistent.

- Only types and members that consumers need MUST be exported; internal
  helpers MUST remain library-private.
- Parameter names MUST be self-documenting and consistent across the
  widget (e.g., all decoration parameters follow the same naming pattern).
- Callback signatures MUST use standard Dart idioms (`ValueChanged<T>`,
  `VoidCallback`) and avoid exposing internal state.
- Default values MUST produce a visually correct, accessible widget
  without any required parameters beyond the minimum.
- Breaking API changes MUST bump the MAJOR version and be documented
  in `CHANGELOG.md` with migration instructions.

*Rationale*: A clean API reduces onboarding friction and support burden;
once published at 1.0.0, the API is a semver contract.

### V. Reliability & Edge-Case Handling

The widget MUST handle all reasonable user and platform scenarios
gracefully.

- The widget MUST work correctly in LTR and RTL text directions.
- The widget MUST respect the host app's `ThemeData` for colors, text
  styles, and shape defaults when custom decorations are not provided.
- Autofill MUST function correctly on iOS and Android with the
  `oneTimeCode` hint.
- The widget MUST not throw exceptions for edge cases: zero-length OTP,
  rapid input, paste operations exceeding `len`, or repeated
  focus/unfocus cycles.
- Haptic feedback (via `gaimon`) MUST degrade gracefully on platforms
  that do not support it (web, desktop) without throwing.

*Rationale*: Package consumers expect widgets to behave correctly out of
the box across all supported Flutter platforms.

## pub.dev Compliance Requirements

These requirements are non-negotiable for every release:

| Requirement              | Criteria                                          |
|--------------------------|---------------------------------------------------|
| Dart format              | `dart format .` produces zero changes              |
| Static analysis          | `flutter analyze` reports zero issues              |
| Documentation coverage   | All public APIs have dartdoc comments              |
| Example                  | `example/` contains a runnable demo                |
| License                  | Recognized OSS license present at repo root        |
| SDK constraints          | `environment.sdk` uses modern Dart 3.x range       |
| Platform support         | Explicitly declared in `pubspec.yaml` if needed    |
| Dry-run publish          | `dart pub publish --dry-run` passes cleanly        |

## Development Workflow

1. **Code Review**: Every change MUST be reviewed for correctness, API
   consistency, and documentation completeness before merge.
2. **Formatting**: Run `dart format .` before every commit.
3. **Analysis**: Run `flutter analyze` and resolve all issues before
   every commit.
4. **Testing**: Widget tests SHOULD cover primary user interactions
   (input, validation, animation triggers). Tests are encouraged but
   not blocking for initial release.
5. **Versioning**: Follow semver strictly:
   - MAJOR: Breaking API changes (renamed parameters, removed members).
   - MINOR: New features, new parameters with defaults.
   - PATCH: Bug fixes, documentation improvements.
6. **Changelog**: Update `CHANGELOG.md` with every version bump using
   human-readable descriptions grouped by Added/Changed/Fixed/Removed.

## Governance

This constitution governs all development decisions for the
`animated_otp_field` package. It supersedes ad-hoc practices.

- **Amendments**: Any principle change MUST be documented with rationale,
  version-bumped in this file, and propagated to dependent templates.
- **Versioning**: This constitution follows semver. MAJOR for principle
  removals/redefinitions, MINOR for new principles/sections, PATCH for
  wording clarifications.
- **Compliance**: Every PR and code review MUST verify alignment with
  these principles. Non-compliance MUST be justified with a documented
  exception.

**Version**: 1.0.0 | **Ratified**: 2026-03-03 | **Last Amended**: 2026-03-03
