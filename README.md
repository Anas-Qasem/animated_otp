# Animated OTP Field

[![Demo](https://github.com/Anas-Qasem/animated_otp/blob/main/demo/demo.gif?raw=true)](https://github.com/Anas-Qasem/animated_otp/blob/main/demo/demo.gif)

A highly customizable, animated OTP (One-Time Password) input field for Flutter.
Each digit pops in with a smooth bounce animation similar to Telegram, the active box shows a
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
  telegram_animated_otp_field: ^0.1.0
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

## License

MIT License — see [LICENSE](LICENSE) for details.
