import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Widget para crear elementos flotantes animados estilo Discord
/// Simula objetos 3D como pesas, mancuernas, etc.
class FloatingElement extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  final double delay;
  final bool rotates;

  const FloatingElement({
    super.key,
    required this.child,
    this.amplitude = 10.0,
    this.duration = const Duration(seconds: 3),
    this.delay = 0.0,
    this.rotates = false,
  });

  @override
  State<FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<FloatingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _floatAnimation = Tween<double>(
      begin: -widget.amplitude,
      end: widget.amplitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(
      Duration(milliseconds: (widget.delay * 1000).toInt()),
      () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      },
    );
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
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: widget.rotates
              ? Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: widget.child,
                )
              : widget.child,
        );
      },
    );
  }
}

/// Mancuerna 3D estilizada con colores del gym
class Dumbbell3D extends StatelessWidget {
  final double size;
  final Color color;

  const Dumbbell3D({
    super.key,
    this.size = 80,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Barra central
          Container(
            width: size * 1.2,
            height: size * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[400]!,
                  Colors.grey[600]!,
                  Colors.grey[800]!,
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.075),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // Peso izquierdo
          Positioned(
            left: 0,
            child: _buildWeight(size),
          ),
          // Peso derecho
          Positioned(
            right: 0,
            child: _buildWeight(size),
          ),
        ],
      ),
    );
  }

  Widget _buildWeight(double size) {
    return Container(
      width: size * 0.5,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.35,
          height: size * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.08),
          ),
        ),
      ),
    );
  }
}

/// Disco de pesa estilizado
class WeightPlate3D extends StatelessWidget {
  final double size;
  final Color color;
  final String? label;

  const WeightPlate3D({
    super.key,
    this.size = 80,
    this.color = AppColors.primary,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 5,
                spreadRadius: -2,
              ),
            ],
          ),
          child: label != null
              ? Center(
                  child: Text(
                    label!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Kettlebell estilizado
class Kettlebell3D extends StatelessWidget {
  final double size;
  final Color color;

  const Kettlebell3D({
    super.key,
    this.size = 80,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Asa
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.6,
              height: size * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.3),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: size * 0.08,
                ),
              ),
            ),
          ),
          // Cuerpo
          Positioned(
            bottom: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Partículas brillantes animadas
class GlowParticles extends StatefulWidget {
  final int particleCount;
  final Color color;

  const GlowParticles({
    super.key,
    this.particleCount = 20,
    this.color = AppColors.primary,
  });

  @override
  State<GlowParticles> createState() => _GlowParticlesState();
}

class _GlowParticlesState extends State<GlowParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ),
    );
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
          painter: _ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y - progress * particle.speed) % 1.0;
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
