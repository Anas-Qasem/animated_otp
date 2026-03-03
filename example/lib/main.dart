import 'package:telegram_animated_otp_field/telegram_animated_otp_field.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const OtpExampleApp());
}

/// Example app demonstrating [AnimatedOtpField] usage.
class OtpExampleApp extends StatelessWidget {
  const OtpExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated OTP Field Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const OtpVerificationPage(),
    );
  }
}

/// A demo page that shows an OTP verification screen.
///
/// Enter `123456` for a valid OTP to see the success animation.
/// Any other 6-digit code triggers the shake and error feedback.
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpKey = GlobalKey<AnimatedOtpFieldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'OTP Verification',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to your phone',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Client-side validation: the OTP is valid when it equals
                // "123456". Any other input triggers the error animation.
                AnimatedOtpField(
                  key: _otpKey,
                  length: 6,
                  pinSize: const Size(50, 50),
                  isOtpValid: (otp) => otp == '123456',
                  onCompleted: (otp) {
                    debugPrint('OTP entered: $otp');
                  },
                  onValidationAnimationDone: () {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP Verified!')),
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Hint: enter 123456 for a valid OTP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
