part of '../animated_otp_field.dart';

/// A single pin box within the [AnimatedOtpField].
///
/// Displays one digit with animated transitions for entry (bounce-in),
/// focus highlighting, valid (scale-pulse), and invalid (error border) states.
class _PinField extends StatefulWidget {
  const _PinField({
    required this.value,
    required this.isFocus,
    required this.isLastPin,
    required this.showValidOtp,
    required this.showInvalidOtp,
    required this.animatedOtpField,
    required this.onValidationAnimationDone,
  });

  /// The single-character value displayed in this pin box.
  final String value;

  /// Whether this pin box is currently focused (shows the cursor).
  final bool isFocus;

  /// Whether this is the last pin in the sequence. Used to fire
  /// [onValidationAnimationDone] at the end of the success animation.
  final bool isLastPin;

  /// Whether to show the valid-OTP decoration and scale-pulse animation.
  final bool showValidOtp;

  /// Whether to show the invalid-OTP error decoration.
  final bool showInvalidOtp;

  /// Reference to the parent widget for reading style and size properties.
  final AnimatedOtpField animatedOtpField;

  /// Called when the valid-OTP animation on the last pin finishes.
  final VoidCallback onValidationAnimationDone;

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  late final ValueNotifier<Alignment> _alignment;
  late final ValueNotifier<Matrix4> _scale;

  static const _defaultAlignment = Alignment(0.0, 2.4);
  static final _defaultScale = Matrix4.diagonal3Values(1.0, 1.0, 1.0);

  @override
  void initState() {
    super.initState();
    _alignment = ValueNotifier(_defaultAlignment);
    _scale = ValueNotifier(_defaultScale);
  }

  @override
  void didUpdateWidget(covariant _PinField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value.isNotEmpty && widget.value != oldWidget.value) {
      _alignment.value = const Alignment(0.0, -0.2);
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) _alignment.value = Alignment.center;
      });
    } else if (widget.value.isEmpty) {
      _alignment.value = _defaultAlignment;
    } else if (widget.showValidOtp && !oldWidget.showValidOtp) {
      _scale.value = Matrix4.diagonal3Values(1.08, 1.08, 1.0);
      Timer(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        _scale.value = _defaultScale;
        if (widget.isLastPin) widget.onValidationAnimationDone();
      });
    }
  }

  @override
  void dispose() {
    _alignment.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Matrix4>(
      valueListenable: _scale,
      builder: (context, scaleValue, child) {
        return AnimatedContainer(
          transform: scaleValue,
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
          if (widget.value.isEmpty &&
              widget.animatedOtpField.showCursor &&
              widget.isFocus)
            Align(
              alignment: Alignment.center,
              child: _PinCursor(
                cursor: widget.animatedOtpField.cursor,
                cursorTextStyle: widget.animatedOtpField.cursorTextStyle,
              ),
            ),
          ValueListenableBuilder<Alignment>(
            valueListenable: _alignment,
            builder: (context, alignValue, child) {
              return AnimatedAlign(
                curve: Curves.ease,
                alignment: alignValue,
                duration: const Duration(milliseconds: 200),
                child: child!,
              );
            },
            child: Text(
              widget.value,
              style: widget.animatedOtpField.valueTextStyle ??
                  const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Decoration _fieldDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final defaultDecoration =
        widget.animatedOtpField.pinDecoration ?? _defaultDecoration();

    if (widget.showInvalidOtp) {
      return widget.animatedOtpField.errorPinDecoration ??
          defaultDecoration.copyWith(
            border: Border.all(width: 1.5, color: theme.colorScheme.error),
          );
    }

    if (widget.showValidOtp) {
      return widget.animatedOtpField.validPinDecoration ??
          defaultDecoration.copyWith(
            border: Border.all(width: 1.8, color: Colors.green),
          );
    }

    if (widget.isFocus) {
      return widget.animatedOtpField.focusedPinDecoration ??
          defaultDecoration.copyWith(
            border: Border.all(width: 1.5, color: theme.primaryColor),
          );
    }

    return defaultDecoration;
  }

  BoxDecoration _defaultDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(width: 1, color: Colors.grey[350]!),
      borderRadius: BorderRadius.circular(8),
    );
  }
}
