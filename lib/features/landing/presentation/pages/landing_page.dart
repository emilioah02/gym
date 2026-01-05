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
              // Stats Section
              SliverToBoxAdapter(child: _buildStatsSection()),
              // Galería
              SliverToBoxAdapter(child: _buildGallerySection()),
              // CTA Final
              SliverToBoxAdapter(child: _buildFinalCTA()),
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

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingXXL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.backgroundDark,
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'MEXICAN BULKING EN NÚMEROS',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return Wrap(
                spacing: AppConstants.spacingXL,
                runSpacing: AppConstants.spacingXL,
                alignment: WrapAlignment.center,
                children: [
                  _StatCard(
                    value: '35+',
                    label: 'Ejercicios',
                    icon: Icons.fitness_center,
                    width: isMobile ? constraints.maxWidth * 0.4 : 150,
                  ),
                  _StatCard(
                    value: '10+',
                    label: 'Rutinas',
                    icon: Icons.calendar_month,
                    width: isMobile ? constraints.maxWidth * 0.4 : 150,
                  ),
                  _StatCard(
                    value: '24/7',
                    label: 'Acceso',
                    icon: Icons.access_time,
                    width: isMobile ? constraints.maxWidth * 0.4 : 150,
                  ),
                  _StatCard(
                    value: '100%',
                    label: 'Gratis',
                    icon: Icons.star,
                    width: isMobile ? constraints.maxWidth * 0.4 : 150,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    final List<String> images = [
      'assets/publicidad/p1.jpg',
      'assets/publicidad/p2.jpg',
      'assets/publicidad/p3.jpg',
      'assets/publicidad/p4.jpg',
      'assets/publicidad/p5.jpg',
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            children: [
              Text(
                'NUESTRAS INSTALACIONES',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Conoce Mexican Bulking Gym',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _GalleryCard(imagePath: images[index], index: index);
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingXL),
      ],
    );
  }

  Widget _buildFinalCTA() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Elementos flotantes decorativos
          SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FloatingElement(
                  amplitude: 8,
                  child: const WeightPlate3D(size: 40),
                ),
                Positioned(
                  left: 50,
                  child: FloatingElement(
                    amplitude: 6,
                    delay: 0.3,
                    child: const WeightPlate3D(size: 30, color: AppColors.primaryLight),
                  ),
                ),
                Positioned(
                  right: 50,
                  child: FloatingElement(
                    amplitude: 6,
                    delay: 0.6,
                    child: const WeightPlate3D(size: 30, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            '¿Listo Para Transformarte?',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Únete a Mexican Bulking y comienza tu camino fitness hoy.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          // Botones
          Wrap(
            spacing: AppConstants.spacingM,
            runSpacing: AppConstants.spacingM,
            alignment: WrapAlignment.center,
            children: [
              _CTAButton(
                text: 'COMENZAR AHORA',
                icon: Icons.rocket_launch,
                isPrimary: true,
                onPressed: () => context.go(AppRoutes.login),
              ),
              _CTAButton(
                text: 'Ya tengo cuenta',
                icon: Icons.login,
                isPrimary: false,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo y nombre
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowPrimary,
                      blurRadius: 15,
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
              const SizedBox(width: AppConstants.spacingM),
              Text(
                'MEXICAN BULKING',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),
          // Ubicación
          _LocationCard(),
          const SizedBox(height: AppConstants.spacingXL),
          // Redes sociales
          Text(
            'Síguenos',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(
                icon: Icons.camera_alt,
                gradient: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
                url: AppConstants.instagramUrl,
              ),
              const SizedBox(width: AppConstants.spacingL),
              _SocialButton(
                icon: Icons.facebook,
                gradient: const [Color(0xFF1877F2), Color(0xFF1877F2)],
                url: AppConstants.facebookUrl,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),
          // Links legales
          Wrap(
            spacing: AppConstants.spacingM,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.privacyPolicy),
                child: Text(
                  'Privacidad',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
              Text('•', style: TextStyle(color: AppColors.textSecondaryDark)),
              TextButton(
                onPressed: () => context.push(AppRoutes.termsConditions),
                child: Text(
                  'Términos',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Copyright
          Text(
            '© 2025 Mexican Bulking. Todos los derechos reservados.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Developer credit
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://chapingo.web.app/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.glassDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.code, size: 14, color: AppColors.primary),
                  const SizedBox(width: AppConstants.spacingS),
                  Text(
                    'Programado por Emilio Álvarez Herrera',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingXS),
                  Icon(Icons.open_in_new, size: 12, color: AppColors.textSecondaryDark),
                ],
              ),
            ),
          ),
        ],
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

/// Hero Section
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
          // Elementos 3D flotantes - adaptados para móvil y desktop
          // Mancuerna (arriba derecha en desktop, arriba derecha en móvil)
          Positioned(
            top: isMobile
                ? size.height * 0.08 - scrollOffset * 0.2
                : size.height * 0.15 - scrollOffset * 0.3,
            right: isMobile ? 20 : size.width * 0.1,
            child: FloatingElement(
              amplitude: isMobile ? 12 : 20,
              duration: const Duration(seconds: 4),
              rotates: true,
              child: Opacity(
                opacity: isMobile ? 0.7 : 0.6,
                child: Dumbbell3D(size: isMobile ? 35 : 50),
              ),
            ),
          ),
          // Disco de pesa (izquierda)
          Positioned(
            top: isMobile
                ? size.height * 0.22 - scrollOffset * 0.15
                : size.height * 0.6 - scrollOffset * 0.2,
            left: isMobile ? 15 : size.width * 0.05,
            child: FloatingElement(
              amplitude: isMobile ? 10 : 15,
              duration: const Duration(milliseconds: 3500),
              delay: 0.5,
              child: Opacity(
                opacity: isMobile ? 0.65 : 0.5,
                child: WeightPlate3D(size: isMobile ? 45 : 60),
              ),
            ),
          ),
          // Kettlebell (abajo derecha)
          Positioned(
            bottom: isMobile
                ? size.height * 0.32 + scrollOffset * 0.1
                : size.height * 0.2 + scrollOffset * 0.1,
            right: isMobile ? 25 : size.width * 0.15,
            child: FloatingElement(
              amplitude: isMobile ? 8 : 12,
              duration: const Duration(milliseconds: 3800),
              delay: 0.3,
              child: Opacity(
                opacity: isMobile ? 0.6 : 0.4,
                child: Kettlebell3D(size: isMobile ? 35 : 45),
              ),
            ),
          ),
          // Disco adicional para móvil (abajo izquierda)
          if (isMobile)
            Positioned(
              bottom: size.height * 0.35 + scrollOffset * 0.05,
              left: 30,
              child: FloatingElement(
                amplitude: 10,
                duration: const Duration(milliseconds: 3200),
                delay: 0.7,
                child: Opacity(
                  opacity: 0.55,
                  child: const WeightPlate3D(size: 35, color: AppColors.primaryLight),
                ),
              ),
            ),
          // Contenido principal
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo con glow
                  _buildAnimatedLogo(),
                  SizedBox(height: isMobile ? AppConstants.spacingL : AppConstants.spacingXL),
                  // Título
                  _buildAnimatedTitle(isMobile),
                  SizedBox(height: isMobile ? AppConstants.spacingM : AppConstants.spacingL),
                  // Tagline
                  _buildAnimatedTagline(isMobile),
                  SizedBox(height: isMobile ? AppConstants.spacingXL : AppConstants.spacingXXL),
                  // CTA Button
                  _buildAnimatedCTA(context),
                  const Spacer(flex: 2),
                  // Scroll indicator
                  _buildScrollIndicator(),
                  const SizedBox(height: AppConstants.spacingXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
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
              offset: Offset(0, sin(floatController.value * 2 * pi) * 5),
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
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
                fontSize: isMobile ? 40 : 64,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryDark,
                letterSpacing: isMobile ? 6 : 12,
                height: 1,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ).createShader(bounds),
              child: Text(
                'BULKING',
                style: TextStyle(
                  fontSize: isMobile ? 40 : 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: isMobile ? 8 : 16,
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
        child: Column(
          children: [
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              AppConstants.appTaglineSecondary,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCTA(BuildContext context) {
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
          text: 'EMPEZAR A ENTRENAR',
          icon: Icons.fitness_center,
          isPrimary: true,
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
            offset: Offset(0, sin(floatController.value * 2 * pi) * 5),
            child: Column(
              children: [
                Text(
                  'Desliza para explorar',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Icon(
                  Icons.keyboard_double_arrow_down,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bloque de feature alternado
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
          begin: Offset(widget.imageOnLeft ? -0.1 : 0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        )),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
            vertical: AppConstants.spacingXXL,
          ),
          child: isMobile
              ? _buildMobileLayout(accentColor)
              : _buildDesktopLayout(accentColor),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Color accentColor) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.15),
                Colors.transparent,
              ],
              radius: 1.5,
            ),
          ),
          child: widget.illustration,
        ),
        _buildContent(accentColor),
      ],
    );
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
        child: _buildContent(accentColor),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.imageOnLeft ? children : children.reversed.toList(),
    );
  }

  Widget _buildContent(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          widget.title,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          widget.description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
            height: 1.6,
          ),
        ),
        if (widget.bulletPoints != null) ...[
          const SizedBox(height: AppConstants.spacingL),
          ...widget.bulletPoints!.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: accentColor, size: 18),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        point,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
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

/// Card de estadística
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final double width;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.glassDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de galería
class _GalleryCard extends StatelessWidget {
  final String imagePath;
  final int index;

  const _GalleryCard({
    required this.imagePath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: AppConstants.spacingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Image.asset(
          imagePath,
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
    );
  }
}

/// Botón CTA
class _CTAButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CTAButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isPrimary ? 32 : 24,
            vertical: widget.isPrimary ? 18 : 14,
          ),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: _isHovered
                        ? [AppColors.primaryLight, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: _isHovered
                        ? AppColors.primary
                        : AppColors.glassBorder,
                    width: 1.5,
                  ),
            boxShadow: widget.isPrimary && _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          transform: _isHovered
              ? Matrix4.translationValues(0.0, -2.0, 0.0)
              : Matrix4.identity(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary
                    ? AppColors.backgroundDark
                    : (_isHovered ? AppColors.primary : AppColors.textPrimaryDark),
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.isPrimary
                      ? AppColors.backgroundDark
                      : (_isHovered ? AppColors.primary : AppColors.textPrimaryDark),
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isPrimary ? 16 : 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de ubicación
class _LocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.glassDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mexican Bulking Gym',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calz. Aragón 14, Lindavista\n07300 Ciudad de México, CDMX',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          // Mapa clickeable
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://maps.app.goo.gl/KspxQHHMhfrkfoSn6');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              color: AppColors.backgroundDark,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ver en Maps',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.backgroundDark,
                                fontWeight: FontWeight.bold,
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

/// Botón de red social
class _SocialButton extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.gradient,
    required this.url,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse(widget.url);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
          ),
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
              : Matrix4.identity(),
          child: Icon(widget.icon, color: Colors.white, size: 28),
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
