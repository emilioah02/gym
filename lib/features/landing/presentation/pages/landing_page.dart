import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';

/// Landing Page with parallax hero section and glassmorphism design
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollController.offset);
      });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSatelliteMapGrid() {
    // Imagen satelital de Google Maps del gimnasio Mexican Bulking
    // Coordenadas: 19.4911, -99.1320 (Lindavista, CDMX)
    // Usa imagen local para mejor rendimiento y evitar costos de API
    return Image.asset(
      'assets/images/gym_satellite_map.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackMap(),
    );
  }

  Widget _buildFallbackMap() {
    // Fallback usando tiles de OpenStreetMap si la API de Google falla
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMapTile(6672, 12784),
        _buildMapTile(6673, 12784),
        _buildMapTile(6674, 12784),
        _buildMapTile(6672, 12785),
        _buildMapTile(6673, 12785),
        _buildMapTile(6674, 12785),
        _buildMapTile(6672, 12786),
        _buildMapTile(6673, 12786),
        _buildMapTile(6674, 12786),
      ],
    );
  }

  Widget _buildMapTile(int x, int y) {
    return CachedNetworkImage(
      imageUrl: 'https://tile.openstreetmap.org/15/$x/$y.png',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.glassDark,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.glassDark,
        child: const Icon(
          Icons.map_outlined,
          color: AppColors.textSecondaryDark,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Parallax background
          _buildParallaxBackground(size),
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeroSection(size)),
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              SliverToBoxAdapter(child: _buildCarouselSection()),
              SliverToBoxAdapter(child: _buildCtaSection()),
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground(Size size) {
    return Positioned(
      top: -_scrollOffset * AppConstants.parallaxFactor,
      left: 0,
      right: 0,
      child: SizedBox(
        height: size.height * 1.2,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), AppColors.backgroundDark],
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.3,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: Size(size.width, size.height * 1.2),
              painter: _GridPainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Size size) {
    return Container(
      height: size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.glowPrimary,
                      blurRadius: 30,
                      spreadRadius: 5,
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
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
              )),
              child: Column(
                children: [
                  Text(
                    'MEXICAN',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    'BULKING',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                child: Column(
                  children: [
                    Text(
                      AppConstants.appTagline,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      AppConstants.appTaglineSecondary,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                child: PrimaryButton(
                  text: 'EMPEZAR A ENTRENAR',
                  icon: Icons.fitness_center,
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          // FadeTransition(
          //   opacity: _animationController,
          //   child: _buildScrollIndicator(),
          // ),
          // const SizedBox(hei ght: AppConstants.spacingXL),
        ],
      ),
    );
  }

  // Widget _buildScrollIndicator() {
  //   return Column(
  //     children: [
  //       Text(
  //         'Desliza para explorar',
  //         style: AppTypography.labelSmall.copyWith(
  //           color: AppColors.textSecondaryDark,
  //         ),
  //       ),
  //       const SizedBox(height: AppConstants.spacingS),
  //       const Icon(
  //         Icons.keyboard_arrow_down,
  //         color: AppColors.primary,
  //         size: 32,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.calendar_month,
        'title': 'Rutinas Personalizadas',
        'description': 'Planes de entrenamiento para hombres y mujeres',
      },
      {
        'icon': Icons.fitness_center,
        'title': '35+ Ejercicios',
        'description': 'Biblioteca completa de máquinas con guías',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Sigue tu Progreso',
        'description': 'Monitorea tu camino fitness',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          Text(
            '¿Por qué Mexican Bulking?',
            style: AppTypography.headlineMediumDark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: AppTypography.titleMediumDark,
                            ),
                            const SizedBox(height: AppConstants.spacingXS),
                            Text(
                              feature['description'] as String,
                              style: AppTypography.bodySmallDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    // Lista de imágenes de publicidad del gimnasio
    final List<String> instagramImages = [
      'assets/publicidad/p1.jpg',
      'assets/publicidad/p2.jpg',
      'assets/publicidad/p3.jpg',
      'assets/publicidad/p4.jpg',
      'assets/publicidad/p5.jpg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXXL),
      child: Column(
        children: [
          Text(
            'Nuestras Instalaciones',
            style: AppTypography.headlineMediumDark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          CarouselSlider(
            options: CarouselOptions(
              height: 300,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              enlargeCenterPage: true,
              enlargeFactor: 0.25,
              viewportFraction: 0.85,
            ),
            items: instagramImages.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.glassBorder.withValues(alpha: 0.2),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textSecondaryDark,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagen no encontrada',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: GlassCard(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          children: [
            Text(
              '¿Listo para Transformarte?',
              style: AppTypography.headlineSmallDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Comienza tu camino fitness hoy con Mexican Bulking.',
              style: AppTypography.bodyMediumDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            PrimaryButton(
              text: 'Comenzar',
              icon: Icons.arrow_forward,
              onPressed: () => context.go(AppRoutes.login),
            ),
            const SizedBox(height: AppConstants.spacingM),
            PrimaryButton(
              text: 'Ya Tengo una Cuenta',
              isOutlined: true,
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.spacingXXL),
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withValues(alpha: 0.8),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Visítanos',
            style: AppTypography.headlineSmallDark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuestra Ubicación',
                            style: AppTypography.titleMediumDark,
                          ),
                          const SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'Mexican Bulking Gym',
                            style: AppTypography.bodySmallDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingL),
                // Mapa satelital - Vista estática del gimnasio
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse('https://maps.app.goo.gl/KspxQHHMhfrkfoSn6');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.glassDark,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Vista satelital usando tiles de OpenStreetMap
                          // Coordenadas: 19.4911, -99.1320 (Lindavista, CDMX)
                          _buildSatelliteMapGrid(),

                          // Pin de ubicación centrado
                          // const Center(
                          //   child: Icon(
                          //     Icons.location_pin,
                          //     color: AppColors.error,
                          //     size: 48,
                          //     shadows: [
                          //       Shadow(
                          //         color: Colors.black54,
                          //         blurRadius: 8,
                          //         offset: Offset(0, 2),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // Overlay de tap para indicar que es clickeable
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ver en Google Maps',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
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
                const SizedBox(height: AppConstants.spacingM),

                // Dirección
                Row(
                  children: [
                    const Icon(Icons.place, color: AppColors.textSecondaryDark, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Calz. Aragón 14, Lindavista\n07300 Ciudad de México, CDMX',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),
          // Redes Sociales
          Text(
            'Síguenos en Redes Sociales',
            style: AppTypography.titleMediumDark,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Instagram
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(AppConstants.instagramUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF833AB4),
                        Color(0xFFFD1D1D),
                        Color(0xFFFCAF45),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFD1D1D).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingL),
              // Facebook
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(AppConstants.facebookUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1877F2).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.facebook,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),
          // Copyright
          Text(
            '© 2025 Mexican Bulking. Todos los derechos reservados.',
            style: AppTypography.bodySmallDark.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingS),

          // Legal Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => context.push(AppRoutes.privacyPolicy),
                child: Text(
                  'Privacidad',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Text(
                '•',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              InkWell(
                onTap: () => context.push(AppRoutes.termsConditions),
                child: Text(
                  'Términos',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Developer Credit
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://chapingo.web.app/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.glassDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.code,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppConstants.spacingS),
                  Text(
                    'Programado por Emilio Álvarez Herrera',
                    style: AppTypography.bodySmallDark.copyWith(
                      color: AppColors.textSecondaryDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingXS),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: AppColors.textSecondaryDark,
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
