import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Home Page with recommended routines and quick navigation
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.displayName?.split(' ').first ?? 'Athlete';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildAppBar(userName, user),
              // Welcome section
              SliverToBoxAdapter(child: _buildWelcomeSection(userName)),
              // Quick actions
              SliverToBoxAdapter(child: _buildQuickActions()),
              // Recommended routines
              SliverToBoxAdapter(child: _buildRecommendedSection()),
              // Categories
              SliverToBoxAdapter(child: _buildCategoriesSection()),
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingXXL),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppColors.backgroundDark),
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
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(String userName, user) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppConstants.spacingM),
        child: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : null,
          child: user?.photoURL == null
              ? Text(
                  userName[0].toUpperCase(),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.backgroundDark,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mexican Bulking',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.textSecondaryDark),
          onPressed: () => _showLogoutDialog(),
        ),
        const SizedBox(width: AppConstants.spacingS),
      ],
    );
  }

  Widget _buildWelcomeSection(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buenos Días';
    } else if (hour < 17) {
      greeting = 'Buenas Tardes';
    } else {
      greeting = 'Buenas Noches';
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          Text(
            userName,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            "¡Vamos a darlo todo hoy!",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.fitness_center,
              label: 'Todas las Rutinas',
              color: AppColors.primary,
              onTap: () => context.go(AppRoutes.routines),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.male,
              label: 'Hombres',
              color: Colors.blue,
              onTap: () => context.go('${AppRoutes.routines}?gender=men'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.female,
              label: 'Mujeres',
              color: Colors.pink,
              onTap: () => context.go('${AppRoutes.routines}?gender=women'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommendedRoutines = [
      {
        'title': 'Fuerza Cuerpo Completo',
        'subtitle': 'Desarrolla masa muscular general',
        'exercises': 12,
        'duration': '45 min',
      },
      {
        'title': 'Enfoque Tren Superior',
        'subtitle': 'Pecho, espalda, hombros y brazos',
        'exercises': 10,
        'duration': '40 min',
      },
      {
        'title': 'Día de Pierna Intenso',
        'subtitle': 'Cuádriceps, isquiotibiales y glúteos',
        'exercises': 8,
        'duration': '35 min',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spacingXL),
        SectionHeader(
          title: 'Recomendados',
          actionText: 'Ver Todo',
          actionIcon: Icons.arrow_forward_ios,
          onActionTap: () => context.go(AppRoutes.routines),
        ),
        const SizedBox(height: AppConstants.spacingM),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
            ),
            itemCount: recommendedRoutines.length,
            itemBuilder: (context, index) {
              final routine = recommendedRoutines[index];
              return Container(
                width: 240,
                margin: EdgeInsets.only(
                  right: index < recommendedRoutines.length - 1
                      ? AppConstants.spacingM
                      : 0,
                ),
                child: RoutineTile(
                  title: routine['title'] as String,
                  subtitle: routine['subtitle'] as String,
                  exerciseCount: routine['exercises'] as int,
                  duration: routine['duration'] as String,
                  onTap: () => context.go('/routines/routine_$index'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'icon': Icons.speed, 'title': 'Cardio', 'count': 5},
      {'icon': Icons.fitness_center, 'title': 'Fuerza', 'count': 15},
      {'icon': Icons.accessibility_new, 'title': 'Flexibilidad', 'count': 4},
      {'icon': Icons.local_fire_department, 'title': 'HIIT', 'count': 6},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spacingXL),
        const SectionHeader(title: 'Categorías'),
        const SizedBox(height: AppConstants.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.spacingM,
              crossAxisSpacing: AppConstants.spacingM,
              childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GlassCard(
                onTap: () => context.go(AppRoutes.routines),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      category['title'] as String,
                      style: AppTypography.titleMediumDark,
                    ),
                    Text(
                      '${category['count']} máquinas',
                      style: AppTypography.bodySmallDark,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text('Cerrar Sesión', style: AppTypography.titleLargeDark),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: AppTypography.bodyMediumDark,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = GoRouter.of(context);
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              navigator.go(AppRoutes.landing);
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingM,
        horizontal: AppConstants.spacingS,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
