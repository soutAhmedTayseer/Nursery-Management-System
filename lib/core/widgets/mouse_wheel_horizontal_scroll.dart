import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Horizontal [SingleChildScrollView] that also scrolls on plain vertical
/// mouse-wheel input, so desktop users don't need to hold Shift.
class MouseWheelHorizontalScroll extends StatefulWidget {
  const MouseWheelHorizontalScroll({super.key, required this.child});

  final Widget child;

  @override
  State<MouseWheelHorizontalScroll> createState() => _MouseWheelHorizontalScrollState();
}

class _MouseWheelHorizontalScrollState extends State<MouseWheelHorizontalScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final delta = event.scrollDelta.dy != 0 ? event.scrollDelta.dy : event.scrollDelta.dx;
    final target = (_controller.offset + delta).clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );
    _controller.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
