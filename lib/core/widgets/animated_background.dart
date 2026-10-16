import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Orqa fondagi gradient (Bosishga xalaqit bermasligi uchun IgnorePointer ichida)
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E3A8A),
                      Color.lerp(
                        const Color(0xFF1E3A8A),
                        const Color(0xFF6366F1),
                        (math.sin(_controller.value * 2 * math.pi) + 1) / 2,
                      )!,
                      const Color(0xFF3B82F6),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // 2. Fon ustidagi naqsh (Pattern) - bu ham bosishga xalaqit bermasligi kerak
        IgnorePointer(
          child: Opacity(
            opacity: 0.05,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
        ),
        // 3. Asosiy kontent - hamma tugmalar shu yerda bo'ladi
        widget.child,
      ],
    );
  }
}
