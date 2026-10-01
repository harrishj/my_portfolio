import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final double delay;

  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.offset = const Offset(0, 30),
    this.delay = 0,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_isVisible && info.visibleFraction > 0.15) {
      _isVisible = true;
      if (widget.delay <= 0) {
        if (mounted) _controller.forward();
      } else {
        _timer = Timer(
          Duration(milliseconds: (widget.delay * 1000).toInt()),
          () {
            if (mounted) _controller.forward();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('scroll-reveal-${widget.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _slide.value,
            child: Opacity(
              opacity: _opacity.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
