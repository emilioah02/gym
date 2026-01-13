import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';

/// Página para crear y enviar anuncios personalizados a clientes
/// Diseño glassmorphismo consistente con el resto de la app
class SendAnnouncementPage extends ConsumerStatefulWidget {
  const SendAnnouncementPage({super.key});

  @override
  ConsumerState<SendAnnouncementPage> createState() => _SendAnnouncementPageState();
}

class _SendAnnouncementPageState extends ConsumerState<SendAnnouncementPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  AnnouncementType _tipoSeleccionado = AnnouncementType.aviso;
  bool _enviarATodos = true;
  final Set<String> _clientesSeleccionados = {};
  bool _isLoading = false;

  // Sugerencias de títulos por tipo
  final Map<AnnouncementType, List<String>> _tituloSugerencias = {
    AnnouncementType.oferta: ['Oferta Especial', 'Descuento Exclusivo', 'Promoción Limitada'],
    AnnouncementType.promocion: ['Nueva Promoción', '2x1 en Suplementos', 'Paquete Especial'],
    AnnouncementType.aviso: ['Aviso Importante', 'Recordatorio', 'Información del Gym'],
    AnnouncementType.informacion: ['Horarios Actualizados', 'Nuevas Clases', 'Mantenimiento'],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();

    _titleFocusNode.addListener(() => setState(() {}));
    _messageFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    _titleFocusNode.dispose();
    _messageFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _enviarAnuncio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseUser = ref.read(firebaseUserProvider).value;
      final userModel = ref.read(userModelProvider).value;

      if (firebaseUser == null || userModel == null) {
        throw Exception('Usuario no autenticado');
      }

      final announcement = AnnouncementModel(
        id: '',
        titulo: _tituloController.text.trim(),
        mensaje: _mensajeController.text.trim(),
        tipo: _tipoSeleccionado,
        entrenadorId: firebaseUser.uid,
        entrenadorNombre: userModel.nombre ?? 'Entrenador',
        fechaCreacion: DateTime.now(),
        clientesIds: _enviarATodos ? [] : _clientesSeleccionados.toList(),
        activo: true,
      );

      await ref.read(firebaseServiceProvider).createAnnouncement(announcement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Anuncio enviado exitosamente'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background con múltiples gradientes
          _buildBackground(),
          // Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipo de anuncio
                          _buildSectionTitle('Tipo de Anuncio', Icons.category_rounded),
                          const SizedBox(height: AppConstants.spacingM),
                          _buildAnnouncementTypeSelector(),
                          const SizedBox(height: AppConstants.spacingXL),

                          // Título con sugerencias
                          _buildSectionTitle('Título', Icons.title_rounded),
                          const SizedBox(height: AppConstants.spacingM),
                          _buildTitleSection(),
                          const SizedBox(height: AppConstants.spacingXL),

                          // Mensaje
                          _buildSectionTitle('Mensaje', Icons.message_rounded),
                          const SizedBox(height: AppConstants.spacingM),
                          _buildMessageInput(),
                          const SizedBox(height: AppConstants.spacingXL),

                          // Destinatarios
                          _buildSectionTitle('Destinatarios', Icons.people_rounded),
                          const SizedBox(height: AppConstants.spacingM),
                          _buildRecipientsSection(clientsAsync),
                          const SizedBox(height: AppConstants.spacingXL),

                          // Preview
                          if (_tituloController.text.isNotEmpty || _mensajeController.text.isNotEmpty) ...[
                            _buildSectionTitle('Vista Previa', Icons.preview_rounded),
                            const SizedBox(height: AppConstants.spacingM),
                            _buildPreview(),
                            const SizedBox(height: AppConstants.spacingXL),
                          ],

                          // Botón de enviar
                          _buildSendButton(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D0D0D),
                Color(0xFF1A1A1A),
                Color(0xFF0D0D0D),
              ],
            ),
          ),
        ),
        // Primary accent orb
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Secondary accent orb
        Positioned(
          bottom: 200,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getTypeColor(_tipoSeleccionado).withValues(alpha: 0.15),
                  _getTypeColor(_tipoSeleccionado).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Subtle noise overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.02),
                Colors.transparent,
                Colors.white.withValues(alpha: 0.01),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.4),
                  AppColors.primary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Nuevo Anuncio',
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementTypeSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTypeChip(AnnouncementType.oferta)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeChip(AnnouncementType.aviso)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTypeChip(AnnouncementType.promocion)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTypeChip(AnnouncementType.informacion)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(AnnouncementType type) {
    final isSelected = _tipoSeleccionado == type;
    final color = _getTypeColor(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoSeleccionado = type;
          _tituloController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.15),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              color: isSelected ? color : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getTypeName(type),
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? color : Colors.white54,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    final sugerencias = _tituloSugerencias[_tipoSeleccionado] ?? [];
    final isFocused = _titleFocusNode.hasFocus;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isFocused ? 0.12 : 0.1),
                Colors.white.withValues(alpha: isFocused ? 0.07 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sugerencias de títulos
              if (sugerencias.isNotEmpty) ...[
                Text(
                  'Sugerencias rápidas',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sugerencias.map((sugerencia) {
                    final isSelected = _tituloController.text == sugerencia;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _tituloController.text = sugerencia;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.3),
                                    AppColors.primary.withValues(alpha: 0.15),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          sugerencia,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected ? AppColors.primary : Colors.white60,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              // Campo de texto
              TextFormField(
                controller: _tituloController,
                focusNode: _titleFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Ej: ¡Oferta especial!',
                  hintStyle: TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error, width: 1),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      Icons.edit_rounded,
                      color: _titleFocusNode.hasFocus ? AppColors.primary : Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final isFocused = _messageFocusNode.hasFocus;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isFocused ? 0.12 : 0.1),
                Colors.white.withValues(alpha: isFocused ? 0.07 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: _mensajeController,
            focusNode: _messageFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            maxLines: 5,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje aquí...',
              hintStyle: TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.all(18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un mensaje';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientsSection(AsyncValue<List<UserModel>> clientsAsync) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Toggle todos los clientes
              GestureDetector(
                onTap: () {
                  setState(() {
                    _enviarATodos = !_enviarATodos;
                    if (_enviarATodos) {
                      _clientesSeleccionados.clear();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _enviarATodos
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.primary.withValues(alpha: 0.1),
                            ],
                          )
                        : null,
                    color: _enviarATodos ? null : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _enviarATodos
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                      width: _enviarATodos ? 1.5 : 1,
                    ),
                    boxShadow: _enviarATodos
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (_enviarATodos ? AppColors.primary : Colors.white).withValues(alpha: 0.2),
                              (_enviarATodos ? AppColors.primary : Colors.white).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: _enviarATodos ? AppColors.primary : Colors.white54,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enviar a todos los clientes',
                              style: AppTypography.titleSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Todos recibirán esta notificación',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Custom Toggle Switch
                      Container(
                        width: 56,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: _enviarATodos
                              ? const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                )
                              : null,
                          color: _enviarATodos ? null : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _enviarATodos
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          alignment: _enviarATodos ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: _enviarATodos ? Colors.white : Colors.white38,
                              shape: BoxShape.circle,
                              boxShadow: _enviarATodos
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de clientes (si no es todos)
              if (!_enviarATodos) ...[
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                clientsAsync.when(
                  data: (clients) {
                    if (clients.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingL),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_off_rounded, color: Colors.white30, size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay clientes disponibles',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        // Contador de seleccionados
                        if (_clientesSeleccionados.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '${_clientesSeleccionados.length} cliente(s) seleccionado(s)',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Lista de clientes
                        ...clients.map((client) {
                          final isSelected = _clientesSeleccionados.contains(client.uid);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _clientesSeleccionados.remove(client.uid);
                                } else {
                                  _clientesSeleccionados.add(client.uid);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.primary.withValues(alpha: 0.15),
                                          AppColors.primary.withValues(alpha: 0.08),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [
                                                AppColors.primary.withValues(alpha: 0.3),
                                                AppColors.primary.withValues(alpha: 0.15),
                                              ]
                                            : [
                                                Colors.white.withValues(alpha: 0.1),
                                                Colors.white.withValues(alpha: 0.05),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (client.nombre ?? 'C')[0].toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected ? AppColors.primary : Colors.white54,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          client.nombre ?? 'Cliente',
                                          style: AppTypography.titleSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          client.email,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [AppColors.primary, AppColors.primaryLight],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Text(
                      'Error al cargar clientes',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final color = _getTypeColor(_tipoSeleccionado);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getTypeIcon(_tipoSeleccionado),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tituloController.text.isEmpty ? 'Título del anuncio' : _tituloController.text,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ahora mismo',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _getTypeName(_tipoSeleccionado).toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _mensajeController.text.isEmpty ? 'El mensaje aparecerá aquí...' : _mensajeController.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: _mensajeController.text.isEmpty ? Colors.white30 : Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = _tituloController.text.isNotEmpty &&
        _mensajeController.text.isNotEmpty &&
        (_enviarATodos || _clientesSeleccionados.isNotEmpty);

    return GestureDetector(
      onTap: canSend && !_isLoading ? _enviarAnuncio : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 62,
        decoration: BoxDecoration(
          gradient: canSend
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: canSend
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: canSend
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 48,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: canSend ? Colors.white : Colors.white30,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Enviar Anuncio',
                      style: AppTypography.titleMedium.copyWith(
                        color: canSend ? Colors.white : Colors.white30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _getTypeName(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return 'Oferta';
      case AnnouncementType.promocion:
        return 'Promoción';
      case AnnouncementType.aviso:
        return 'Aviso';
      case AnnouncementType.informacion:
        return 'Info';
    }
  }

  Color _getTypeColor(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return const Color(0xFF4ADE80); // Green
      case AnnouncementType.promocion:
        return AppColors.primary; // Yellow/Gold
      case AnnouncementType.aviso:
        return const Color(0xFFFBBF24); // Amber
      case AnnouncementType.informacion:
        return const Color(0xFF60A5FA); // Blue
    }
  }

  IconData _getTypeIcon(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return Icons.local_offer_rounded;
      case AnnouncementType.promocion:
        return Icons.celebration_rounded;
      case AnnouncementType.aviso:
        return Icons.notifications_active_rounded;
      case AnnouncementType.informacion:
        return Icons.info_rounded;
    }
  }
}
