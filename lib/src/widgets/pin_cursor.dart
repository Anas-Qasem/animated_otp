part of '../animated_otp_field.dart';

/// A blinking cursor widget displayed inside an empty, focused pin box.
///
/// Fades in and out continuously using a [FadeTransition] driven by an
/// [AnimationController]. If [cursor] is null, a default `|` text is shown.
class _PinCursor extends StatefulWidget {
  const _PinCursor({
    required this.cursor,
    required this.cursorTextStyle,
  });

  /// Custom cursor widget, or `null` to use the default `|` text.
  final Widget? cursor;

  /// Style applied to the default `|` text cursor.
  final TextStyle? cursorTextStyle;

  @override
  State<_PinCursor> createState() => _PinCursorState();
}

class _PinCursorState extends State<_PinCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: widget.cursor ??
          Text(
            '|',
            style: widget.cursorTextStyle ??
                TextStyle(color: Theme.of(context).primaryColor),
          ),
    );
  }
}
