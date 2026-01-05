import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';

/// Sección de feature alternada estilo Discord
/// Imagen a la izquierda o derecha según el índice
class FeatureSection extends StatefulWidget {
  final String title;
  final String description;
  final Widget illustration;
  final bool imageOnLeft;
  final Color? accentColor;
  final List<String>? bulletPoints;

  const FeatureSection({
    super.key,
    required this.title,
    required this.description,
    required this.illustration,
    this.imageOnLeft = true,
    this.accentColor,
    this.bulletPoints,
  });

  @override
  State<FeatureSection> createState() => _FeatureSectionState();
}

class _FeatureSectionState extends State<FeatureSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.imageOnLeft ? -0.2 : 0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(bool visible) {
    if (visible && !_isVisible) {
      _isVisible = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final accentColor = widget.accentColor ?? AppColors.primary;

    return VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
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
      ),
    );
  }

  Widget _buildMobileLayout(Color accentColor) {
    return Column(
      children: [
        // Ilustración arriba en móvil
        Container(
          height: 250,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingXL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.2),
                Colors.transparent,
              ],
              radius: 1.5,
            ),
          ),
          child: widget.illustration,
        ),
        // Contenido abajo
        _buildContent(accentColor),
      ],
    );
  }

  Widget _buildDesktopLayout(Color accentColor) {
    final children = [
      // Ilustración
      Expanded(
        flex: 5,
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            gradient: RadialGradient(
              colors: [
                accentColor.withValues(alpha: 0.15),
                Colors.transparent,
              ],
              radius: 1.2,
            ),
          ),
          child: widget.illustration,
        ),
      ),
      const SizedBox(width: AppConstants.spacingXXL),
      // Contenido
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
        // Línea de acento
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        // Título
        Text(
          widget.title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        // Descripción
        Text(
          widget.description,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryDark,
            height: 1.6,
          ),
        ),
        // Bullet points opcionales
        if (widget.bulletPoints != null && widget.bulletPoints!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingL),
          ...widget.bulletPoints!.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        point,
                        style: AppTypography.bodyMedium.copyWith(
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

/// Detector de visibilidad simple
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final Function(bool) onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  final GlobalKey _key = GlobalKey();
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final RenderBox box = renderObject as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final Size screenSize = MediaQuery.of(context).size;

    final bool isVisible = position.dy < screenSize.height &&
        position.dy + size.height > 0;

    if (isVisible != _wasVisible) {
      _wasVisible = isVisible;
      widget.onVisibilityChanged(isVisible);
    }

    Future.delayed(const Duration(milliseconds: 100), _checkVisibility);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
