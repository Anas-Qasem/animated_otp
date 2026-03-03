# Quick Start: animated_otp_field

**Branch**: `001-code-review-enhancements`
**Date**: 2026-03-03

## Prerequisites

- Flutter SDK >= 3.41.2
- Dart SDK >= 3.11.0

## Install

```yaml
# pubspec.yaml
dependencies:
  animated_otp_field: ^0.1.0
```

```bash
flutter pub get
```

## Basic Usage (Client-Side Validation)

```dart
import 'package:animated_otp_field/animated_otp_field.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOtpField(
          length: 6,
          isOtpValid: (otp) => otp == '123456',
          onCompleted: (otp) => debugPrint('Entered: $otp'),
          onValidationAnimationDone: () {
            debugPrint('Success animation finished');
          },
        ),
      ),
    );
  }
}
```

## Server-Side Validation

```dart
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpKey = GlobalKey<AnimatedOtpFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOtpField(
          key: _otpKey,
          length: 6,
          onCompleted: (otp) async {
            // Call your server API
            final isValid = await _verifyOtp(otp);
            _otpKey.currentState?.validateOtp(isValid);
          },
        ),
      ),
    );
  }

  Future<bool> _verifyOtp(String otp) async {
    // Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    return otp == '123456';
  }
}
```

## Custom Appearance

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

## Run the Example

```bash
cd example
flutter run
```

Enter `123456` for a valid OTP (success animation), or any other code to see
the shake and error feedback.

## Run Tests

```bash
flutter test
```

All widget tests should pass with zero failures.

## Verify Package Health

```bash
# Format
dart format .

# Analyze
flutter analyze

# Run tests
flutter test

# Dry-run publish
dart pub publish --dry-run
```

All four commands should report zero issues.
