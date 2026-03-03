# Tasks: Code Review & pub.dev Publication Readiness

**Input**: Design documents from `/specs/001-code-review-enhancements/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/public-api.md, quickstart.md
**SDK**: Dart 3.11.0 / Flutter 3.41.2

**Tests**: YES — comprehensive widget tests are required (FR-018, FR-019, SC-009).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. Most bug fixes and documentation are already applied; remaining tasks focus on SDK alignment, outstanding code fixes, full test coverage, and final verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Library**: `lib/src/telegram_animated_otp_field.dart`, `lib/src/widgets/pin_field.dart`, `lib/src/widgets/pin_cursor.dart`
- **Barrel export**: `lib/telegram_animated_otp_field.dart`
- **Tests**: `test/telegram_animated_otp_field_test.dart`
- **Example**: `example/lib/main.dart`
- **Metadata**: `pubspec.yaml`, `README.md`, `CHANGELOG.md`, `LICENSE`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Align SDK constraints and project configuration with Flutter 3.41.2 / Dart 3.11.0.

- [x] T001 Add `flutter: ">=3.41.2"` constraint under `environment:` in `pubspec.yaml` (currently missing)
- [x] T002 [P] Set `homepage` and `repository` URLs in `pubspec.yaml` (replace TODO placeholders on lines 7-9)
- [x] T003 Run `flutter pub get` to regenerate `pubspec.lock` with updated constraints

---

## Phase 2: Foundational (Remaining Bug Fixes)

**Purpose**: Fix outstanding code defects that affect multiple user stories. MUST complete before tests can be written.

**CRITICAL**: These fixes were specified in the code review but are still missing from the source.

- [x] T004 Wrap `Gaimon.error()` call in try-catch in `lib/src/telegram_animated_otp_field.dart` line 400 (FR-005, SC-005) — currently unguarded, will crash on web/desktop
- [x] T005 [P] Run `dart format .` and verify zero changes
- [x] T006 [P] Run `flutter analyze` and verify zero issues across library, example, and test code

**Checkpoint**: All code defects resolved, SDK aligned — test implementation can begin.

---

## Phase 3: User Story 1 — Correct OTP Validation Behavior (Priority: P1) MVP

**Goal**: Verify via widget tests that `isOtpValid` callback fires correctly (with and without `Key`), and that valid/invalid animations trigger appropriately.

**Independent Test**: Create `AnimatedOtpField` with `isOtpValid`, enter a complete OTP, assert `onCompleted` fires and UI state reflects validation result.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation fixes.**

- [x] T007 [US1] Create test file scaffold with imports and `main()` in `test/telegram_animated_otp_field_test.dart`
- [x] T008 [US1] Test: widget renders correct number of pin boxes for default `length: 6` in `test/telegram_animated_otp_field_test.dart`
- [x] T009 [US1] Test: widget renders correct number of pin boxes for custom `length: 4` in `test/telegram_animated_otp_field_test.dart`
- [x] T010 [US1] Test: `onCompleted` callback fires with full OTP string when all digits entered in `test/telegram_animated_otp_field_test.dart`
- [x] T011 [US1] Test: `isOtpValid` returning `true` triggers valid decoration state in `test/telegram_animated_otp_field_test.dart`
- [x] T012 [US1] Test: `isOtpValid` returning `false` triggers error decoration and validation message in `test/telegram_animated_otp_field_test.dart`
- [x] T013 [US1] Test: validation works correctly when widget has a `GlobalKey` in `test/telegram_animated_otp_field_test.dart`
- [x] T014 [US1] Test: re-focusing the field after error clears error decoration and message in `test/telegram_animated_otp_field_test.dart`

**Checkpoint**: US1 tests verify core validation contract. Run `flutter test` — all US1 tests pass.

---

## Phase 4: User Story 2 — Stable Widget Lifecycle (Priority: P1)

**Goal**: Verify via widget tests that the widget disposes cleanly without leaked notifiers, timers, or exceptions.

**Independent Test**: Mount the widget, trigger animations, then dispose mid-animation. Assert no exceptions thrown.

### Tests for User Story 2

- [x] T015 [US2] Test: widget disposes without exceptions when no interaction occurs in `test/telegram_animated_otp_field_test.dart`
- [x] T016 [US2] Test: widget disposes cleanly during active valid-OTP animation (mid-timer) in `test/telegram_animated_otp_field_test.dart`
- [x] T017 [US2] Test: widget with externally provided `controller` and `focusNode` does NOT dispose them in `test/telegram_animated_otp_field_test.dart`
- [x] T018 [US2] Test: widget with null `controller` and `focusNode` disposes its own internally created instances in `test/telegram_animated_otp_field_test.dart`

**Checkpoint**: US2 tests verify lifecycle safety. Run `flutter test` — all US1 + US2 tests pass.

---

## Phase 5: User Story 3 — SMS Autofill Works on Mobile (Priority: P2)

**Goal**: Verify via widget tests that the `autofill` method correctly forwards values to the internal field and triggers validation, including truncation of over-length values.

**Independent Test**: Programmatically invoke `autofill()` on the state and assert the field value updates correctly.

### Tests for User Story 3

- [x] T019 [US3] Test: `autofill` with exact-length value fills all pins and triggers `onCompleted` in `test/telegram_animated_otp_field_test.dart`
- [x] T020 [US3] Test: `autofill` with over-length value truncates to `length` in `test/telegram_animated_otp_field_test.dart`

**Checkpoint**: US3 tests verify autofill contract. Run `flutter test` — all US1–US3 tests pass.

---

## Phase 6: User Story 4 — Clean Public API for Package Consumers (Priority: P2)

**Goal**: Verify via widget tests that the widget renders correctly with zero required parameters and all defaults produce a functional field.

**Independent Test**: Create `AnimatedOtpField()` with no parameters, verify it renders and accepts input.

### Tests for User Story 4

- [x] T021 [US4] Test: `AnimatedOtpField()` with zero parameters renders a functional 6-digit field in `test/telegram_animated_otp_field_test.dart`
- [x] T022 [US4] Test: custom `pinDecoration`, `focusedPinDecoration`, and `errorPinDecoration` are applied in `test/telegram_animated_otp_field_test.dart`
- [x] T023 [US4] Test: `validateOtp(true)` via `GlobalKey<AnimatedOtpFieldState>` triggers valid state in `test/telegram_animated_otp_field_test.dart`
- [x] T024 [US4] Test: `validateOtp(false)` via `GlobalKey<AnimatedOtpFieldState>` triggers error state in `test/telegram_animated_otp_field_test.dart`

**Checkpoint**: US4 tests verify public API defaults and server-side validation. Run `flutter test` — all US1–US4 tests pass.

---

## Phase 7: User Story 5 — Cross-Platform Graceful Degradation (Priority: P3)

**Goal**: Verify that `Gaimon.error()` is wrapped in try-catch (T004) so invalid OTP does not throw on web/desktop.

**Independent Test**: Trigger invalid OTP in test environment (which has no native haptics). Assert no exceptions.

### Tests for User Story 5

- [x] T025 [US5] Test: invalid OTP does not throw exception when haptic feedback is unavailable (test environment) in `test/telegram_animated_otp_field_test.dart`
- [x] T026 [US5] Test: `shakeOnInvalidOtp: false` disables shake but still shows error decoration in `test/telegram_animated_otp_field_test.dart`

**Checkpoint**: US5 tests verify graceful degradation. Run `flutter test` — all tests pass.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final verification that all quality gates pass before publication.

- [x] T027 Run `dart format .` — zero files changed (SC-002)
- [x] T028 Run `flutter analyze` — zero issues across library, example, and test code (SC-001)
- [x] T029 Run `flutter test` — zero failures, all 20 tests pass (SC-009)
- [x] T030 Run `dart pub publish --dry-run` — zero errors (SC-003)
- [x] T031 Verify example app runs successfully with `cd example && flutter run` (SC-007)
- [x] T032 [P] Verify dartdoc coverage: all public classes, constructors, properties, and methods have `///` comments (SC-004)
- [x] T033 [P] Verify README contains 3+ code examples: basic, server-side, custom appearance (SC-008)
- [x] T034 Update CHANGELOG.md to document widget test additions under version 0.1.0 in `CHANGELOG.md`
- [x] T035 Run quickstart.md validation: follow `specs/001-code-review-enhancements/quickstart.md` steps end-to-end

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories (T004 is critical for US5 tests)
- **User Stories (Phases 3–7)**: All depend on Foundational phase completion
  - US1 (Phase 3) and US2 (Phase 4) can proceed in parallel
  - US3 (Phase 5) and US4 (Phase 6) can proceed in parallel after US1
  - US5 (Phase 7) depends on T004 (Gaimon try-catch fix)
- **Polish (Phase 8)**: Depends on all user story phases being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no dependencies on other stories
- **US2 (P1)**: Can start after Phase 2 — no dependencies on other stories. Can run in parallel with US1
- **US3 (P2)**: Can start after Phase 2 — independent of other stories
- **US4 (P2)**: Can start after Phase 2 — uses `GlobalKey<AnimatedOtpFieldState>` (same as US1 T013)
- **US5 (P3)**: Depends on T004 (Gaimon try-catch) from Phase 2

### Within Each User Story

- Tests MUST be written and verified to FAIL (or pass once code is correct)
- Each story's tests should be independently runnable
- Story complete = all tests in that story pass

### Parallel Opportunities

- T001 and T002 (Setup) can run in parallel
- T005 and T006 (Foundational verification) can run in parallel
- US1 (Phase 3) and US2 (Phase 4) can be developed in parallel (different test groups)
- US3 (Phase 5) and US4 (Phase 6) can be developed in parallel
- T027, T028, T029, T030 (Polish verification) run sequentially but are fast
- T032 and T033 (documentation checks) can run in parallel

---

## Parallel Example: User Story 1 + User Story 2

```bash
# Both user stories can start at the same time after Phase 2:

# Developer A — US1 (validation tests):
Task T008: "Test: widget renders correct number of pin boxes for default length"
Task T010: "Test: onCompleted fires with full OTP"
Task T011: "Test: isOtpValid true triggers valid decoration"
Task T012: "Test: isOtpValid false triggers error decoration"

# Developer B — US2 (lifecycle tests):
Task T015: "Test: widget disposes without exceptions"
Task T016: "Test: widget disposes cleanly during animation"
Task T017: "Test: external controller/focusNode not disposed"
```

---

## Implementation Strategy

### MVP First (US1 + US2 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational bug fix (T004–T006)
3. Complete Phase 3: US1 validation tests (T007–T014)
4. Complete Phase 4: US2 lifecycle tests (T015–T018)
5. **STOP and VALIDATE**: `flutter test` — all P1 tests pass
6. This gives confidence in the two most critical user stories

### Incremental Delivery

1. Setup + Foundational → SDK aligned, bugs fixed
2. US1 + US2 tests → Core validation and lifecycle verified (MVP!)
3. US3 tests → Autofill verified
4. US4 tests → Public API defaults and server-side validation verified
5. US5 tests → Cross-platform safety verified
6. Polish → All quality gates pass, ready to publish

### Single Developer Strategy (Recommended)

1. T001–T003 (Setup) — 5 min
2. T004–T006 (Foundational) — 10 min
3. T007–T014 (US1 tests) — 30 min
4. T015–T018 (US2 tests) — 20 min
5. T019–T020 (US3 tests) — 10 min
6. T021–T024 (US4 tests) — 15 min
7. T025–T026 (US5 tests) — 10 min
8. T027–T035 (Polish) — 15 min
**Total estimated**: ~2 hours

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- All tests written in a single file `test/telegram_animated_otp_field_test.dart` grouped by `group()` per user story
- The existing test file is a commented-out placeholder — T007 replaces it entirely
- T004 (Gaimon try-catch) is the only remaining code fix; all other FR bug fixes from the code review are already applied
- Commit after each phase completion
- Stop at any checkpoint to validate independently
