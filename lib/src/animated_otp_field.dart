import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gaimon/gaimon.dart';
import 'package:flutter/material.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
part 'widgets/pin_field.dart';
part 'widgets/pin_cursor.dart';

class AnimatedOtpField extends StatefulWidget {
  const AnimatedOtpField({
    Key? key,
    this.cursor,
    this.len = 6,
    this.isOtpValid,
    this.onCompleted,
    this.spacing = 8,
    this.pinDecoration,
    this.fieldFocusNod,
    this.textController,
    this.valueTextStyle,
    this.cursorTextStyle,
    this.showCursor = true,
    this.optValidationValue,
    this.errorPinDecoration,
    this.validPinDecoration,
    this.extraFieldHeight = 0,
    this.focusedPinDecoration,
    this.ignorePointer = false,
    this.validationMsgTextStyle,
    this.validationAnimationDone,
    this.shakeOnInValidOtp = true,
    this.showValidationMsg = true,
    this.enableTextSelection = true,
    this.pinSize = const Size(45, 45),
    this.validationMsg = "InValid OTP",
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.pinAnimationDuration = const Duration(milliseconds: 300),
  })  : assert(isOtpValid != null || optValidationValue != null, "How You Gonna Check If The Otp is Valid ! :) "),
        super(key: key);

  /// If true , user can select Text
  final bool enableTextSelection;

  /// Controls the text being edited. If null, a controller will be created internally.
  ///
  /// If you provide your own [TextEditingController], you are responsible for disposing it.
  /// If left null, the widget creates and disposes its own controller automatically.
  ///
  /// Example (when providing your own controller):
  /// ```dart
  /// late final TextEditingController _controller;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _controller = TextEditingController();
  /// }
  ///
  /// @override
  /// void dispose() {
  ///   _controller.dispose();
  ///   super.dispose();
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return AnimatedOtpField(textController: _controller);
  /// }
  /// ```
  final TextEditingController? textController;

  /// The focus node for the OTP field. If null, a [FocusNode] will be created internally.
  ///
  /// If you provide your own [FocusNode], you are responsible for disposing it.
  /// If left null, the widget creates and disposes its own focus node automatically.
  ///
  /// Example (when providing your own focus node):
  /// ```dart
  /// late final FocusNode _focusNode;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   _focusNode = FocusNode();
  /// }
  ///
  /// @override
  /// void dispose() {
  ///   _focusNode.dispose();
  ///   super.dispose();
  /// }
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return AnimatedOtpField(fieldFocusNod: _focusNode);
  /// }
  /// ```
  final FocusNode? fieldFocusNod;

  /// The length of the OTP code to be entered. Determines how many digits or characters the field will accept.
  final int len;

  /// The size of each individual OTP pin box.
  /// This determines the width and height of each input field for the OTP digits.
  final Size pinSize;

  /// The duration of the animation for the OTP pin fields.
  /// Controls how long the pin field animation takes when the value changes or animates.
  final Duration pinAnimationDuration;

  /// The decoration to use for each OTP pin field when the input is invalid.
  /// If null, a default error decoration is applied (red border).
  final Decoration? errorPinDecoration;

  /// The decoration to use for each OTP pin field.
  /// If null, a default decoration is applied.
  final Decoration? pinDecoration;

  /// The decoration to use for each OTP pin field when it is focused.
  /// If null, a default focused decoration is applied (primary color border).
  final Decoration? focusedPinDecoration;

  /// The decoration to use for each OTP pin field when the entered OTP is valid.
  /// If null, a default valid decoration is applied (green border with slightly thicker border).
  final Decoration? validPinDecoration;

  /// The horizontal space between each OTP pin field.
  /// This controls the gap between the individual input boxes.
  final double spacing;

  /// The widget to use as the cursor within each OTP pin field.
  /// If provided, this widget will be displayed as the cursor. If null, a default text cursor '|' is used.
  final Widget? cursor;

  /// A callback function that is called when the OTP field is filled to its full length.
  /// The function receives the complete OTP value as a string.
  /// Use this to validate the entered OTP when the validation occurs on the client side.
  /// This callback is only triggered if [optValidationValue] is null.
  final bool Function(String otpValue)? isOtpValid;

  /// The [TextStyle] to apply to the value entered in each pin field.
  /// If null, a default style is used.
  final TextStyle? valueTextStyle;

  /// The [TextStyle] to apply to the default text cursor ('|').
  /// This property is only effective when [cursor] is null.
  final TextStyle? cursorTextStyle;

  /// Whether to show the cursor in the active pin field.
  /// If true, a blinking cursor will be displayed in the currently focused pin box.
  final bool showCursor;

  /// Use this value when the validation happens on the server side or the validation happens in state management.
  /// Set this to true or false based on your validation result to trigger valid/invalid UI.
  /// This value overrides the result of [isOtpValid] if both are provided.
  final bool? optValidationValue;

  /// Whether the OTP field should shake when the entered OTP is invalid.
  /// This property is only effective when the OTP is validated and found to be invalid.
  final bool shakeOnInValidOtp;

  /// A callback function that is called when the OTP field is successfully completed (filled to [len]).
  /// This is called regardless of the validation result.
  /// The function receives the complete OTP value as a string.
  final void Function(String otpValue)? onCompleted;

  /// A callback function that is called when the valid OTP animation finishes.
  /// This can be used to trigger further actions after a successful validation animation.
  final void Function()? validationAnimationDone;

  /// Whether the field should ignore user input (pointer events).
  /// If true, the field cannot be focused or edited.
  final bool ignorePointer;

  /// Hints for the auto-fill feature of the device keyboard.
  /// Defaults to [AutofillHints.oneTimeCode] for OTP fields.
  final Iterable<String>? autofillHints;

  /// The message to display below the OTP field when validation fails.
  /// This message is only shown if [showValidationMsg] is true and the OTP is invalid.
  final String validationMsg;

  /// Whether to display the validation message below the OTP field when validation fails.
  final bool showValidationMsg;

  /// The [TextStyle] to apply to the validation message.
  /// If null, a default text style is used.
  final TextStyle? validationMsgTextStyle;

  final double extraFieldHeight;

  @override
  State<AnimatedOtpField> createState() => _AnimatedOtpFieldState();
}

class _AnimatedOtpFieldState extends State<AnimatedOtpField> implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  @override
  late final GlobalKey<EditableTextState> editableTextKey;
  EditableTextState? get fieldState => editableTextKey.currentState;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enableTextSelection;

  @override
  void autofill(TextEditingValue newEditingValue) {
    // TODO: implement autofill
  }

  @override
  String get autofillId => fieldState!.autofillId;

  @override
  TextInputConfiguration get textInputConfiguration {
    final List<String>? autofillHints = widget.autofillHints?.toList(growable: false);
    final AutofillConfiguration autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: _controller.value,
          )
        : AutofillConfiguration.disabled;

    return fieldState!.textInputConfiguration.copyWith(autofillConfiguration: autofillConfiguration);
  }

  /// Text Controller
  late final TextEditingController _controller;

  // field focus node
  late final FocusNode _fieldFocusNode;

  late final Widget editableText;

  // pin fields
  late final Widget pins;

  late final ValueNotifier<bool> isValid;

  late final ValueNotifier<int> _currentFocus;

  late final ValueNotifier<String> _currentValue;

  late final ValueNotifier<bool> _showInValidOtpDecoration;

  late final List<ValueNotifier<bool>> showValidOtpAnimation;

  late final ShakeAnimationController _shakeAnimationController;

  late final ValueNotifier<String> validationMsg;

  late final TextStyle errorTextStyle;

  /// Handles the tap gesture on the OTP field to request keyboard focus.
  /// It also sets the focus to the appropriate pin based on the current value length.
  void _onTap() {
    fieldState?.requestKeyboard();
    _currentFocus.value = _currentValue.value.length;
  }

  /// Listens to changes in the focus node to update the currently focused pin.
  /// When the field gains focus, it highlights the pin where the next character will be entered.
  /// When the field loses focus, it removes the focus highlight from all pins.
  void _focusNodeListner() {
    if (_fieldFocusNode.hasFocus) {
      /// remove error decoration on Error
      _showInValidOtpDecoration.value = false;
      validationMsg.value = "";

      /// to focus the last pin if the value len is equal to [widget.len]
      if (_currentValue.value.length == widget.len) {
        _currentFocus.value = widget.len - 1;
      } else {
        /// use max to handle when the field is empty
        _currentFocus.value = max(_currentValue.value.length, 0);
      }
    } else {
      _currentFocus.value = -1;
    }
  }

  /// Called when the text in the EditableText changes.
  /// Updates the [_currentValue] and the focused pin based on the new value.
  /// If the OTP reaches the specified length, it unfocused the field and calls the [isOtpValid] callback.
  void _onChanged(String value) {
    if (value.length > widget.len) {
      final int lastCharIndex = _currentValue.value.length - 1;
      _currentValue.value = _currentValue.value.replaceRange(lastCharIndex, lastCharIndex + 1, value.split('').last);
      fieldState?.updateEditingValue(TextEditingValue(text: _currentValue.value));
      _onComplete(value);
      return;
    }

    _currentValue.value = value.trim();

    /// for focusing the next pin
    if (_currentValue.value.length < widget.len) {
      _currentFocus.value = _currentValue.value.length;
    }

    /// when otp complete
    if (value.length == widget.len) {
      _onComplete(value);
    }
  }

  /// Called when the OTP field is filled to its full length ([len]).
  /// Triggers the [onCompleted] callback and the validation process.
  void _onComplete(String value) {
    if (widget.onCompleted != null) widget.onCompleted!(value);
    _fieldFocusNode.unfocus();

    // validate from the function or external value
    if (widget.isOtpValid != null && widget.optValidationValue == null) {
      _validateTheOpt(value, widget.isOtpValid!(value));
    }
  }

  /// Validates the entered OTP based on the provided boolean value.
  /// Triggers either the valid or invalid OTP animation and effects.
  void _validateTheOpt(String value, bool validationValue) {
    isValid.value = validationValue;
    if (isValid.value) {
      _otpIsValid();
    } else {
      _otpIsInValid();
    }
  }

  /// Triggers the valid OTP animation for each pin field sequentially.
  void _otpIsValid() {
    Timer(
      Duration(milliseconds: 80),
      () {
        for (int i = 0; i < widget.len; i++) {
          Timer(Duration(milliseconds: 85 + (i * 100)), () => showValidOtpAnimation[i].value = true);
        }
      },
    );
  }

  /// Triggers the invalid OTP animation (shake) and error decoration.
  void _otpIsInValid() {
    if (widget.shakeOnInValidOtp) _shakeAnimationController.start(shakeCount: 1);
    _showInValidOtpDecoration.value = true;
    Timer(Duration(milliseconds: 1200), () => _showInValidOtpDecoration.value = false);
    Gaimon.error(); // Assuming Gaimon is imported and available
    validationMsg.value = widget.validationMsg;
  }

  /// Returns the character at the specified index in the current OTP value.
  /// Returns an empty string if the index is out of bounds.
  String _pinValue(int index) {
    if (index >= _currentValue.value.length) {
      return "";
    }
    return _currentValue.value.split('')[index];
  }

  @override
  void didUpdateWidget(covariant AnimatedOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentValue.value.length == widget.len && widget.isOtpValid == null && widget.optValidationValue != null) {
      _validateTheOpt(_currentValue.value, widget.optValidationValue!);
    }
  }

  @override
  void initState() {
    super.initState();
    isValid = ValueNotifier<bool>(true);
    _currentFocus = ValueNotifier<int>(-1);
    validationMsg = ValueNotifier<String>("");
    _currentValue = ValueNotifier<String>("");
    editableTextKey = GlobalKey<EditableTextState>();
    _fieldFocusNode = widget.fieldFocusNod ?? FocusNode();
    _showInValidOtpDecoration = ValueNotifier<bool>(false);
    _shakeAnimationController = ShakeAnimationController();
    _controller = widget.textController ?? TextEditingController();
    showValidOtpAnimation = List.generate(widget.len, (_) => ValueNotifier<bool>(false));
    errorTextStyle = TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600);
    editableText = Offstage(
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
        style: const TextStyle(fontSize: 0, height: 0, color: Colors.transparent),
      ),
    );
    pins = ShakeAnimationWidget(
      shakeRange: .1,
      isForward: false,
      shakeAnimationController: _shakeAnimationController,
      shakeAnimationType: ShakeAnimationType.LeftRightShake,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: widget.spacing,
        children: List.generate(
          widget.len,
          (index) => ListenableBuilder(
            listenable: Listenable.merge([_currentFocus, _currentValue, _showInValidOtpDecoration, showValidOtpAnimation[index]]),
            builder: (_, __) {
              return _PinField(
                value: _pinValue(index),
                animatedOtpField: widget,
                isLastPin: index + 1 == widget.len,
                isFocus: _currentFocus.value == index,
                showInValidOTP: _showInValidOtpDecoration.value,
                showValidOtp: showValidOtpAnimation[index].value,
                shakeAnimationController: _shakeAnimationController,
                validationAnimationDone: () {
                  if (widget.validationAnimationDone != null) widget.validationAnimationDone!();
                },
              );
            },
          ),
        ),
      ),
    );
    _fieldFocusNode.addListener(_focusNodeListner);
  }

  @override
  void dispose() {
    _currentValue.dispose();
    _currentFocus.dispose();
    validationMsg.dispose();
    _showInValidOtpDecoration.dispose();
    _fieldFocusNode.removeListener(_focusNodeListner);
    for (ValueNotifier<bool> e in showValidOtpAnimation) {
      e.dispose();
    }
    showValidOtpAnimation.clear();
    if (widget.textController == null) _controller.dispose();
    if (widget.fieldFocusNod == null) _fieldFocusNode.dispose();
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
          height: widget.pinSize.height + (50 + widget.extraFieldHeight),
          width: (widget.pinSize.width * widget.len) + (widget.spacing * (widget.len - 1)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              editableText,
              Positioned.fill(child: pins),
              if (widget.showValidationMsg)
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ValueListenableBuilder<String>(
                      valueListenable: validationMsg,
                      builder: (_, msg, __) => AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        transitionBuilder: _transitionBuilder,
                        child: msg.isEmpty ? SizedBox.shrink() : Text(msg, style: widget.validationMsgTextStyle ?? errorTextStyle),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    // Convert double animation to Offset animation
    final Animation<Offset> offsetAnimation = animation.drive(
      Tween<Offset>(
        begin: Offset(-1, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut)),
    );
    return SlideTransition(position: offsetAnimation, child: child);
  }
}
