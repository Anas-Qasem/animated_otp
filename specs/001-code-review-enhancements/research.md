# Research: Code Review & pub.dev Publication Readiness

**Branch**: `001-code-review-enhancements`
**Date**: 2026-03-03

## R1: SDK Version Constraints

**Decision**: Dart `^3.11.0`, Flutter `>=3.41.2`

**Rationale**: The project targets the latest stable Flutter 3.41.2 (Dart
3.11.0). This ensures access to the latest language features, performance
improvements, and bug fixes. Using caret syntax (`^3.11.0`) allows all Dart
3.x versions >=3.11.0 while excluding Dart 4.0.

**Alternatives considered**:
- `>=2.15.0 <4.0.0` (original) — too permissive; code uses Dart 3 features
  (`super.key`, named constructor parameters) and Flutter 3.27+ features
  (`Row.spacing`).
- `^3.6.0` — too permissive; targeting latest stable SDK provides better
  compatibility guarantees and tooling support.

## R2: Dependency Justification

### shake_animation_widget ^3.0.4

**Decision**: Keep.

**Rationale**: Provides `ShakeAnimationWidget` and `ShakeAnimationController`
for the invalid-OTP shake effect. Building a custom shake animation would
require an `AnimationController`, a `Transform` widget, and a sine-based
`Tween`. The existing dependency is small and does this well.

**Alternatives considered**:
- Custom `AnimationController` + `Transform.translate` with a sine curve.
  Rejected: ~40 LOC of animation plumbing for no real benefit.

### gaimon ^1.4.1

**Decision**: Keep, with platform-safe try-catch.

**Rationale**: Provides native haptic feedback patterns (error, success,
warning) via platform channels. iOS uses `UIFeedbackGenerator`; Android uses
`Vibrator`. No Flutter SDK equivalent exists for patterned haptic feedback
(`HapticFeedback` only offers generic patterns, not "error" specifically).

**Alternatives considered**:
- `HapticFeedback.heavyImpact()` from `flutter/services.dart`. Rejected: does
  not convey "error" semantics to the user on iOS.
- Remove haptics entirely. Rejected: haptic feedback on validation failure is a
  key UX feature.

## R3: Public API Naming Conventions

**Decision**: Rename four parameters to match Flutter SDK conventions.

| Original | Renamed | Precedent |
|----------|---------|-----------|
| `textController` | `controller` | `TextField.controller` |
| `fieldFocusNod` | `focusNode` | `TextField.focusNode` (also fixes typo) |
| `len` | `length` | Standard Dart naming; no abbreviation |
| `shakeOnInValidOtp` | `shakeOnInvalidOtp` | Standard lowerCamelCase |

**Rationale**: Since the package is at version 0.0.1 and has never been
published, these are free renames with no migration cost.

**Alternatives considered**:
- Keep original names and deprecate later. Rejected: creates unnecessary API
  churn post-publication.

## R4: Barrel File Export Strategy

**Decision**: Use explicit `show` clause.

```dart
export 'src/animated_otp_field.dart' show AnimatedOtpField, AnimatedOtpFieldState;
```

**Rationale**: Controls the public API surface precisely. Prevents accidental
export of internal symbols if new public-looking types are added to the source
file.

**Alternatives considered**:
- Bare `export 'src/animated_otp_field.dart';` (original). Rejected: could leak
  unintended symbols.

## R5: Version Number for Initial Release

**Decision**: `0.1.0`

**Rationale**: Semver convention — `0.x.y` signals "initial development, API
may change". The package has never been published, so `1.0.0` would imply API
stability prematurely. `0.0.1` (original) is too low for a feature-complete
package.

**Alternatives considered**:
- `1.0.0` — implies stable API contract. Rejected: premature for first
  publication.
- `0.0.2` — too conservative; this is a major overhaul, not a patch.

## R6: Autofill Implementation

**Decision**: Implement the `AutofillClient.autofill` method to forward values
to the hidden `EditableText` and call `_onChanged`.

**Rationale**: The original implementation left `autofill()` empty, which meant
SMS autofill on iOS/Android silently dropped the value. The fix truncates
over-length values and triggers the normal input flow.

**Alternatives considered**:
- Use `AutofillGroup` wrapper. Rejected: the widget already implements
  `AutofillClient` directly, which gives more control over truncation.

## R7: Timer Safety Pattern

**Decision**: Guard all `Timer` callbacks with `if (mounted)` / `if (!mounted) return`.

**Rationale**: When the user navigates away while an animation timer is pending,
the callback fires on a disposed `State`, causing "used after being disposed"
exceptions. The `mounted` check is the standard Flutter pattern for this.

**Alternatives considered**:
- Cancel all timers in `dispose()`. Rejected: requires tracking every `Timer`
  instance, which is more complex and error-prone for short-lived fire-once
  timers.
- Use `AnimationController` instead of `Timer`. Rejected: would require
  significant refactoring of the sequential valid-animation cascade for marginal
  benefit.

## R8: Testing Strategy

**Decision**: Write comprehensive widget tests in `test/animated_otp_field_test.dart`
using `flutter_test`.

**Rationale**: A pub.dev package must inspire confidence in consumers. Widget
tests verify that the core contract (rendering, input, validation, disposal)
works correctly. Tests also guard against regressions when the package evolves.

**Test coverage areas**:
- Widget renders with default parameters (correct number of pin boxes).
- Digit input updates the displayed value and advances focus.
- Completing all digits fires `onCompleted` with the full OTP string.
- Client-side validation via `isOtpValid` triggers valid/invalid UI.
- Server-side validation via `AnimatedOtpFieldState.validateOtp` triggers
  valid/invalid UI.
- Error decoration is displayed when OTP is invalid.
- Error state clears when user re-focuses the field.
- Widget disposes cleanly without exceptions (no leaked notifiers or timers).

**Alternatives considered**:
- Skip tests for initial release. Rejected: the constitution's Development
  Workflow section encourages test coverage, and tests are essential for
  pub.dev credibility.
- Golden (screenshot) tests. Deferred: useful for visual regression but not
  required for initial publication. Can be added in a follow-up.
