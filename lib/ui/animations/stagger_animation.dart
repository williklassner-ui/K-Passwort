import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredList extends StatelessWidget {
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 30),
    this.initialDelay = Duration.zero,
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration initialDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          children[i]
              .animate(delay: initialDelay + staggerDelay * i)
              .fadeIn(duration: 250.ms, curve: Curves.easeOut)
              .slideY(begin: 0.06, end: 0, duration: 250.ms, curve: Curves.easeOut),
      ],
    );
  }
}

extension AnimateWidget on Widget {
  Widget staggeredEntrance(int index, {Duration stagger = const Duration(milliseconds: 30)}) {
    return animate(delay: stagger * index)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}
