import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/models/models.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Página de perfil del entrenador
class TrainerProfilePage extends ConsumerWidget {
  const TrainerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: userAsync.when(
                  data: (user) {
                    if (user == null) {
                      return const _LoadingState();
                    }
                    return _buildContent(context, ref, user);
                  },
                  loading: () => const _LoadingState(),
                  error: (error, _) => _ErrorState(error: error.toString()),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          center: Alignment.topLeft,
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
      expandedHeight: 80,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            60,
            AppConstants.spacingL,
            AppConstants.spacingM,
          ),
          child: Row(
            children: [
              Text(
                'Perfil',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de perfil
          _buildProfileHeader(user),
          const SizedBox(height: AppConstants.spacingL),

          // Modo Cliente
          _buildClientModeCard(context),
          const SizedBox(height: AppConstants.spacingL),

          // Agregar Entrenador
          _buildSectionTitle('Agregar Entrenador'),
          const SizedBox(height: AppConstants.spacingM),
          _AddTrainerCard(),
          const SizedBox(height: AppConstants.spacingL),

          // Información de la cuenta
          _buildSectionTitle('Información de la Cuenta'),
          const SizedBox(height: AppConstants.spacingM),
          _buildInfoCard(user),
          const SizedBox(height: AppConstants.spacingL),

          // Ajustes
          _buildSectionTitle('Ajustes'),
          const SizedBox(height: AppConstants.spacingM),
          _buildSettingsSection(context, ref),
          const SizedBox(height: AppConstants.spacingL),

          // Gestión de Entrenadores (solo admin)
          if (user.rol == UserRole.admin) ...[
            _buildSectionTitle('Gestión de Entrenadores'),
            const SizedBox(height: AppConstants.spacingM),
            _TrainerManagementSection(currentUser: user),
            const SizedBox(height: AppConstants.spacingL),
          ],

          // Acerca de
          _buildSectionTitle('Acerca de'),
          const SizedBox(height: AppConstants.spacingM),
          _buildAboutSection(context),
          const SizedBox(height: AppConstants.spacingL),

          // Cerrar sesión
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return GlassCard(
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(
                    (user.nombre ?? 'E')[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nombre ?? 'Entrenador',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.rol == UserRole.admin
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusRound,
                    ),
                  ),
                  child: Text(
                    user.rol.displayName,
                    style: TextStyle(
                      color: user.rol == UserRole.admin
                          ? AppColors.warning
                          : AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInfoCard(dynamic user) {
    return GlassCard(
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', user.email ?? 'No disponible'),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            'Miembro desde',
            user.createdAt != null
                ? _formatDate(user.createdAt!)
                : 'No disponible',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
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
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.store,
          title: 'Administrar Tienda',
          subtitle: 'Gestionar productos y catálogo',
          onTap: () => context.go('/trainer/store-admin'),
        ),
        const SizedBox(height: AppConstants.spacingS),
        _buildSettingsTile(
          icon: Icons.feedback,
          title: 'Enviar Retroalimentación',
          subtitle: 'Ayúdanos a mejorar la app',
          onTap: () => _sendFeedback(context),
        ),
        const SizedBox(height: AppConstants.spacingS),
        _buildSettingsTile(
          icon: Icons.share,
          title: 'Compartir App',
          subtitle: 'Invita a otros entrenadores',
          onTap: () => _shareApp(context),
        ),
        const SizedBox(height: AppConstants.spacingS),
        _buildSettingsTile(
          icon: Icons.notifications,
          title: 'Notificaciones',
          subtitle: 'Configurar alertas',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Próximamente'),
                backgroundColor: AppColors.info,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.info,
          title: 'Acerca de Mexican Bulking',
          subtitle: 'Versión 1.0.0',
          onTap: () => _showAboutDialog(context),
        ),
        const SizedBox(height: AppConstants.spacingS),
        _buildSettingsTile(
          icon: Icons.privacy_tip,
          title: 'Política de Privacidad',
          subtitle: 'Ver términos y condiciones',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Próximamente'),
                backgroundColor: AppColors.info,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondaryDark),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _logout(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildClientModeCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        context.go('/client/home');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.info,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Cliente',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ver la app como cliente',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.info,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _sendFeedback(BuildContext context) async {
    const phoneNumber = '+525511600105';
    final message = Uri.encodeComponent(
      'Hola, quiero enviar retroalimentación sobre Mexican Bulking:',
    );
    final url = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    // TODO: Implementar share con link de la app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartir app - Próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Mexican Bulking',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Tu aplicación de gestión de entrenamientos para conectar entrenadores con clientes.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              '© 2025 Mexican Bulking',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          '¿Cerrar sesión?',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'Se cerrará tu sesión y deberás iniciar sesión nuevamente.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await ref.read(authServiceProvider).signOut();
      // La navegación será manejada por el authStateChangesProvider
    }
  }
}

// Helper Widgets

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.spacingXL),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Error al cargar',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección de gestión de entrenadores (solo admin)
class _TrainerManagementSection extends ConsumerStatefulWidget {
  final dynamic currentUser;

  const _TrainerManagementSection({required this.currentUser});

  @override
  ConsumerState<_TrainerManagementSection> createState() =>
      _TrainerManagementSectionState();
}

class _TrainerManagementSectionState
    extends ConsumerState<_TrainerManagementSection> {
  List<UserModel> _trainers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() => _isLoading = true);
    try {
      final trainers = await ref.read(firebaseServiceProvider).getTrainers();
      if (mounted) {
        setState(() {
          _trainers = trainers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar entrenadores: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y botón de agregar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Entrenadores del Gimnasio',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showAddTrainerDialog(),
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                tooltip: 'Agregar Entrenador',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: AppConstants.spacingM),

          // Lista de entrenadores
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacingL),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_trainers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Text(
                  'No hay entrenadores registrados',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trainers.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppConstants.spacingS),
              itemBuilder: (context, index) {
                final trainer = _trainers[index];
                return _buildTrainerItem(trainer);
              },
            ),

          // Botón para setup rápido de entrenadores predefinidos
          const SizedBox(height: AppConstants.spacingM),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: AppConstants.spacingM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _runQuickSetup,
              icon: const Icon(Icons.group_add, size: 18),
              label: const Text('Actualizar Entrenadores Predefinidos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerItem(UserModel trainer) {
    final isCurrentUser = trainer.uid == widget.currentUser.uid;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: trainer.photoUrl != null
                ? CachedNetworkImageProvider(trainer.photoUrl!)
                : null,
            child: trainer.photoUrl == null
                ? Text(
                    (trainer.nombre ?? 'E')[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppConstants.spacingM),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        trainer.nombre ?? 'Sin nombre',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge de rol
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: trainer.rol == UserRole.admin
                            ? AppColors.warning.withValues(alpha: 0.2)
                            : AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusRound,
                        ),
                      ),
                      child: Text(
                        trainer.rol == UserRole.admin ? 'Admin' : 'Entrenador',
                        style: TextStyle(
                          color: trainer.rol == UserRole.admin
                              ? AppColors.warning
                              : AppColors.info,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  trainer.email,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Botón eliminar (solo si no es el usuario actual)
          if (!isCurrentUser)
            IconButton(
              onPressed: () => _confirmDeleteTrainer(trainer),
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              tooltip: 'Eliminar acceso',
            ),
        ],
      ),
    );
  }

  Future<void> _showAddTrainerDialog() async {
    final emailController = TextEditingController();
    UserRole selectedRole = UserRole.entrenador;

    await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Agregar Entrenador',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email del usuario',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'usuario@ejemplo.com',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Rol',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UserRole>(
                    value: selectedRole,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceDark,
                    style: const TextStyle(color: AppColors.textPrimaryDark),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.entrenador,
                        child: Text('Entrenador'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un email'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                Navigator.pop(context, true);

                // Procesar fuera del diálogo
                await _addTrainer(email, selectedRole);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTrainer(String email, UserRole role) async {
    try {
      // Buscar usuario por email
      final user = await ref
          .read(firebaseServiceProvider)
          .getUserByEmail(email);

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario no encontrado'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Actualizar rol del usuario
      await ref.read(firebaseServiceProvider).updateUserRole(user.uid, role);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.nombre ?? user.email} ahora es ${role.displayName}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Recargar lista
      await _loadTrainers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar entrenador: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _runQuickSetup() async {
    final emails = [
      'arthurmg0604@gmail.com',
      'mactziaguilar717@gmail.com',
      'penichediego1@gmail.com',
      'penichealberto56@gmail.com',
      'diegopeniche.galindo25@gmail.com',
      'emilioah02@gmail.com',
    ];

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(width: 16),
            Text('Actualizando usuarios...', style: TextStyle(color: AppColors.textPrimaryDark)),
          ],
        ),
      ),
    );

    try {
      final results = await ref.read(firebaseServiceProvider).makeUsersTrainers(emails);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        // Mostrar resultados
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text('Resultados', style: TextStyle(color: AppColors.textPrimaryDark)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: results.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(
                      color: e.value.contains('Error') || e.value.contains('No encontrado')
                          ? AppColors.error
                          : AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadTrainers();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _confirmDeleteTrainer(UserModel trainer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Eliminar acceso de entrenador',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cambiar a ${trainer.nombre ?? trainer.email} a rol de cliente?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(firebaseServiceProvider)
            .updateUserRole(trainer.uid, UserRole.cliente);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${trainer.nombre ?? trainer.email} ahora es cliente',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // Recargar lista
        await _loadTrainers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar entrenador: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

/// Widget para agregar un nuevo entrenador por correo
class _AddTrainerCard extends ConsumerStatefulWidget {
  const _AddTrainerCard();

  @override
  ConsumerState<_AddTrainerCard> createState() => _AddTrainerCardState();
}

class _AddTrainerCardState extends ConsumerState<_AddTrainerCard> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addTrainer() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo electrónico'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo electrónico válido'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await ref
          .read(firebaseServiceProvider)
          .makeUsersTrainers([email]);

      final result = results[email] ?? 'Error desconocido';

      if (mounted) {
        final isSuccess = !result.contains('Error') && !result.contains('No encontrado');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSuccess
                  ? '$email ahora es entrenador'
                  : result,
            ),
            backgroundColor: isSuccess ? AppColors.success : AppColors.error,
          ),
        );

        if (isSuccess) {
          _emailController.clear();
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  'Agregar nuevo entrenador',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Ingresa el correo del usuario para convertirlo en entrenador',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'correo@ejemplo.com',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: const BorderSide(color: AppColors.success),
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondaryDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addTrainer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
