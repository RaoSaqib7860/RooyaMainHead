import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotateWidget extends StatefulWidget {
  final Widget? child;
  const RotateWidget({Key? key, this.child}) : super(key: key);

  @override
  _RotateWidgetState createState() => _RotateWidgetState();
}

class _RotateWidgetState extends State<RotateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 9))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
