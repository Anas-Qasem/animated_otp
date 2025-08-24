part of '../animated_otp_field.dart';

/// An individual pin field widget representing a single digit/character input box.
/// Handles the display of the value, cursor, and valid/invalid/focused states with animations.
class _PinField extends StatefulWidget {
  const _PinField({
    required this.value,
    required this.isFocus,
    required this.isLastPin,
    required this.showValidOtp,
    required this.showInValidOTP,
    required this.animatedOtpField,
    required this.onValidationAnimationDone,
    required this.shakeAnimationController,
  });

  /// The current single character value displayed in this pin field.
  final String value;

  /// Indicates if this pin field is currently focused and should show the cursor.
  final bool isFocus;

  /// Indicates if this is the last pin field in the sequence.
  /// Used to trigger the [onValidationAnimationDone] callback at the end of the valid animation.
  final bool isLastPin;

  /// Controls whether to show the valid OTP decoration and animation for this pin field.
  final bool showValidOtp;

  /// Controls whether to show the invalid OTP decoration for this pin field.
  final bool showInValidOTP;

  /// A reference back to the parent [AnimatedOtpField] widget to access its properties.
  final AnimatedOtpField animatedOtpField;

  /// A callback function to be called when the valid animation for the last pin field finishes.
  final VoidCallback onValidationAnimationDone;

  /// The controller for the shake animation, used when the OTP is invalid.
  final ShakeAnimationController shakeAnimationController;

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  late final ValueNotifier<Alignment> alignment;
  late final ValueNotifier<Matrix4> scale;
  late final Alignment defualtAlignValue;
  late final Matrix4 defualtScaleValue;

  @override
  void initState() {
    super.initState();

    defualtAlignValue = const Alignment(0.0, 2.4);
    defualtScaleValue = Matrix4.diagonal3Values(1.0, 1.0, 1.0);
    alignment = ValueNotifier(defualtAlignValue);
    scale = ValueNotifier(defualtScaleValue);
  }

  @override
  void didUpdateWidget(covariant _PinField oldWidget) {
    if (widget.value.isNotEmpty && widget.value != oldWidget.value) {
      alignment.value = const Alignment(0.0, -.2);

      /// for bouncing effect
      Timer(Duration(milliseconds: 200), () => alignment.value = const Alignment(0.0, 0.0));
    } else if (widget.value.isEmpty) {
      alignment.value = defualtAlignValue;
    } else if (widget.showValidOtp) {
      // Start valid animation only when showValidOtp becomes true
      scale.value = Matrix4.diagonal3Values(1.08, 1.08, 1.0);

      /// for scaling effect
      Timer(Duration(milliseconds: 120), () {
        scale.value = defualtScaleValue;
        if (widget.isLastPin) widget.onValidationAnimationDone();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Remove listener for shake animation controller if needed, or handle in parent.
    // widget.shakeAnimationController.removeListener(); // This line seems incorrect here.
    alignment.dispose();
    scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: scale,
      builder: (context, scale, child) {
        return AnimatedContainer(
          transform: scale,
          clipBehavior: Clip.hardEdge,
          decoration: _fieldDecoration(context),
          width: widget.animatedOtpField.pinSize.width,
          height: widget.animatedOtpField.pinSize.height,
          duration: widget.animatedOtpField.pinAnimationDuration,
          child: child!,
        );
      },
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          /// cursor
          if (widget.value.isEmpty && widget.animatedOtpField.showCursor && widget.isFocus) ...[
            Align(
              alignment: Alignment.center,
              child: _PinCursor(
                cursor: widget.animatedOtpField.cursor,
                cursorTextStyle: widget.animatedOtpField.cursorTextStyle,
              ),
            )
          ],

          /// value
          ValueListenableBuilder<Alignment>(
            valueListenable: alignment,
            builder: (context, alignment, child) {
              return AnimatedAlign(
                curve: Curves.ease,
                duration: Duration(milliseconds: 200),
                alignment: alignment,
                child: child!,
              );
            },
            child: Text(widget.value, style: widget.animatedOtpField.valueTextStyle ?? TextStyle(fontSize: 20)),
          )
        ],
      ),
    );
  }

  Decoration _fieldDecoration(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);
    final BoxDecoration defualtDecoration = widget.animatedOtpField.pinDecoration ?? _defualtDecoration();
    //
    if (widget.showInValidOTP) {
      return widget.animatedOtpField.errorPinDecoration ??
          defualtDecoration.copyWith(border: Border.all(width: 1.5, color: appTheme.colorScheme.error));
    }

    if (widget.showValidOtp) {
      return widget.animatedOtpField.validPinDecoration ?? defualtDecoration.copyWith(border: Border.all(width: 1.8, color: Colors.green));
    }

    if (widget.isFocus) {
      return widget.animatedOtpField.focusedPinDecoration ?? defualtDecoration.copyWith(border: Border.all(width: 1.5, color: appTheme.primaryColor));
    }
    return defualtDecoration;
  }

  BoxDecoration _defualtDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        width: 1,
        color: Colors.grey[350]!,
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }
}
