import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/data/auth_service.dart';

/// Página de perfil del cliente
class ClientProfilePage extends ConsumerStatefulWidget {
  const ClientProfilePage({super.key});

  @override
  ConsumerState<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends ConsumerState<ClientProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _alturaController;
  late TextEditingController _pesoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _edadController = TextEditingController();
    _alturaController = TextEditingController();
    _pesoController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _initControllers(UserModel user) {
    _nombreController.text = user.nombre ?? '';
    _edadController.text = user.edad?.toString() ?? '';
    _alturaController.text = user.altura?.toString() ?? '';
    _pesoController.text = user.peso?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('Usuario no encontrado')),
                    );
                  }
                  return SliverToBoxAdapter(child: _buildContent(user));
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.backgroundDark,
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Perfil',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 4),
      //     child: _isEditing
      //         ? TextButton(
      //             onPressed: () => setState(() => _isEditing = false),
      //             child: const Text('Cancelar'),
      //           )
      //         : IconButton(
      //             icon: const Icon(Icons.edit, color: AppColors.primary),
      //             onPressed: () {
      //               final user = ref.read(userModelProvider).valueOrNull;
      //               if (user != null) {
      //                 _initControllers(user);
      //                 setState(() => _isEditing = true);
      //               }
      //             },
      //           ),
      //   ),
      // ],
    );
  }

  Widget _buildContent(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          // Avatar y nombre
          _buildProfileHeader(user),
          const SizedBox(height: AppConstants.spacingL),

          // Membresía
          _buildMembershipCard(user),
          const SizedBox(height: AppConstants.spacingL),

          // Stats de IMC
          _buildIMCCard(user),
          const SizedBox(height: AppConstants.spacingL),

          // Información personal
          _buildPersonalInfo(user),
          const SizedBox(height: AppConstants.spacingL),

          // Objetivo
          if (user.objetivo != null) ...[
            _buildGoalCard(user),
            const SizedBox(height: AppConstants.spacingL),
          ],

          // Progreso de peso
          _buildWeightProgress(user),
          const SizedBox(height: AppConstants.spacingL),

          // Acciones
          _buildActions(user),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: user.photoUrl != null
                  ? CachedNetworkImageProvider(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      (user.nombre ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            if (user.genero != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: user.genero == UserGender.hombre
                        ? Colors.blue
                        : Colors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    user.genero == UserGender.hombre
                        ? Icons.male
                        : Icons.female,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          user.nombre ?? 'Usuario',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          user.email,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        if (user.rachasDias > 0) ...[
          const SizedBox(height: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.rachasDias} días de racha',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMembershipCard(UserModel user) {
    final hasActiveMembership = user.tieneMembresiaActiva;
    final isExpiringSoon = user.membresiaPorVencer;
    final daysRemaining = user.diasRestantesMembresia;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasActiveMembership
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasActiveMembership ? Icons.card_membership : Icons.warning,
                  color: hasActiveMembership ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membresía',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      hasActiveMembership ? 'Activa' : 'Vencida',
                      style: AppTypography.bodyMedium.copyWith(
                        color: hasActiveMembership
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () => _showMembershipDialog(user),
              ),
            ],
          ),
          if (user.tipoMembresia != null) ...[
            const Divider(color: AppColors.glassBorder),
            _InfoRow(
              icon: Icons.event,
              label: 'Tipo',
              value: user.tipoMembresia!.displayName,
            ),
            if (user.fechaPagoMembresia != null)
              _InfoRow(
                icon: Icons.payment,
                label: 'Fecha de pago',
                value: DateFormat('dd/MM/yyyy').format(user.fechaPagoMembresia!),
              ),
            if (user.fechaFinMembresia != null)
              _InfoRow(
                icon: Icons.event_available,
                label: 'Vencimiento',
                value: DateFormat('dd/MM/yyyy').format(user.fechaFinMembresia!),
              ),
            if (hasActiveMembership) ...[
              const Divider(color: AppColors.glassBorder),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: isExpiringSoon
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isExpiringSoon ? Icons.warning : Icons.check_circle,
                      color: isExpiringSoon ? AppColors.warning : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpiringSoon
                          ? '¡Renueva pronto! $daysRemaining días restantes'
                          : '$daysRemaining días restantes',
                      style: TextStyle(
                        color: isExpiringSoon ? AppColors.warning : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (!hasActiveMembership) ...[
            const Divider(color: AppColors.glassBorder),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPaymentDialog,
                icon: const Icon(Icons.payment),
                label: const Text('Renovar Membresía'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIMCCard(UserModel user) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Peso',
                value: user.peso?.toStringAsFixed(1) ?? '-',
                unit: 'kg',
                icon: Icons.monitor_weight,
                color: AppColors.info,
              ),
              Container(width: 1, height: 50, color: AppColors.glassBorder),
              _StatItem(
                label: 'Altura',
                value: user.altura?.toStringAsFixed(2) ?? '-',
                unit: 'm',
                icon: Icons.height,
                color: AppColors.primary,
              ),
              Container(width: 1, height: 50, color: AppColors.glassBorder),
              _StatItem(
                label: 'IMC',
                value: user.imc?.toStringAsFixed(1) ?? '-',
                unit: '',
                icon: Icons.calculate,
                color: _getIMCColor(user.rangoIMC),
              ),
            ],
          ),
          if (user.rangoIMC != null) ...[
            const Divider(color: AppColors.glassBorder),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: _getIMCColor(user.rangoIMC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIMCIcon(user.rangoIMC),
                    color: _getIMCColor(user.rangoIMC),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rango OMS: ${user.rangoIMC!.displayName}',
                    style: TextStyle(
                      color: _getIMCColor(user.rangoIMC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(UserModel user) {
    if (_isEditing) {
      return _buildEditForm(user);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: AppColors.glassBorder),
          _InfoRow(
            icon: Icons.person,
            label: 'Nombre',
            value: user.nombre ?? '-',
          ),
          _InfoRow(
            icon: Icons.cake,
            label: 'Edad',
            value: user.edad != null ? '${user.edad} años' : '-',
          ),
          _InfoRow(
            icon: user.genero == UserGender.hombre ? Icons.male : Icons.female,
            label: 'Género',
            value: user.genero?.displayName ?? '-',
          ),
          if (user.diasEntrenamiento != null &&
              user.diasEntrenamiento!.isNotEmpty)
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Días de entrenamiento',
              value: '${user.diasEntrenamiento!.length} días/semana',
            ),
        ],
      ),
    );
  }

  Widget _buildEditForm(UserModel user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar Información',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          _EditField(
            label: 'Nombre',
            controller: _nombreController,
            icon: Icons.person,
          ),
          _EditField(
            label: 'Edad',
            controller: _edadController,
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            suffix: 'años',
          ),
          _EditField(
            label: 'Altura',
            controller: _alturaController,
            icon: Icons.height,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: 'm',
          ),
          _EditField(
            label: 'Peso',
            controller: _pesoController,
            icon: Icons.monitor_weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: 'kg',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(UserModel user) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag, color: AppColors.primary),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu Objetivo',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  user.objetivo!.displayName,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgress(UserModel user) {
    if (user.pesoInicial == null || user.peso == null) {
      return const SizedBox.shrink();
    }

    final difference = user.peso! - user.pesoInicial!;
    final isLoss = difference < 0;
    final color = isLoss ? AppColors.success : AppColors.info;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de Peso',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Inicial',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  Text(
                    '${user.pesoInicial!.toStringAsFixed(1)} kg',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              Icon(
                isLoss ? Icons.trending_down : Icons.trending_up,
                color: color,
                size: 32,
              ),
              Column(
                children: [
                  Text(
                    'Actual',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  Text(
                    '${user.peso!.toStringAsFixed(1)} kg',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLoss ? 'Has bajado' : 'Has subido',
                  style: TextStyle(color: color),
                ),
                const SizedBox(width: 4),
                Text(
                  '${difference.abs().toStringAsFixed(1)} kg',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(UserModel user) {
    return Column(
      children: [
        // Compartir App
        GlassCard(
          onTap: _shareApp,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Compartir App',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        // Enviar Retroalimentación
        GlassCard(
          onTap: _sendFeedback,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.feedback_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Enviar Retroalimentación',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        // Actualizar Datos
        GlassCard(
          onTap: () => context.go(AppRoutes.clientOnboarding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Actualizar Datos',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        // Cerrar Sesión
        GlassCard(
          onTap: _signOut,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Cerrar Sesión',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.error),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        '¡Únete a Mexican Bulking! La mejor app para transformar tu cuerpo. '
        'Descarga la app y comienza tu transformación hoy: '
        '[Link de la app]',
        subject: 'Mexican Bulking - Tu gimnasio en tu bolsillo',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendFeedback() async {
    const phoneNumber = '+525511600105';
    final message = Uri.encodeComponent(
      'Hola, quiero enviar retroalimentación sobre Mexican Bulking:',
    );
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showMembershipDialog(UserModel user) async {
    final now = DateTime.now();
    MembershipType? selectedType;
    DateTime? paymentDate;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            'Gestionar Membresía',
            style: AppTypography.titleLargeDark,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de Membresía',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...MembershipType.values.map((type) => RadioListTile<MembershipType>(
                  title: Text(
                    type.displayName,
                    style: AppTypography.bodyMediumDark,
                  ),
                  value: type,
                  groupValue: selectedType,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.textSecondaryDark;
                  }),
                  onChanged: (value) => setState(() => selectedType = value),
                )),
                const SizedBox(height: 16),
                Text(
                  'Fecha de Pago',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2020),
                      lastDate: now,
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            surface: AppColors.surfaceDark,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => paymentDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.glassDark,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          paymentDate != null
                              ? DateFormat('dd/MM/yyyy').format(paymentDate!)
                              : 'Seleccionar fecha',
                          style: AppTypography.bodyMediumDark,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedType != null && paymentDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de vencimiento',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime(
                              paymentDate!.year,
                              paymentDate!.month + selectedType!.durationInMonths,
                              paymentDate!.day,
                            ),
                          ),
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedType != null && paymentDate != null
                  ? () async {
                      final endDate = DateTime(
                        paymentDate!.year,
                        paymentDate!.month + selectedType!.durationInMonths,
                        paymentDate!.day,
                      );

                      try {
                        final firebaseService = ref.read(firebaseServiceProvider);
                        await firebaseService.updateUserProfile(user.uid, {
                          'tipoMembresia': selectedType!.value,
                          'fechaPagoMembresia': paymentDate,
                          'fechaFinMembresia': endDate,
                        });

                        ref.invalidate(userModelProvider);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Membresía actualizada'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Row(
          children: [
            const Icon(Icons.payment, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Renovar Membresía', style: AppTypography.titleLargeDark),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Realiza tu pago mediante transferencia a:',
                style: AppTypography.bodyMediumDark,
              ),
              const SizedBox(height: 16),
              _PaymentInfoTile(
                label: 'Banco',
                value: 'Banco Azteca',
                icon: Icons.account_balance,
              ),
              _PaymentInfoTile(
                label: 'Número de cuenta',
                value: '49541309234643',
                icon: Icons.credit_card,
              ),
              _PaymentInfoTile(
                label: 'CLABE',
                value: '127180013092346436',
                icon: Icons.pin,
              ),
              _PaymentInfoTile(
                label: 'Número de tarjeta',
                value: '4027665864357166',
                icon: Icons.payment,
              ),
              _PaymentInfoTile(
                label: 'Titular',
                value: 'Luis Emilio Álvarez Herrera',
                icon: Icons.person,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: _sendPaymentReceipt,
            icon: const Icon(Icons.send),
            label: const Text('Enviar Comprobante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPaymentReceipt() async {
    const phoneNumber = '+525511600105';
    final message = Uri.encodeComponent(
      'Hola, quiero enviar el comprobante de pago de mi membresía de Mexican Bulking.',
    );
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = ref.read(userModelProvider).valueOrNull;

      if (currentUser != null) {
        final peso = double.tryParse(_pesoController.text);
        final altura = double.tryParse(_alturaController.text);

        await firebaseService.updateUserProfile(currentUser.uid, {
          'nombre': _nombreController.text,
          'edad': int.tryParse(_edadController.text),
          'altura': altura,
          'peso': peso,
        });

        ref.invalidate(userModelProvider);

        if (mounted) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Cerrar Sesión', style: AppTypography.titleLargeDark),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: AppTypography.bodyMediumDark,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().signOut();
      if (mounted) {
        context.go(AppRoutes.landing);
      }
    }
  }

  Color _getIMCColor(IMCRange? range) {
    switch (range) {
      case IMCRange.bajoPeso:
        return AppColors.info;
      case IMCRange.normal:
        return AppColors.success;
      case IMCRange.sobrepeso:
        return AppColors.warning;
      case IMCRange.obesidad:
        return AppColors.error;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  IconData _getIMCIcon(IMCRange? range) {
    switch (range) {
      case IMCRange.bajoPeso:
        return Icons.trending_down;
      case IMCRange.normal:
        return Icons.check_circle;
      case IMCRange.sobrepeso:
        return Icons.warning;
      case IMCRange.obesidad:
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ],
        ),
        Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryDark),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffix;

  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTypography.bodyMediumDark,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
                suffixText: suffix,
                suffixStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PaymentInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.glassDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
