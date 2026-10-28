import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Llama que hace un pulso breve cuando la racha aumenta.
class AnimatedFlame extends StatefulWidget {
  const AnimatedFlame({super.key, required this.streak, this.size = 64});
  final int streak;
  final double size;
  @override
  State<AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<AnimatedFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40),
    TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60),
  ]).animate(_c);

  @override
  void didUpdateWidget(AnimatedFlame old) {
    super.didUpdateWidget(old);
    if (widget.streak > old.streak) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: Icon(Icons.local_fire_department,
            size: widget.size,
            color: widget.streak > 0 ? AppColors.orange : AppColors.lightGreen),
      );
}
