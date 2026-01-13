import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/floating_element.dart';

/// Landing Page rediseñada estilo Discord
/// Con elementos 3D flotantes y secciones alternadas
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _heroAnimationController;
  late AnimationController _floatController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });

    _heroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Fondo con partículas
          const Positioned.fill(
            child: _AnimatedBackground(),
          ),
          // Contenido principal
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: _HeroSection(
                  animationController: _heroAnimationController,
                  floatController: _floatController,
                  scrollOffset: _scrollOffset,
                ),
              ),
              // Sección de características alternadas
              SliverToBoxAdapter(child: _buildFeatureSections()),
              // Galería
              SliverToBoxAdapter(child: _buildGallerySection()),
              // Footer
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSections() {
    return Column(
      children: [
        // Separador con gradiente
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Feature 1: Rutinas personalizadas
        _FeatureBlock(
          title: 'Rutinas Diseñadas Para Ti',
          description:
              'Planes de entrenamiento específicos para hombres y mujeres. '
              'Desde principiantes hasta avanzados, cada rutina está optimizada para maximizar tus resultados.',
          bulletPoints: const [
            'Rutinas para diferentes niveles',
            'Enfocadas en hipertrofia y fuerza',
            'Videos demostrativos de cada ejercicio',
          ],
          illustration: _buildRoutineIllustration(),
          imageOnLeft: true,
        ),
        // Feature 2: Máquinas y ejercicios
        _FeatureBlock(
          title: '35+ Ejercicios con Guía',
          description:
              'Biblioteca completa de máquinas del gimnasio con instrucciones detalladas. '
              'Aprende la técnica correcta y maximiza cada repetición.',
          bulletPoints: const [
            'Guías paso a paso',
            'Músculos trabajados en cada ejercicio',
            'Tips de seguridad y forma',
          ],
          illustration: _buildExerciseIllustration(),
          imageOnLeft: false,
          accentColor: AppColors.info,
        ),
        // Feature 3: Seguimiento de progreso
        _FeatureBlock(
          title: 'Monitorea Tu Transformación',
          description:
              'Registra tu asistencia, sigue tu progreso y mantente motivado. '
              'Visualiza tu evolución semana a semana.',
          bulletPoints: const [
            'Calendario de entrenamientos',
            'Historial de asistencias',
            'Estadísticas de progreso',
          ],
          illustration: _buildProgressIllustration(),
          imageOnLeft: true,
          accentColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildRoutineIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mancuerna flotante principal
        FloatingElement(
          amplitude: 15,
          duration: const Duration(seconds: 3),
          rotates: true,
          child: const Dumbbell3D(size: 60, color: AppColors.primary),
        ),
        // Discos flotantes alrededor
        Positioned(
          top: 20,
          right: 40,
          child: FloatingElement(
            amplitude: 10,
            duration: const Duration(milliseconds: 2500),
            delay: 0.5,
            child: const WeightPlate3D(size: 50, color: AppColors.primaryLight),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 30,
          child: FloatingElement(
            amplitude: 12,
            duration: const Duration(milliseconds: 2800),
            delay: 0.3,
            child: const WeightPlate3D(size: 40, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        FloatingElement(
          amplitude: 12,
          duration: const Duration(seconds: 3),
          child: const Kettlebell3D(size: 70, color: AppColors.info),
        ),
        Positioned(
          top: 30,
          left: 40,
          child: FloatingElement(
            amplitude: 8,
            duration: const Duration(milliseconds: 2600),
            delay: 0.4,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                color: AppColors.info,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gráfica estilizada
        FloatingElement(
          amplitude: 10,
          duration: const Duration(seconds: 3),
          child: Container(
            width: 150,
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: CustomPaint(
              painter: _ChartPainter(color: AppColors.success),
              size: const Size(120, 70),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 30,
          child: FloatingElement(
            amplitude: 8,
            duration: const Duration(milliseconds: 2700),
            delay: 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '+15%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : AppConstants.spacingXL,
                vertical: isMobile ? 32 : AppConstants.spacingXL,
              ),
              child: Column(
                children: [
                  Text(
                    'NUESTRAS INSTALACIONES',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: isMobile ? 2.5 : 3,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : AppConstants.spacingS),
                  Text(
                    'Conoce Mexican Bulking Gym',
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _ImageCarousel(isMobile: isMobile),
            SizedBox(height: isMobile ? 40 : AppConstants.spacingXL),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 60,
            vertical: isMobile ? 40 : 50,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(
              top: BorderSide(
                color: AppColors.glassBorder.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Column(
            children: [
              // Contenido principal - Horizontal en PC, Vertical en móvil
              if (isMobile) ...[
                // MÓVIL: Layout vertical original
                _LocationCard(isMobile: true),
                const SizedBox(height: 32),
                // Redes sociales
                Text(
                  'Síguenos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: Icons.camera_alt,
                      gradient: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
                      url: AppConstants.instagramUrl,
                      isMobile: true,
                    ),
                    const SizedBox(width: 20),
                    _SocialButton(
                      icon: Icons.facebook,
                      gradient: const [Color(0xFF1877F2), Color(0xFF1877F2)],
                      url: AppConstants.facebookUrl,
                      isMobile: true,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Links legales
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.go('${AppRoutes.privacy}?from=landing'),
                      child: Text(
                        'Privacidad',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 0.5))),
                    TextButton(
                      onPressed: () => context.go('${AppRoutes.terms}?from=landing'),
                      child: Text(
                        'Términos',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Developer credit móvil
                _buildDeveloperCredit(isMobile: true),
                const SizedBox(height: 32),
              ] else ...[
                // PC: Layout horizontal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna 1: Ubicación
                    Expanded(
                      flex: 3,
                      child: _buildLocationSection(),
                    ),
                    const SizedBox(width: 40),
                    // Columna 2: Redes Sociales
                    Expanded(
                      flex: 2,
                      child: _buildSocialSection(context),
                    ),
                    const SizedBox(width: 40),
                    // Columna 3: Legal
                    Expanded(
                      flex: 2,
                      child: _buildLegalSection(context),
                    ),
                    const SizedBox(width: 40),
                    // Columna 4: Developer
                    Expanded(
                      flex: 3,
                      child: _buildDeveloperSection(),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
              // Separador
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 24 : 50),
              // Título grande MEXICAN BULKING - Estilo Discord
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calcular tamaño de fuente basado en el ancho disponible
                  final maxWidth = constraints.maxWidth;
                  final fontSize = isMobile ? maxWidth * 0.18 : maxWidth * 0.14;

                  return Column(
                    children: [
                      Text(
                        'MEXICAN',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryDark.withValues(alpha: 0.35),
                          letterSpacing: isMobile ? 4 : 12,
                          height: 0.9,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                            AppColors.primary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'BULKING',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: isMobile ? 6 : 16,
                            height: 0.85,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: isMobile ? 16 : 24),
              // Copyright
              Text(
                '© 2025 Mexican Bulking. Todos los derechos reservados.',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Sección de ubicación para PC
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UBICACIÓN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mexican Bulking Gym',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calz. Aragón 14, Lindavista\n07300 Ciudad de México, CDMX',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://maps.app.goo.gl/KspxQHHMhfrkfoSn6');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ver en Google Maps',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Sección de redes sociales para PC
  Widget _buildSocialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SÍGUENOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SocialButton(
              icon: Icons.camera_alt,
              gradient: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
              url: AppConstants.instagramUrl,
              isMobile: false,
            ),
            const SizedBox(width: 16),
            _SocialButton(
              icon: Icons.facebook,
              gradient: const [Color(0xFF1877F2), Color(0xFF1877F2)],
              url: AppConstants.facebookUrl,
              isMobile: false,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '@mexicanbulking',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  // Sección legal para PC
  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEGAL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        _buildLegalLink(
          'Política de Privacidad',
          () => context.go('${AppRoutes.privacy}?from=landing'),
        ),
        const SizedBox(height: 12),
        _buildLegalLink(
          'Términos y Condiciones',
          () => context.go('${AppRoutes.terms}?from=landing'),
        ),
      ],
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryDark,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // Sección developer para PC
  Widget _buildDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESARROLLADO POR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        _buildDeveloperCredit(isMobile: false),
      ],
    );
  }

  // Developer credit widget reutilizable
  Widget _buildDeveloperCredit({required bool isMobile}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse('https://chapingo.web.app/');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 20,
            vertical: isMobile ? 14 : 14,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primaryLight.withValues(alpha: 0.1),
                AppColors.glassDark.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ).createShader(bounds),
                child: Text(
                  'Emilio Álvarez Herrera',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

/// Fondo animado con partículas
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
          painter: _BackgroundPainter(
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42);

  _BackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Gradiente base
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0A0A),
          AppColors.backgroundDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid sutil
    final gridPaint = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Partículas flotantes
    for (int i = 0; i < 30; i++) {
      final baseX = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final particleSize = _random.nextDouble() * 3 + 1;
      final speed = _random.nextDouble() * 0.5 + 0.2;
      final offset = sin((animationValue + i * 0.1) * 2 * pi) * 20;

      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: _random.nextDouble() * 0.3 + 0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 2);

      canvas.drawCircle(
        Offset(baseX, (baseY + offset * speed) % size.height),
        particleSize,
        paint,
      );
    }

    // Círculos de glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.2),
        radius: 300,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      300,
      glowPaint,
    );

    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.08),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.6),
        radius: 400,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.6),
      400,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Hero Section - Rediseñada estilo Discord móvil
class _HeroSection extends StatelessWidget {
  final AnimationController animationController;
  final AnimationController floatController;
  final double scrollOffset;

  const _HeroSection({
    required this.animationController,
    required this.floatController,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          // Elementos 3D flotantes - más visibles y mejor posicionados para móvil
          // Mancuerna (arriba derecha)
          Positioned(
            top: isMobile
                ? size.height * 0.06 - scrollOffset * 0.15
                : size.height * 0.15 - scrollOffset * 0.3,
            right: isMobile ? 16 : size.width * 0.1,
            child: FloatingElement(
              amplitude: isMobile ? 15 : 20,
              duration: const Duration(seconds: 4),
              rotates: true,
              child: Opacity(
                opacity: isMobile ? 0.85 : 0.6,
                child: Dumbbell3D(size: isMobile ? 42 : 50),
              ),
            ),
          ),
          // Disco de pesa (izquierda superior)
          Positioned(
            top: isMobile
                ? size.height * 0.12 - scrollOffset * 0.1
                : size.height * 0.6 - scrollOffset * 0.2,
            left: isMobile ? 12 : size.width * 0.05,
            child: FloatingElement(
              amplitude: isMobile ? 12 : 15,
              duration: const Duration(milliseconds: 3500),
              delay: 0.5,
              child: Opacity(
                opacity: isMobile ? 0.8 : 0.5,
                child: WeightPlate3D(size: isMobile ? 50 : 60),
              ),
            ),
          ),
          // Kettlebell (abajo derecha)
          Positioned(
            bottom: isMobile
                ? size.height * 0.28 + scrollOffset * 0.08
                : size.height * 0.2 + scrollOffset * 0.1,
            right: isMobile ? 20 : size.width * 0.15,
            child: FloatingElement(
              amplitude: isMobile ? 10 : 12,
              duration: const Duration(milliseconds: 3800),
              delay: 0.3,
              child: Opacity(
                opacity: isMobile ? 0.75 : 0.4,
                child: Kettlebell3D(size: isMobile ? 40 : 45),
              ),
            ),
          ),
          // Disco adicional para móvil (abajo izquierda)
          if (isMobile)
            Positioned(
              bottom: size.height * 0.32 + scrollOffset * 0.05,
              left: 24,
              child: FloatingElement(
                amplitude: 12,
                duration: const Duration(milliseconds: 3200),
                delay: 0.7,
                child: Opacity(
                  opacity: 0.7,
                  child: const WeightPlate3D(size: 38, color: AppColors.primaryLight),
                ),
              ),
            ),
          // Contenido principal - mejor espaciado móvil
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : AppConstants.spacingXXL,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? size.height * 0.12 : 0),
                  const Spacer(flex: 2),
                  // Logo con glow - más grande en móvil
                  _buildAnimatedLogo(isMobile),
                  SizedBox(height: isMobile ? 28 : AppConstants.spacingXL),
                  // Título - más impactante
                  _buildAnimatedTitle(isMobile),
                  SizedBox(height: isMobile ? 20 : AppConstants.spacingL),
                  // Tagline
                  _buildAnimatedTagline(isMobile),
                  SizedBox(height: isMobile ? 36 : AppConstants.spacingXXL),
                  // CTA Button - más prominente
                  _buildAnimatedCTA(context, isMobile),
                  const Spacer(flex: 2),
                  // Scroll indicator
                  _buildScrollIndicator(),
                  SizedBox(height: isMobile ? 32 : AppConstants.spacingXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo(bool isMobile) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0, 0.5, curve: Curves.easeOut),
        )),
        child: AnimatedBuilder(
          animation: floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, sin(floatController.value * 2 * pi) * 6),
              child: Container(
                width: isMobile ? 120 : 130,
                height: isMobile ? 120 : 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: isMobile ? 50 : 40,
                      spreadRadius: isMobile ? 15 : 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(bool isMobile) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
        )),
        child: Column(
          children: [
            Text(
              'MEXICAN',
              style: TextStyle(
                fontSize: isMobile ? 44 : 64,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryDark,
                letterSpacing: isMobile ? 8 : 12,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ).createShader(bounds),
              child: Text(
                'BULKING',
                style: TextStyle(
                  fontSize: isMobile ? 44 : 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: isMobile ? 10 : 16,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTagline(bool isMobile) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
        )),
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? 300 : 500),
          child: Column(
            children: [
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: 1.2,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 10 : AppConstants.spacingXS),
              Text(
                AppConstants.appTaglineSecondary,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCTA(BuildContext context, bool isMobile) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.6, 1, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.6, 1, curve: Curves.easeOut),
        )),
        child: _CTAButton(
          text: 'EMPEZAR AHORA',
          icon: Icons.arrow_forward_rounded,
          isPrimary: true,
          isMobile: isMobile,
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1, curve: Curves.easeOut),
      ),
      child: AnimatedBuilder(
        animation: floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, sin(floatController.value * 2 * pi) * 6),
            child: Column(
              children: [
                Text(
                  'Desliza para explorar',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bloque de feature alternado - Rediseñado estilo Discord móvil
class _FeatureBlock extends StatefulWidget {
  final String title;
  final String description;
  final Widget illustration;
  final bool imageOnLeft;
  final Color? accentColor;
  final List<String>? bulletPoints;

  const _FeatureBlock({
    required this.title,
    required this.description,
    required this.illustration,
    this.imageOnLeft = true,
    this.accentColor,
    this.bulletPoints,
  });

  @override
  State<_FeatureBlock> createState() => _FeatureBlockState();
}

class _FeatureBlockState extends State<_FeatureBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final accentColor = widget.accentColor ?? AppColors.primary;

    // Detectar visibilidad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isVisible && mounted) {
        _isVisible = true;
        _controller.forward();
      }
    });

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        )),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : AppConstants.spacingXXL,
            vertical: isMobile ? 48 : AppConstants.spacingXXL,
          ),
          child: isMobile
              ? _buildMobileLayout(accentColor)
              : _buildDesktopLayout(accentColor),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Color accentColor) {
    // En móvil solo mostramos el contenido de texto, sin las ilustraciones animadas
    return _buildContent(accentColor, isMobile: true);
  }

  Widget _buildDesktopLayout(Color accentColor) {
    final children = [
      Expanded(
        flex: 5,
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              radius: 1.2,
            ),
          ),
          child: widget.illustration,
        ),
      ),
      const SizedBox(width: AppConstants.spacingXXL),
      Expanded(
        flex: 5,
        child: _buildContent(accentColor, isMobile: false),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.imageOnLeft ? children : children.reversed.toList(),
    );
  }

  Widget _buildContent(Color accentColor, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Línea de acento más prominente
        Container(
          width: isMobile ? 45 : 50,
          height: isMobile ? 4 : 3,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : AppConstants.spacingM),
        // Título más grande en móvil
        Text(
          widget.title,
          style: TextStyle(
            fontSize: isMobile ? 26 : 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: isMobile ? 14 : AppConstants.spacingM),
        // Descripción con mejor legibilidad
        Text(
          widget.description,
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            color: AppColors.textSecondaryDark,
            height: 1.65,
            letterSpacing: 0.1,
          ),
        ),
        if (widget.bulletPoints != null) ...[
          SizedBox(height: isMobile ? 20 : AppConstants.spacingL),
          ...widget.bulletPoints!.map((point) => Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 12 : AppConstants.spacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: accentColor,
                        size: isMobile ? 16 : 14,
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 13,
                          color: AppColors.textSecondaryDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

/// Carrusel de imágenes con auto-scroll - Mejorado para móvil
class _ImageCarousel extends StatefulWidget {
  final bool isMobile;

  const _ImageCarousel({this.isMobile = false});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<String> _images = const [
    'assets/publicidad/p1.jpg',
    'assets/publicidad/p2.jpg',
    'assets/publicidad/p3.jpg',
    'assets/publicidad/p4.jpg',
    'assets/publicidad/p5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.isMobile ? 0.88 : 0.85);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.isMobile ? 280 : 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final page = _pageController.page ?? _currentPage.toDouble();
                    scale = (1 - (page - index).abs() * 0.12).clamp(0.88, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 6 : AppConstants.spacingS,
                    vertical: widget.isMobile ? 12 : AppConstants.spacingM,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.isMobile ? 20 : AppConstants.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: widget.isMobile ? 24 : 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.isMobile ? 20 : AppConstants.radiusXL),
                    child: Image.asset(
                      _images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceDark,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondaryDark,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: widget.isMobile ? 20 : AppConstants.spacingM),
        // Indicadores de página mejorados
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _images.length,
            (index) => GestureDetector(
              onTap: () => _goToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 5 : 4),
                width: _currentPage == index ? (widget.isMobile ? 28 : 24) : (widget.isMobile ? 10 : 8),
                height: widget.isMobile ? 10 : 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.isMobile ? 5 : 4),
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  boxShadow: _currentPage == index
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón CTA - Rediseñado estilo Discord
class _CTAButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final bool isMobile;
  final VoidCallback onPressed;

  const _CTAButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isMobile
        ? (widget.isPrimary ? 36.0 : 28.0)
        : (widget.isPrimary ? 32.0 : 24.0);
    final verticalPadding = widget.isMobile
        ? (widget.isPrimary ? 18.0 : 14.0)
        : (widget.isPrimary ? 16.0 : 12.0);
    final fontSize = widget.isMobile
        ? (widget.isPrimary ? 16.0 : 14.0)
        : (widget.isPrimary ? 15.0 : 13.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [AppColors.primaryLight, AppColors.primary]
                        : [AppColors.primary, AppColors.primary],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.isMobile ? 14 : 12),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: _isHovered
                        ? AppColors.primary
                        : AppColors.glassBorder.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isHovered ? 0.5 : 0.35),
                      blurRadius: _isHovered ? 24 : 16,
                      spreadRadius: _isHovered ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          transform: _isPressed
              ? Matrix4.translationValues(0.0, 2.0, 0.0)
              : (_isHovered ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.isPrimary
                      ? AppColors.backgroundDark
                      : (_isHovered ? AppColors.primary : AppColors.textPrimaryDark),
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: widget.isMobile ? 10 : 8),
              Icon(
                widget.icon,
                color: widget.isPrimary
                    ? AppColors.backgroundDark
                    : (_isHovered ? AppColors.primary : AppColors.textPrimaryDark),
                size: widget.isMobile ? 20 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de ubicación - Mejorada para móvil
class _LocationCard extends StatelessWidget {
  final bool isMobile;

  const _LocationCard({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.all(isMobile ? 18 : AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.glassDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(isMobile ? 18 : AppConstants.radiusL),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: isMobile ? 22 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 14 : AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mexican Bulking Gym',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 4),
                    Text(
                      'Calz. Aragón 14, Lindavista\n07300 Ciudad de México, CDMX',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: AppColors.textSecondaryDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 18 : AppConstants.spacingL),
          // Mapa clickeable
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://maps.app.goo.gl/KspxQHHMhfrkfoSn6');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              height: isMobile ? 140 : 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isMobile ? 14 : AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 14 : AppConstants.radiusM),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/gym_satellite_map.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceDark,
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            color: AppColors.textSecondaryDark,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Overlay con botón
                    Positioned(
                      bottom: isMobile ? 10 : 8,
                      right: isMobile ? 10 : 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 14 : 12,
                          vertical: isMobile ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(isMobile ? 22 : 20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: AppColors.backgroundDark,
                              size: isMobile ? 14 : 14,
                            ),
                            SizedBox(width: isMobile ? 6 : 4),
                            Text(
                              'Ver en Maps',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de red social - Mejorado para móvil
class _SocialButton extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String url;
  final bool isMobile;

  const _SocialButton({
    required this.icon,
    required this.gradient,
    required this.url,
    this.isMobile = false,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.isMobile ? 54.0 : 56.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          final Uri url = Uri.parse(widget.url);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(widget.isMobile ? 14 : AppConstants.radiusM),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: _isHovered ? 0.5 : 0.35),
                blurRadius: _isHovered ? 20 : 12,
                spreadRadius: _isHovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          transform: _isPressed
              ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
              : (_isHovered ? Matrix4.diagonal3Values(1.08, 1.08, 1.0) : Matrix4.identity()),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: widget.isMobile ? 26 : 28,
          ),
        ),
      ),
    );
  }
}

/// Painter para la gráfica de progreso
class _ChartPainter extends CustomPainter {
  final Color color;

  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    canvas.drawPath(path, paint);

    // Puntos
    final dotPaint = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
