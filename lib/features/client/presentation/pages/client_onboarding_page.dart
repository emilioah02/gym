import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página de onboarding para nuevos clientes
/// Captura datos del usuario: nombre, edad, altura, peso, género
/// Calcula automáticamente el IMC y muestra el rango OMS
class ClientOnboardingPage extends ConsumerStatefulWidget {
  const ClientOnboardingPage({super.key});

  @override
  ConsumerState<ClientOnboardingPage> createState() => _ClientOnboardingPageState();
}

class _ClientOnboardingPageState extends ConsumerState<ClientOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();

  UserGender? _selectedGender;
  UserGoal? _selectedGoal;
  final List<int> _selectedDays = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Autocompletar el nombre con el nombre del usuario de Google
    _autofillUserName();
  }

  void _autofillUserName() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.displayName != null) {
      _nombreController.text = currentUser.displayName!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _edadController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  double? get _calculatedIMC {
    final altura = double.tryParse(_alturaController.text);
    final peso = double.tryParse(_pesoController.text);

    if (altura != null && peso != null && altura > 0) {
      return peso / (altura * altura);
    }
    return null;
  }

  IMCRange? get _imcRange {
    final imc = _calculatedIMC;
    if (imc == null) return null;

    if (imc < 18.5) return IMCRange.bajoPeso;
    if (imc < 25) return IMCRange.normal;
    if (imc < 30) return IMCRange.sobrepeso;
    return IMCRange.obesidad;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildWelcomePage(currentUser.valueOrNull),
                      _buildPersonalDataPage(),
                      _buildPhysicalDataPage(),
                      _buildGoalPage(),
                      _buildSchedulePage(),
                      _buildSummaryPage(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textSecondaryDark),
              onPressed: _previousPage,
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Configuración Inicial',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Page 0: Bienvenida
  Widget _buildWelcomePage(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spacingXL),
          // Avatar del usuario (de Google)
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: user?.photoUrl != null
                ? CachedNetworkImageProvider(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            '¡Bienvenido a\nMexican Bulking!',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Vamos a configurar tu perfil para\npersonalizar tu experiencia.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          GlassCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person,
                  title: 'Datos personales',
                  description: 'Nombre, edad y género',
                ),
                const Divider(color: AppColors.glassBorder),
                _InfoRow(
                  icon: Icons.monitor_weight,
                  title: 'Datos físicos',
                  description: 'Altura y peso para calcular tu IMC',
                ),
                const Divider(color: AppColors.glassBorder),
                _InfoRow(
                  icon: Icons.flag,
                  title: 'Tu objetivo',
                  description: 'Qué quieres lograr',
                ),
                const Divider(color: AppColors.glassBorder),
                _InfoRow(
                  icon: Icons.calendar_today,
                  title: 'Horario',
                  description: 'Días que entrenarás',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 1: Datos personales
  Widget _buildPersonalDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos Personales',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Cuéntanos un poco sobre ti',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Nombre
          Text('Nombre', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _nombreController,
              style: AppTypography.bodyLargeDark,
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Edad
          Text('Edad', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _edadController,
              style: AppTypography.bodyLargeDark,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '25',
                hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.cake, color: AppColors.primary),
                suffixText: 'años',
                suffixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Género
          Text('Género', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: AppConstants.spacingS),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  gender: UserGender.hombre,
                  icon: Icons.male,
                  color: Colors.blue,
                  isSelected: _selectedGender == UserGender.hombre,
                  onTap: () => setState(() => _selectedGender = UserGender.hombre),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: _GenderOption(
                  gender: UserGender.mujer,
                  icon: Icons.female,
                  color: Colors.pink,
                  isSelected: _selectedGender == UserGender.mujer,
                  onTap: () => setState(() => _selectedGender = UserGender.mujer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Page 2: Datos físicos
  Widget _buildPhysicalDataPage() {
    final imc = _calculatedIMC;
    final range = _imcRange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos Físicos',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Calcularemos tu IMC automáticamente',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Altura
          Text('Altura', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _alturaController,
              style: AppTypography.bodyLargeDark,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '1.75',
                hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.height, color: AppColors.primary),
                suffixText: 'm',
                suffixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Peso
          Text('Peso', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _pesoController,
              style: AppTypography.bodyLargeDark,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '70',
                hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: const Icon(Icons.monitor_weight, color: AppColors.primary),
                suffixText: 'kg',
                suffixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // IMC Card
          if (imc != null)
            GlassCard(
              child: Column(
                children: [
                  Text(
                    'Tu IMC',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    imc.toStringAsFixed(1),
                    style: AppTypography.displayMedium.copyWith(
                      color: _getIMCColor(range),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: _getIMCColor(range).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Text(
                      range?.displayName ?? '',
                      style: TextStyle(
                        color: _getIMCColor(range),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  // Escala visual
                  _buildIMCScale(imc),
                ],
              ),
            ),

          const SizedBox(height: AppConstants.spacingM),

          // Info OMS
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rangos según la OMS',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingM),
                _buildIMCRangeRow('Bajo peso', '< 18.5', AppColors.info),
                _buildIMCRangeRow('Normal', '18.5 - 24.9', AppColors.success),
                _buildIMCRangeRow('Sobrepeso', '25 - 29.9', AppColors.warning),
                _buildIMCRangeRow('Obesidad', '≥ 30', AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIMCScale(double imc) {
    // Normalizar el IMC a un rango de 0-1 (considerando IMC de 15 a 40)
    double position = ((imc - 15) / 25).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.info,
                    AppColors.success,
                    AppColors.warning,
                    AppColors.error,
                  ],
                  stops: [0.0, 0.35, 0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              left: position * (MediaQuery.of(context).size.width - 100) - 10,
              top: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.textPrimaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.backgroundDark, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
            Text('40', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildIMCRangeRow(String label, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Text(
            range,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // Page 3: Objetivo
  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cuál es tu objetivo?',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Personaliza tu experiencia según tus metas',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          ...UserGoal.values.map((goal) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: _GoalOption(
              goal: goal,
              isSelected: _selectedGoal == goal,
              onTap: () => setState(() => _selectedGoal = goal),
            ),
          )),
        ],
      ),
    );
  }

  // Page 4: Días de entrenamiento
  Widget _buildSchedulePage() {
    const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué días entrenarás?',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Selecciona los días que planeas entrenar (opcional)',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          ...List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDays.contains(dayNumber);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
              child: GlassCard(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(dayNumber);
                    } else {
                      _selectedDays.add(dayNumber);
                    }
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.glassDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.glassBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dayNames[index][0],
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        dayNames[index],
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSelected ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: AppConstants.animationFast,
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacingM),

          if (_selectedDays.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDays.length} días seleccionados',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Page 5: Resumen
  Widget _buildSummaryPage() {
    final imc = _calculatedIMC;
    final range = _imcRange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Todo listo!',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Revisa tu información antes de continuar',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Resumen de datos
          GlassCard(
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.person,
                  label: 'Nombre',
                  value: _nombreController.text.isNotEmpty ? _nombreController.text : '-',
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: Icons.cake,
                  label: 'Edad',
                  value: _edadController.text.isNotEmpty ? '${_edadController.text} años' : '-',
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: _selectedGender == UserGender.hombre ? Icons.male : Icons.female,
                  label: 'Género',
                  value: _selectedGender?.displayName ?? '-',
                  valueColor: _selectedGender == UserGender.hombre ? Colors.blue : Colors.pink,
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: Icons.height,
                  label: 'Altura',
                  value: _alturaController.text.isNotEmpty ? '${_alturaController.text} m' : '-',
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: Icons.monitor_weight,
                  label: 'Peso',
                  value: _pesoController.text.isNotEmpty ? '${_pesoController.text} kg' : '-',
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: Icons.calculate,
                  label: 'IMC',
                  value: imc != null ? '${imc.toStringAsFixed(1)} (${range?.displayName ?? ""})' : '-',
                  valueColor: _getIMCColor(range),
                ),
                const Divider(color: AppColors.glassBorder),
                _SummaryRow(
                  icon: Icons.flag,
                  label: 'Objetivo',
                  value: _selectedGoal?.displayName ?? '-',
                ),
                if (_selectedDays.isNotEmpty) ...[
                  const Divider(color: AppColors.glassBorder),
                  _SummaryRow(
                    icon: Icons.calendar_today,
                    label: 'Días',
                    value: '${_selectedDays.length} días/semana',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingL),

          // Nota
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Podrás actualizar esta información en cualquier momento desde tu perfil.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
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

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == 5;
    final canProceed = _canProceedFromCurrentPage();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondaryDark,
                  side: const BorderSide(color: AppColors.glassBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0)
            const SizedBox(width: AppConstants.spacingM),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: canProceed
                  ? (isLastPage ? _saveAndContinue : _nextPage)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                disabledBackgroundColor: AppColors.glassDark,
                disabledForegroundColor: AppColors.textSecondaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: Text(isLastPage ? 'Comenzar' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.backgroundDark.withValues(alpha: 0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Guardando...',
                style: TextStyle(color: AppColors.textPrimaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceedFromCurrentPage() {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _nombreController.text.isNotEmpty &&
            _edadController.text.isNotEmpty &&
            _selectedGender != null;
      case 2:
        return _alturaController.text.isNotEmpty &&
            _pesoController.text.isNotEmpty &&
            _calculatedIMC != null;
      case 3:
        return _selectedGoal != null;
      case 4:
        return true; // Días son opcionales
      case 5:
        return true;
      default:
        return true;
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveAndContinue() async {
    print('🚀 [DEBUG] _saveAndContinue() - INICIANDO');
    setState(() => _isLoading = true);

    try {
      print('📊 [DEBUG] Obteniendo firebaseService y currentUser...');
      final firebaseService = ref.read(firebaseServiceProvider);
      final currentUser = ref.read(userModelProvider).valueOrNull;

      print('👤 [DEBUG] Usuario actual: ${currentUser?.email}');
      print('👤 [DEBUG] Usuario es null: ${currentUser == null}');

      if (currentUser != null) {
        final peso = double.tryParse(_pesoController.text);
        final altura = double.tryParse(_alturaController.text);

        print('📝 [DEBUG] Datos a guardar:');
        print('   - Nombre: ${_nombreController.text}');
        print('   - Edad: ${_edadController.text}');
        print('   - Género: $_selectedGender');
        print('   - Altura: $altura');
        print('   - Peso: $peso');
        print('   - Objetivo: $_selectedGoal');
        print('   - Días: $_selectedDays');

        final updatedUser = currentUser.copyWith(
          nombre: _nombreController.text,
          edad: int.tryParse(_edadController.text),
          genero: _selectedGender,
          altura: altura,
          peso: peso,
          pesoInicial: peso,
          objetivo: _selectedGoal,
          diasEntrenamiento: _selectedDays.isEmpty ? null : _selectedDays,
          onboardingCompleto: true,
        );

        print('💾 [DEBUG] Guardando usuario en Firestore...');
        await firebaseService.saveUser(updatedUser);
        print('✅ [DEBUG] Usuario guardado exitosamente');

        // Refrescar el usuario
        print('🔄 [DEBUG] Invalidando userModelProvider...');
        ref.invalidate(userModelProvider);
        print('✅ [DEBUG] Provider invalidado');

        // Navegar al home usando GoRouter
        print('🧭 [DEBUG] Verificando mounted: $mounted');
        if (mounted) {
          print('🧭 [DEBUG] Intentando navegar a: ${AppRoutes.clientHome}');
          context.go(AppRoutes.clientHome);
          print('✅ [DEBUG] Navegación ejecutada (context.go llamado)');
        } else {
          print('❌ [DEBUG] Widget no está mounted, no se puede navegar');
        }
      } else {
        print('❌ [DEBUG] currentUser es null, no se puede guardar');
      }
    } catch (e, stackTrace) {
      print('❌ [DEBUG] ERROR en _saveAndContinue:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      print('🏁 [DEBUG] _saveAndContinue() - FINALIZANDO');
      if (mounted) {
        setState(() => _isLoading = false);
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
}

// Widget helpers

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
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
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final UserGender gender;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.gender,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? color : AppColors.textSecondaryDark),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              gender.displayName,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final UserGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (goal) {
      case UserGoal.bajarGrasa:
        return Icons.trending_down;
      case UserGoal.aumentarMusculo:
        return Icons.trending_up;
      case UserGoal.mantener:
        return Icons.trending_flat;
      case UserGoal.mejorarResistencia:
        return Icons.directions_run;
      case UserGoal.flexibilidad:
        return Icons.self_improvement;
    }
  }

  String get _description {
    switch (goal) {
      case UserGoal.bajarGrasa:
        return 'Reducir grasa corporal y definir';
      case UserGoal.aumentarMusculo:
        return 'Ganar masa muscular y fuerza';
      case UserGoal.mantener:
        return 'Mantener condición física actual';
      case UserGoal.mejorarResistencia:
        return 'Aumentar resistencia cardiovascular';
      case UserGoal.flexibilidad:
        return 'Mejorar movilidad y flexibilidad';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.glassDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.displayName,
                  style: AppTypography.titleSmall.copyWith(
                    color: isSelected ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  _description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: AppConstants.animationFast,
            child: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
              color: valueColor ?? AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
