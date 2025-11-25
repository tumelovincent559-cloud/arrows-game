import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Overlay widget displaying particle effects celebration animation
class CelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CelebrationOverlay({super.key, required this.onComplete});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.celebrationAnimationDuration,
    );

    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Particle(
          x: 50.w,
          y: 50.h,
          vx: (_random.nextDouble() - 0.5) * 10,
          vy: (_random.nextDouble() - 0.5) * 10,
          color: _getRandomColor(),
          size: _random.nextDouble() * 8 + 4,
        ),
      );
    }

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    });
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryLight,
      AppTheme.secondaryLight,
      AppTheme.pathActiveLight,
      AppTheme.successLight,
      AppTheme.warningLight,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size(100.w, 100.h),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x + particle.vx * progress * 50;
      final y =
          particle.y +
          particle.vy * progress * 50 +
          (progress * progress * 100);

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
