# Animated OTP Field

A highly customizable, animated OTP (One-Time Password) input field for Flutter.
Each digit pops in with a smooth bounce animation, the active box shows a
blinking cursor, and validation triggers either a sequential success pulse or a
shake with haptic feedback.

## Features

- Smooth bounce-in animation on digit entry
- Blinking cursor in the active pin box
- Shake animation with haptic feedback on invalid OTP
- Sequential scale-pulse animation on valid OTP
- Customizable pin decoration for default, focused, error, and valid states
- Custom cursor widget support
- Client-side and server-side validation support
- Autofill support (`oneTimeCode` hint)
- RTL layout support
- Validation message with slide-in animation

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  animated_otp_field: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic — Client-Side Validation

```dart
AnimatedOtpField(
  length: 6,
  isOtpValid: (otp) => otp == '123456',
  onCompleted: (otp) => print('Entered: $otp'),
)
```

### Server-Side Validation

Use a `GlobalKey` to trigger validation after a server response:

```dart
final otpKey = GlobalKey<AnimatedOtpFieldState>();

AnimatedOtpField(
  key: otpKey,
  length: 4,
  onCompleted: (otp) async {
    final isValid = await api.verifyOtp(otp);
    otpKey.currentState?.validateOtp(isValid);
  },
)
```

### Custom Appearance

```dart
AnimatedOtpField(
  length: 6,
  pinSize: const Size(56, 56),
  spacing: 12,
  valueTextStyle: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
  pinDecoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  focusedPinDecoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue, width: 2),
  ),
  isOtpValid: (otp) => otp == '123456',
)
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `length` | `int` | `6` | Number of OTP digits |
| `pinSize` | `Size` | `Size(45, 45)` | Size of each pin box |
| `spacing` | `double` | `8` | Horizontal gap between boxes |
| `controller` | `TextEditingController?` | `null` | External text controller |
| `focusNode` | `FocusNode?` | `null` | External focus node |
| `isOtpValid` | `bool Function(String)?` | `null` | Client-side validation |
| `onCompleted` | `void Function(String)?` | `null` | Called when all digits entered |
| `onValidationAnimationDone` | `VoidCallback?` | `null` | Called after success animation |
| `pinDecoration` | `BoxDecoration?` | `null` | Default pin box decoration |
| `focusedPinDecoration` | `BoxDecoration?` | `null` | Focused pin box decoration |
| `errorPinDecoration` | `BoxDecoration?` | `null` | Error-state decoration |
| `validPinDecoration` | `BoxDecoration?` | `null` | Valid-state decoration |
| `valueTextStyle` | `TextStyle?` | `null` | Style for digit text |
| `cursorTextStyle` | `TextStyle?` | `null` | Style for default `\|` cursor |
| `cursor` | `Widget?` | `null` | Custom cursor widget |
| `showCursor` | `bool` | `true` | Show/hide blinking cursor |
| `shakeOnInvalidOtp` | `bool` | `true` | Shake on invalid OTP |
| `showValidationMsg` | `bool` | `true` | Show error message |
| `validationMsg` | `String` | `'Invalid OTP'` | Error message text |
| `validationMsgTextStyle` | `TextStyle?` | `null` | Error message style |
| `ignorePointer` | `bool` | `false` | Disable all input |
| `autofillHints` | `Iterable<String>?` | `[oneTimeCode]` | Autofill hints |
| `pinAnimationDuration` | `Duration` | `300ms` | Decoration transition duration |
| `extraFieldHeight` | `double` | `0` | Extra space below pin row |
| `enableTextSelection` | `bool` | `true` | Enable text selection |
| `customErrorMsgTween` | `Tween<Offset> Function()?` | `null` | Custom error animation |

## License

MIT License — see [LICENSE](LICENSE) for details.
