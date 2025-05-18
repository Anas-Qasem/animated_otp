part of '../animated_otp_field.dart';

class _PinCursor extends StatefulWidget {
  const _PinCursor({required this.cursor,required this.cursorTextStyle});
  final TextStyle? cursorTextStyle;
  final Widget? cursor;
  @override
  State<_PinCursor> createState() => _PinCursorState();
}

class _PinCursorState extends State<_PinCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startCursorAnimation();
  }

  void _startCursorAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat(reverse: true);
      }
    });
    _animationController.forward();
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
            style: widget.cursorTextStyle ?? TextStyle(color: Theme.of(context).primaryColor),
          ),
    );
  }
}
