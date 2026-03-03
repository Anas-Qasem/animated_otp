import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaimon/gaimon.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

part 'widgets/pin_field.dart';
part 'widgets/pin_cursor.dart';

/// A highly customizable, animated OTP (One-Time Password) input field.
///
/// Displays a row of individual pin boxes that accept numeric input. Each
/// pin animates as the user types, and the widget provides visual feedback
/// for valid and invalid OTP entries including shake animations, haptic
/// feedback, and sequential validation animations.
///
/// ## Client-side validation
///
/// ```dart
/// AnimatedOtpField(
///   length: 6,
///   onCompleted: (otp) => print('Entered: $otp'),
///   isOtpValid: (otp) => otp == '123456',
/// )
/// ```
///
/// ## Server-side validation
///
/// Use a [GlobalKey] to access [AnimatedOtpFieldState.validateOtp]:
///
/// ```dart
/// final otpKey = GlobalKey<AnimatedOtpFieldState>();
///
/// AnimatedOtpField(
///   key: otpKey,
///   length: 4,
///   onCompleted: (otp) async {
///     final isValid = await api.verifyOtp(otp);
///     otpKey.currentState?.validateOtp(isValid);
///   },
/// )
/// ```
///
/// See also:
///
/// - [AnimatedOtpFieldState.validateOtp] for triggering validation
///   programmatically.
class AnimatedOtpField extends StatefulWidget {
  /// Creates an animated OTP input field.
  ///
  /// The [length] determines how many pin boxes are displayed (defaults to 6).
  const AnimatedOtpField({
    super.key,
    this.cursor,
    this.length = 6,
    this.isOtpValid,
    this.onCompleted,
    this.spacing = 8,
    this.pinDecoration,
    this.focusNode,
    this.controller,
    this.valueTextStyle,
    this.cursorTextStyle,
    this.showCursor = true,
    this.errorPinDecoration,
    this.validPinDecoration,
    this.extraFieldHeight = 0,
    this.customErrorMsgTween,
    this.focusedPinDecoration,
    this.ignorePointer = false,
    this.validationMsgTextStyle,
    this.onValidationAnimationDone,
    this.shakeOnInvalidOtp = true,
    this.showValidationMsg = true,
    this.enableTextSelection = true,
    this.pinSize = const Size(45, 45),
    this.validationMsg = 'Invalid OTP',
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.pinAnimationDuration = const Duration(milliseconds: 300),
  });

  /// Whether the user can select text within the hidden input field.
  ///
  /// Defaults to `true`.
  final bool enableTextSelection;

  /// Controls the text being edited.
  ///
  /// If null, the widget creates and disposes its own controller internally.
  /// If you provide your own [TextEditingController], you are responsible for
  /// disposing it.
  ///
  /// ```dart
  /// final controller = TextEditingController();
  ///
  /// AnimatedOtpField(controller: controller)
  /// ```
  final TextEditingController? controller;

  /// The focus node for the OTP field.
  ///
  /// If null, the widget creates and disposes its own [FocusNode] internally.
  /// If you provide your own, you are responsible for disposing it.
  ///
  /// ```dart
  /// final focusNode = FocusNode();
  ///
  /// AnimatedOtpField(focusNode: focusNode)
  /// ```
  final FocusNode? focusNode;

  /// The number of OTP digits to accept.
  ///
  /// Determines the number of pin boxes rendered. Defaults to `6`.
  final int length;

  /// The size of each individual pin box.
  ///
  /// Defaults to `Size(45, 45)`.
  final Size pinSize;

  /// The duration of the pin-box state-change animation.
  ///
  /// Controls how long the decoration transition takes when a pin's state
  /// changes (e.g., focused to filled, normal to error). Defaults to 300 ms.
  final Duration pinAnimationDuration;

  /// Decoration applied to pin boxes when the OTP is invalid.
  ///
  /// If null, the default decoration is used with a red error border derived
  /// from [ThemeData.colorScheme].
  final BoxDecoration? errorPinDecoration;

  /// Decoration applied to each pin box in its default (unfocused, empty)
  /// state.
  ///
  /// If null, a default decoration with a light grey border and 8 px rounded
  /// corners is used.
  final BoxDecoration? pinDecoration;

  /// Decoration applied to the currently focused pin box.
  ///
  /// If null, the default decoration is used with a primary-color border
  /// derived from [ThemeData.primaryColor].
  final BoxDecoration? focusedPinDecoration;

  /// Decoration applied to each pin box when the OTP is valid.
  ///
  /// If null, the default decoration is used with a green border.
  final BoxDecoration? validPinDecoration;

  /// Horizontal spacing between pin boxes in logical pixels.
  ///
  /// Defaults to `8`.
  final double spacing;

  /// A custom widget displayed as the blinking cursor inside the active
  /// pin box.
  ///
  /// If null, a default blinking `|` text cursor is shown, styled with
  /// [cursorTextStyle] or the primary color from the current theme.
  final Widget? cursor;

  /// Called when all digits have been entered to determine validity.
  ///
  /// Return `true` for a valid OTP (triggers the success animation) or
  /// `false` for an invalid OTP (triggers the shake animation and error
  /// decoration).
  ///
  /// For server-side validation, omit this callback and use
  /// [AnimatedOtpFieldState.validateOtp] instead.
  final bool Function(String otpValue)? isOtpValid;

  /// Text style applied to each digit displayed inside a pin box.
  ///
  /// If null, a default `TextStyle(fontSize: 20)` is used.
  final TextStyle? valueTextStyle;

  /// Text style for the default `|` cursor.
  ///
  /// Only effective when [cursor] is null. If null, the cursor uses
  /// [ThemeData.primaryColor].
  final TextStyle? cursorTextStyle;

  /// Whether to show a blinking cursor in the active pin box.
  ///
  /// Defaults to `true`.
  final bool showCursor;

  /// Whether to play a shake animation when the OTP is invalid.
  ///
  /// Defaults to `true`.
  final bool shakeOnInvalidOtp;

  /// Called when all [length] digits have been entered, regardless of the
  /// validation result.
  ///
  /// Use this to trigger server-side validation or other side effects.
  final void Function(String otpValue)? onCompleted;

  /// Called when the valid-OTP confirmation animation finishes on the last
  /// pin box.
  ///
  /// Use this to navigate away or show a success state after the animation
  /// completes.
  final void Function()? onValidationAnimationDone;

  /// Whether the field ignores all pointer events.
  ///
  /// When `true`, the field cannot be focused or edited. Defaults to `false`.
  final bool ignorePointer;

  /// Autofill hints sent to the platform keyboard.
  ///
  /// Defaults to `[AutofillHints.oneTimeCode]`.
  final Iterable<String>? autofillHints;

  /// The message shown below the pin boxes when validation fails.
  ///
  /// Only visible when [showValidationMsg] is `true`. Defaults to
  /// `'Invalid OTP'`.
  final String validationMsg;

  /// Whether to display [validationMsg] below the field on validation
  /// failure.
  ///
  /// Defaults to `true`.
  final bool showValidationMsg;

  /// Text style for the validation-failure message.
  ///
  /// If null, a default red 16 px semi-bold style is used.
  final TextStyle? validationMsgTextStyle;

  /// Extra vertical space added below the pin row.
  ///
  /// Increase this if you need room for a custom validation message or
  /// other widgets below the field. Defaults to `0`.
  final double extraFieldHeight;

  /// Provides a custom [Tween] for the validation-message slide animation.
  ///
  /// If null, a default directional slide-in tween is used (LTR: slide from
  /// left; RTL: slide from right).
  final Tween<Offset> Function()? customErrorMsgTween;

  @override
  State<AnimatedOtpField> createState() => AnimatedOtpFieldState();
}

/// The state for [AnimatedOtpField].
///
/// Exposes [validateOtp] for programmatic (server-side) validation.
/// Access via a [GlobalKey]:
///
/// ```dart
/// final key = GlobalKey<AnimatedOtpFieldState>();
/// // After receiving the server response:
/// key.currentState?.validateOtp(true);
/// ```
class AnimatedOtpFieldState extends State<AnimatedOtpField> implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  @override
  late final GlobalKey<EditableTextState> editableTextKey;

  EditableTextState? get _fieldState => editableTextKey.currentState;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enableTextSelection;

  @override
  void autofill(TextEditingValue newEditingValue) {
    final text = newEditingValue.text.length > widget.length ? newEditingValue.text.substring(0, widget.length) : newEditingValue.text;
    _fieldState?.updateEditingValue(TextEditingValue(text: text));
    _onChanged(text);
  }

  @override
  String get autofillId => _fieldState!.autofillId;

  @override
  TextInputConfiguration get textInputConfiguration {
    final autofillHints = widget.autofillHints?.toList(growable: false);
    final autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(uniqueIdentifier: autofillId, autofillHints: autofillHints, currentEditingValue: _controller.value)
        : AutofillConfiguration.disabled;

    return _fieldState!.textInputConfiguration.copyWith(autofillConfiguration: autofillConfiguration);
  }

  late final TextEditingController _controller;
  late final FocusNode _fieldFocusNode;
  late final Widget _editableText;
  late final Widget _pins;
  late final ValueNotifier<int> _currentFocus;
  late final ValueNotifier<String> _currentValue;
  late final ValueNotifier<bool> _showInvalidOtpDecoration;
  late final List<ValueNotifier<bool>> _validAnimationFlags;
  late final ShakeAnimationController _shakeAnimationController;
  late final ValueNotifier<String> _validationMsg;
  late final TextStyle _errorTextStyle;

  void _onTap() {
    _fieldState?.requestKeyboard();
    _currentFocus.value = _currentValue.value.length;
  }

  void _hideErrorMsg() {
    _showInvalidOtpDecoration.value = false;
    _validationMsg.value = '';
  }

  void _focusNodeListener() {
    if (_fieldFocusNode.hasFocus) {
      _hideErrorMsg();

      if (_currentValue.value.length == widget.length) {
        _currentFocus.value = widget.length - 1;
      } else {
        _currentFocus.value = max(_currentValue.value.length, 0);
      }
    } else {
      _currentFocus.value = -1;
    }
  }

  void _onChanged(String value) {
    _hideErrorMsg();

    if (value.length > widget.length) {
      final lastChar = value.substring(value.length - 1);
      final base = _currentValue.value.substring(0, widget.length - 1);
      _currentValue.value = base + lastChar;
      _fieldState?.updateEditingValue(TextEditingValue(text: _currentValue.value));
      _onComplete(_currentValue.value);
      return;
    }

    _currentValue.value = value.trim();

    if (_currentValue.value.length < widget.length) {
      _currentFocus.value = _currentValue.value.length;
    }

    if (value.length == widget.length) {
      _onComplete(value);
    }
  }

  void _onComplete(String value) {
    widget.onCompleted?.call(value);
    _fieldFocusNode.unfocus();

    if (widget.isOtpValid != null) {
      _validateOtp(value, widget.isOtpValid!(value));
    }
  }

  void _validateOtp(String value, bool isValid) {
    if (isValid) {
      _playValidAnimation();
    } else {
      _playInvalidAnimation();
    }
  }

  void _playValidAnimation() {
    Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      for (int i = 0; i < widget.length; i++) {
        Timer(Duration(milliseconds: 85 + (i * 100)), () {
          if (mounted) _validAnimationFlags[i].value = true;
        });
      }
    });
  }

  void _playInvalidAnimation() {
    if (widget.shakeOnInvalidOtp) {
      _shakeAnimationController.start(shakeCount: 1);
    }
    _showInvalidOtpDecoration.value = true;
    _validationMsg.value = widget.validationMsg;
    Gaimon.error();
  }

  String _pinValue(int index) {
    if (index >= _currentValue.value.length) return '';
    return _currentValue.value.substring(index, index + 1);
  }

  /// Triggers validation UI programmatically.
  ///
  /// Call this with the server response to show the appropriate animation:
  /// - `true` plays the sequential success animation on each pin.
  /// - `false` plays the shake and shows the error decoration.
  ///
  /// ```dart
  /// final otpKey = GlobalKey<AnimatedOtpFieldState>();
  /// // After server response:
  /// otpKey.currentState?.validateOtp(isValid);
  /// ```
  void validateOtp(bool value) {
    _validateOtp(_currentValue.value, value);
  }

  @override
  void initState() {
    super.initState();
    _currentFocus = ValueNotifier<int>(-1);
    _validationMsg = ValueNotifier<String>('');
    _currentValue = ValueNotifier<String>('');
    editableTextKey = GlobalKey<EditableTextState>();
    _fieldFocusNode = widget.focusNode ?? FocusNode();
    _showInvalidOtpDecoration = ValueNotifier<bool>(false);
    _shakeAnimationController = ShakeAnimationController();
    _controller = widget.controller ?? TextEditingController();
    _validAnimationFlags = List.generate(widget.length, (_) => ValueNotifier<bool>(false));
    _errorTextStyle = const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600);
    _editableText = Offstage(
      offstage: true,
      child: EditableText(
        maxLines: 1,
        expands: false,
        showCursor: false,
        autocorrect: false,
        key: editableTextKey,
        autofillClient: this,
        onChanged: _onChanged,
        controller: _controller,
        focusNode: _fieldFocusNode,
        showSelectionHandles: false,
        textAlign: TextAlign.center,
        clipBehavior: Clip.hardEdge,
        rendererIgnoresPointer: true,
        cursorColor: Colors.transparent,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.number,
        selectionColor: Colors.transparent,
        selectionWidthStyle: BoxWidthStyle.tight,
        backgroundCursorColor: Colors.transparent,
        selectionHeightStyle: BoxHeightStyle.tight,
        style: const TextStyle(fontSize: 1, height: 0, color: Colors.transparent),
      ),
    );
    _pins = ShakeAnimationWidget(
      shakeRange: .1,
      isForward: false,
      shakeAnimationController: _shakeAnimationController,
      shakeAnimationType: ShakeAnimationType.LeftRightShake,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: widget.spacing,
        children: List.generate(
          widget.length,
          (index) => ListenableBuilder(
            listenable: Listenable.merge([_currentFocus, _currentValue, _showInvalidOtpDecoration, _validAnimationFlags[index]]),
            builder: (_, __) {
              return _PinField(
                value: _pinValue(index),
                animatedOtpField: widget,
                isLastPin: index + 1 == widget.length,
                isFocus: _currentFocus.value == index,
                showInvalidOtp: _showInvalidOtpDecoration.value,
                showValidOtp: _validAnimationFlags[index].value,
                onValidationAnimationDone: () {
                  widget.onValidationAnimationDone?.call();
                },
              );
            },
          ),
        ),
      ),
    );
    _fieldFocusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _currentValue.dispose();
    _currentFocus.dispose();
    _validationMsg.dispose();
    _showInvalidOtpDecoration.dispose();
    _fieldFocusNode.removeListener(_focusNodeListener);
    for (final flag in _validAnimationFlags) {
      flag.dispose();
    }
    _validAnimationFlags.clear();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.ignorePointer,
      child: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: widget.pinSize.height + 50 + widget.extraFieldHeight,
          width: (widget.pinSize.width * widget.length) + (widget.spacing * (widget.length - 1)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _editableText,
              Positioned.fill(
                child: Directionality(textDirection: TextDirection.ltr, child: _pins),
              ),
              if (widget.showValidationMsg)
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _validationMsg,
                      builder: (_, msg, __) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) => _transitionBuilder(child, animation, context),
                        child: msg.isEmpty ? const SizedBox.shrink() : Text(msg, style: widget.validationMsgTextStyle ?? _errorTextStyle),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation, BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final bool isLtr = textDirection == .ltr;
    final Animation<Offset> offsetAnimation = animation.drive(
      (widget.customErrorMsgTween?.call() ??
              (isLtr ? Tween<Offset>(begin: const .new(-1, 0), end: .zero) : Tween<Offset>(begin: const .new(1, 0), end: .zero)))
          .chain(CurveTween(curve: Curves.easeOut)),
    );
    return SlideTransition(position: offsetAnimation, child: child);
  }
}
