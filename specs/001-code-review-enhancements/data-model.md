# Data Model: Code Review & pub.dev Publication Readiness

**Branch**: `001-code-review-enhancements`
**Date**: 2026-03-03

## Widget Entity Model

This package has no persistent data model. The entities below describe the
runtime widget tree and its internal state.

### AnimatedOtpField (public StatefulWidget)

The top-level widget consumers add to their build tree.

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| `length` | `int` | `6` | Number of OTP digits (pin boxes) |
| `pinSize` | `Size` | `Size(45, 45)` | Dimensions of each pin box |
| `spacing` | `double` | `8` | Horizontal gap between pin boxes |
| `controller` | `TextEditingController?` | `null` | External text controller |
| `focusNode` | `FocusNode?` | `null` | External focus node |
| `isOtpValid` | `bool Function(String)?` | `null` | Client-side validation callback |
| `onCompleted` | `void Function(String)?` | `null` | Fires when all digits entered |
| `onValidationAnimationDone` | `VoidCallback?` | `null` | Fires after success animation |
| `pinDecoration` | `BoxDecoration?` | `null` | Default pin appearance |
| `focusedPinDecoration` | `BoxDecoration?` | `null` | Focused pin appearance |
| `errorPinDecoration` | `BoxDecoration?` | `null` | Error-state pin appearance |
| `validPinDecoration` | `BoxDecoration?` | `null` | Valid-state pin appearance |
| `valueTextStyle` | `TextStyle?` | `null` | Digit text style |
| `cursorTextStyle` | `TextStyle?` | `null` | Default cursor text style |
| `cursor` | `Widget?` | `null` | Custom cursor widget |
| `showCursor` | `bool` | `true` | Show/hide cursor |
| `shakeOnInvalidOtp` | `bool` | `true` | Shake on invalid |
| `showValidationMsg` | `bool` | `true` | Show error message |
| `validationMsg` | `String` | `'Invalid OTP'` | Error message text |
| `validationMsgTextStyle` | `TextStyle?` | `null` | Error message style |
| `ignorePointer` | `bool` | `false` | Disable input |
| `autofillHints` | `Iterable<String>?` | `[oneTimeCode]` | Autofill hints |
| `pinAnimationDuration` | `Duration` | `300ms` | Decoration transition |
| `extraFieldHeight` | `double` | `0` | Extra space below |
| `enableTextSelection` | `bool` | `true` | Allow text selection |
| `customErrorMsgTween` | `Tween<Offset> Function()?` | `null` | Custom error tween |

### AnimatedOtpFieldState (public State)

Internal state of the OTP field. Exposes one public method.

| Member | Type | Purpose |
|--------|------|---------|
| `validateOtp(bool)` | Method | Programmatic server-side validation trigger |
| `editableTextKey` | `GlobalKey<EditableTextState>` | Key for hidden EditableText |

**Internal state notifiers** (all disposed in `dispose()`):

| Notifier | Type | Purpose |
|----------|------|---------|
| `_currentFocus` | `ValueNotifier<int>` | Index of focused pin (-1 = none) |
| `_currentValue` | `ValueNotifier<String>` | Current OTP text |
| `_showInvalidOtpDecoration` | `ValueNotifier<bool>` | Error decoration flag |
| `_validAnimationFlags` | `List<ValueNotifier<bool>>` | Per-pin valid animation flag |
| `_validationMsg` | `ValueNotifier<String>` | Displayed error message text |

### _PinField (internal StatefulWidget)

A single pin box. Receives all data via constructor parameters from the
parent's `ListenableBuilder`.

**Animation states**:

```text
[Empty + Unfocused] → [Empty + Focused (cursor blinks)]
                    → [Filled (bounce-in from bottom)]
                    → [Invalid (error border + shake)]
                    → [Valid (scale pulse 1.08x → 1.0x)]
```

### _PinCursor (internal StatefulWidget)

A blinking cursor using `FadeTransition` driven by an `AnimationController`
repeating with `reverse: true` at 450 ms.

## State Transitions

```text
                    ┌─────────────────────────────┐
                    │        IDLE (empty)          │
                    │  _currentFocus == -1         │
                    │  _currentValue == ""         │
                    └──────────┬──────────────────┘
                               │ tap / focus
                               ▼
                    ┌─────────────────────────────┐
                    │       FOCUSED (typing)       │
                    │  _currentFocus >= 0          │
                    │  cursor blinks in active pin │
                    └──────────┬──────────────────┘
                               │ value.length == length
                               ▼
                    ┌─────────────────────────────┐
                    │       COMPLETED              │
                    │  onCompleted fires           │
                    │  focus removed               │
                    └──────┬───────────┬──────────┘
                           │           │
                 isOtpValid │           │ validateOtp(bool)
                 returns    │           │ called externally
                           ▼           ▼
              ┌────────────────┐  ┌────────────────┐
              │ VALID          │  │ INVALID        │
              │ scale pulse    │  │ shake + error  │
              │ per-pin seq.   │  │ decoration     │
              │ onValidation   │  │ haptic feedback│
              │ AnimationDone  │  │ validation msg │
              └────────────────┘  └───────┬────────┘
                                          │ re-focus
                                          ▼
                                 ┌─────────────────┐
                                 │ FOCUSED (reset)  │
                                 │ error cleared    │
                                 └─────────────────┘
```
