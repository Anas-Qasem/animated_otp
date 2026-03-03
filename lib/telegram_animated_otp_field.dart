/// An animated OTP (One-Time Password) input field widget for Flutter.
///
/// Provides [AnimatedOtpField], a drop-in widget that renders animated pin
/// boxes with built-in validation feedback (shake, haptic, success animation).
///
/// ```dart
/// import 'package:telegram_animated_otp_field/telegram_animated_otp_field.dart';
///
/// AnimatedOtpField(
///   length: 6,
///   onCompleted: (otp) => print('Entered: $otp'),
///   isOtpValid: (otp) => otp == '123456',
/// )
/// ```
library;

export 'src/telegram_animated_otp_field.dart' show AnimatedOtpField, AnimatedOtpFieldState;
