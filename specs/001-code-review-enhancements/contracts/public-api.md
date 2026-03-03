# Public API Contract: telegram_animated_otp_field

**Branch**: `001-code-review-enhancements`
**Date**: 2026-03-03
**Version**: 0.1.0

## Exported Symbols

The barrel file `lib/telegram_animated_otp_field.dart` exports exactly two symbols:

```dart
export 'src/telegram_animated_otp_field.dart' show AnimatedOtpField, AnimatedOtpFieldState;
```

All other types (`_PinField`, `_PinCursor`, internal state) are library-private.

## AnimatedOtpField

**Type**: `StatefulWidget`
**Constructor**: `const AnimatedOtpField({...})`
**Required parameters**: None (all optional with sensible defaults)

### Constructor Parameters

| Parameter | Type | Default | Constraint |
|-----------|------|---------|------------|
| `key` | `Key?` | `null` | Standard widget key |
| `length` | `int` | `6` | Must be > 0 |
| `pinSize` | `Size` | `Size(45, 45)` | Width and height > 0 |
| `spacing` | `double` | `8` | >= 0 |
| `controller` | `TextEditingController?` | `null` | Caller owns lifecycle |
| `focusNode` | `FocusNode?` | `null` | Caller owns lifecycle |
| `isOtpValid` | `bool Function(String)?` | `null` | Called on completion |
| `onCompleted` | `void Function(String)?` | `null` | Called on completion |
| `onValidationAnimationDone` | `VoidCallback?` | `null` | Called after last pin animates |
| `pinDecoration` | `BoxDecoration?` | `null` | Falls back to grey border, 8px radius |
| `focusedPinDecoration` | `BoxDecoration?` | `null` | Falls back to primaryColor border |
| `errorPinDecoration` | `BoxDecoration?` | `null` | Falls back to error color border |
| `validPinDecoration` | `BoxDecoration?` | `null` | Falls back to green border |
| `valueTextStyle` | `TextStyle?` | `null` | Falls back to `fontSize: 20` |
| `cursorTextStyle` | `TextStyle?` | `null` | Falls back to primaryColor |
| `cursor` | `Widget?` | `null` | Falls back to blinking `\|` text |
| `showCursor` | `bool` | `true` | — |
| `shakeOnInvalidOtp` | `bool` | `true` | — |
| `showValidationMsg` | `bool` | `true` | — |
| `validationMsg` | `String` | `'Invalid OTP'` | — |
| `validationMsgTextStyle` | `TextStyle?` | `null` | Falls back to red 16px semi-bold |
| `ignorePointer` | `bool` | `false` | — |
| `autofillHints` | `Iterable<String>?` | `[oneTimeCode]` | — |
| `pinAnimationDuration` | `Duration` | `300ms` | — |
| `extraFieldHeight` | `double` | `0` | — |
| `enableTextSelection` | `bool` | `true` | — |
| `customErrorMsgTween` | `Tween<Offset> Function()?` | `null` | — |

## AnimatedOtpFieldState

**Type**: `State<AnimatedOtpField>`
**Implements**: `TextSelectionGestureDetectorBuilderDelegate`, `AutofillClient`

### Public Members

| Member | Signature | Purpose |
|--------|-----------|---------|
| `validateOtp` | `void validateOtp(bool value)` | Trigger validation UI programmatically (server-side) |
| `editableTextKey` | `GlobalKey<EditableTextState>` | Key for the hidden EditableText (framework override) |

### Usage Pattern (server-side validation)

```dart
final otpKey = GlobalKey<AnimatedOtpFieldState>();

AnimatedOtpField(
  key: otpKey,
  onCompleted: (otp) async {
    final isValid = await myApi.verifyOtp(otp);
    otpKey.currentState?.validateOtp(isValid);
  },
)
```

## Behavioral Contract

1. **Zero required params**: `AnimatedOtpField()` renders a functional 6-digit OTP field.
2. **Owned vs external resources**: If `controller` or `focusNode` is null, the widget creates and disposes its own. If provided, the caller is responsible for disposal.
3. **Validation flow**: `isOtpValid` is called on completion if provided. For server-side, call `validateOtp(bool)` on the state.
4. **Autofill**: Values from the OS are truncated to `length` and fed through the normal input flow.
5. **Platform safety**: Haptic feedback degrades gracefully on unsupported platforms (web, desktop).
6. **Layout**: Pins always render LTR. Error message respects the ambient `Directionality`.
7. **Testing**: The package includes comprehensive widget tests in `test/telegram_animated_otp_field_test.dart` covering rendering, input, validation (client-side and server-side), error states, and disposal. All tests must pass via `flutter test`.

## SDK Requirements

- **Flutter**: >= 3.41.2
- **Dart**: ^3.11.0
