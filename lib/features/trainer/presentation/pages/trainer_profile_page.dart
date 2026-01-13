import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
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
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingM,
              AppConstants.spacingS,
              AppConstants.spacingM,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Perfil',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Tu información y ajustes',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingS),
              ],
            ),
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
          const _ClientModeCard(),
          const SizedBox(height: AppConstants.spacingL),

          // Agregar Entrenador (solo para admins)
          if (user.rol == UserRole.admin) ...[
            _buildSectionTitle('Agregar Entrenador'),
            const SizedBox(height: AppConstants.spacingM),
            _AddTrainerCard(),
            const SizedBox(height: AppConstants.spacingL),
          ],

          // Lista de Entrenadores del Gimnasio (visible para todos los entrenadores)
          // Los admins pueden deslizar para eliminar
          _TrainersListSection(currentUser: user, isAdmin: user.rol == UserRole.admin),
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

          // Acerca de
          _buildSectionTitle('Acerca de'),
          const SizedBox(height: AppConstants.spacingM),
          _buildAboutSection(context),
          const SizedBox(height: AppConstants.spacingL),

          // Cerrar sesión
          _buildLogoutButton(context, ref),

          SizedBox(height: 100),
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
          onTap: () => context.push('/trainer/notification-settings'),
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
          onTap: () => context.push('/privacy-policy'),
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
    const String appName = 'Mexican Bulking';
    const String message =
        '''
¡Únete a $appName! 💪🏋️

La mejor app para gestionar tu entrenamiento en el gimnasio. Conecta con tu entrenador, sigue rutinas personalizadas y alcanza tus metas fitness.

📱 Descarga la app:
Android: https://play.google.com/store/apps/details?id=com.mexicanbulking.app
iOS: https://apps.apple.com/app/mexican-bulking/id123456789

¡Te esperamos en Mexican Bulking Gym!
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: message, subject: 'Únete a $appName'),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo compartir'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
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
      final results = await ref.read(firebaseServiceProvider).makeUsersTrainers(
        [email],
      );

      final result = results[email] ?? 'Error desconocido';

      if (mounted) {
        final isSuccess =
            !result.contains('Error') && !result.contains('No encontrado');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? '$email ahora es entrenador' : result),
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
                      borderSide: const BorderSide(
                        color: AppColors.glassBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: const BorderSide(
                        color: AppColors.glassBorder,
                      ),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _addTrainer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: const Size(48, 48),
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
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para el modo cliente
class _ClientModeCard extends ConsumerStatefulWidget {
  const _ClientModeCard();

  @override
  ConsumerState<_ClientModeCard> createState() => _ClientModeCardState();
}

/// Sección de lista de entrenadores del gimnasio (visible para todos los entrenadores)
class _TrainersListSection extends ConsumerStatefulWidget {
  final dynamic currentUser;
  final bool isAdmin;

  const _TrainersListSection({required this.currentUser, this.isAdmin = false});

  @override
  ConsumerState<_TrainersListSection> createState() =>
      _TrainersListSectionState();
}

class _TrainersListSectionState extends ConsumerState<_TrainersListSection> {
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
      }
    }
  }

  Future<void> _demoteToClient(UserModel trainer) async {
    try {
      await ref
          .read(firebaseServiceProvider)
          .updateUserRole(trainer.uid, UserRole.cliente);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${trainer.nombre ?? trainer.email} ahora es cliente. Puede volver a ser entrenador ingresando su correo.',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Recargar lista
      await _loadTrainers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar rol: $e'),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.groups,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrenadores del Gimnasio',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Equipo de entrenadores disponibles',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadTrainers,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Actualizar',
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _trainers.asMap().entries.map((entry) {
                final index = entry.key;
                final trainer = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _trainers.length - 1
                        ? AppConstants.spacingS
                        : 0,
                  ),
                  child: _buildTrainerItem(trainer),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainerItem(UserModel trainer) {
    final isCurrentUser = trainer.uid == widget.currentUser.uid;
    final canDismiss = widget.isAdmin && !isCurrentUser && trainer.rol != UserRole.admin;

    final itemContent = Container(
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
                Text(
                  trainer.nombre ?? 'Sin nombre',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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

          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trainer.rol == UserRole.admin
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Text(
              trainer.rol == UserRole.admin ? 'Admin' : 'Coach',
              style: TextStyle(
                color: trainer.rol == UserRole.admin
                    ? AppColors.warning
                    : AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Si puede eliminar, envolver en Dismissible
    if (canDismiss) {
      return Dismissible(
        key: Key(trainer.uid),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.person_remove, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Pasar a Cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              title: Text(
                'Cambiar a Cliente',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              content: Text(
                '¿Estás seguro de que deseas cambiar a ${trainer.nombre ?? trainer.email} de entrenador a cliente?\n\nPodrá volver a ser entrenador si ingresas su correo nuevamente.',
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
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => _demoteToClient(trainer),
        child: itemContent,
      );
    }

    return itemContent;
  }
}

class _ClientModeCardState extends ConsumerState<_ClientModeCard> {
  bool _isLoading = false;

  Future<void> _switchToClientMode() async {
    setState(() => _isLoading = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;

      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Verificar si ya existe un usuario de prueba para este entrenador
      final testUserId = '${currentUser.uid}_test_client';
      final existingTestUser = await firebaseService.getUser(testUserId);

      if (existingTestUser == null) {
        // Crear usuario de prueba solo la primera vez
        final testUser = UserModel(
          uid: testUserId,
          email: 'cliente.prueba.${currentUser.uid}@test.com',
          nombre: 'Cliente Prueba',
          rol: UserRole.cliente,
          onboardingCompleto: true,
          createdAt: DateTime.now(),
        );

        await firebaseService.saveUser(testUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario de prueba creado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      // IMPORTANTE: Limpiar caché de rol y modelo antes de cambiar de usuario
      // Esto evita que RoleGate use el rol cacheado del entrenador
      ref.read(cachedUserRoleProvider.notifier).state = null;
      ref.read(cachedUserModelProvider.notifier).state = null;

      // Configurar el ID de usuario activo al usuario de prueba
      ref.read(activeUserIdProvider.notifier).state = testUserId;

      // Invalidar providers para forzar recarga con el nuevo activeUserId
      ref.invalidate(userRoleProvider);
      ref.invalidate(userModelProvider);

      // Navegar al modo cliente
      if (mounted) {
        context.go('/client/home');
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
      onTap: _isLoading ? null : _switchToClientMode,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.info,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
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
}
