import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/widgets.dart';

/// Página para crear y enviar anuncios personalizados a clientes
class SendAnnouncementPage extends ConsumerStatefulWidget {
  const SendAnnouncementPage({super.key});

  @override
  ConsumerState<SendAnnouncementPage> createState() => _SendAnnouncementPageState();
}

class _SendAnnouncementPageState extends ConsumerState<SendAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();

  AnnouncementType _tipoSeleccionado = AnnouncementType.aviso;
  bool _enviarATodos = true;
  final Set<String> _clientesSeleccionados = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
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
          const SnackBar(
            content: Text('✅ Anuncio enviado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al enviar anuncio: $e'),
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
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Enviar Anuncio'),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            // Tipo de anuncio
            Text(
              'Tipo de Anuncio',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            _buildAnnouncementTypeSelector(),
            const SizedBox(height: AppConstants.spacingL),

            // Título
            Text(
              'Título',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            TextFormField(
              controller: _tituloController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Ej: ¡Oferta especial!',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.surfaceLight.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Mensaje
            Text(
              'Mensaje',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            TextFormField(
              controller: _mensajeController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje aquí...',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.surfaceLight.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un mensaje';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Destinatarios
            Text(
              'Destinatarios',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enviar a todos los clientes',
                      style: TextStyle(color: AppColors.textPrimaryDark),
                    ),
                    value: _enviarATodos,
                    onChanged: (value) {
                      setState(() {
                        _enviarATodos = value;
                        if (value) {
                          _clientesSeleccionados.clear();
                        }
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  if (!_enviarATodos) ...[
                    const Divider(color: AppColors.glassBorder),
                    clientsAsync.when(
                      data: (clients) {
                        if (clients.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.spacingM),
                            child: Text(
                              'No hay clientes disponibles',
                              style: TextStyle(color: AppColors.textSecondaryDark),
                            ),
                          );
                        }
                        return Column(
                          children: clients.map((client) {
                            final isSelected = _clientesSeleccionados.contains(client.uid);
                            return CheckboxListTile(
                              title: Text(
                                client.nombre ?? 'Cliente',
                                style: const TextStyle(color: AppColors.textPrimaryDark),
                              ),
                              subtitle: Text(
                                client.email ?? '',
                                style: const TextStyle(color: AppColors.textSecondaryDark),
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _clientesSeleccionados.add(client.uid);
                                  } else {
                                    _clientesSeleccionados.remove(client.uid);
                                  }
                                });
                              },
                              activeColor: AppColors.primary,
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(AppConstants.spacingM),
                        child: Center(child: CircularProgressIndicator()),
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
            const SizedBox(height: AppConstants.spacingXL),

            // Botón de enviar
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarAnuncio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.backgroundDark)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            'Enviar Anuncio',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.backgroundDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementTypeSelector() {
    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: AnnouncementType.values.map((type) {
        final isSelected = _tipoSeleccionado == type;
        return ChoiceChip(
          label: Text(_getTypeName(type)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _tipoSeleccionado = type);
          },
          selectedColor: _getTypeColor(type),
          backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.backgroundDark : AppColors.textPrimaryDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          avatar: Icon(
            _getTypeIcon(type),
            color: isSelected ? AppColors.backgroundDark : _getTypeColor(type),
            size: 20,
          ),
        );
      }).toList(),
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
        return 'Información';
    }
  }

  Color _getTypeColor(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return AppColors.success;
      case AnnouncementType.promocion:
        return AppColors.primary;
      case AnnouncementType.aviso:
        return AppColors.warning;
      case AnnouncementType.informacion:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.oferta:
        return Icons.local_offer;
      case AnnouncementType.promocion:
        return Icons.celebration;
      case AnnouncementType.aviso:
        return Icons.notifications_active;
      case AnnouncementType.informacion:
        return Icons.info;
    }
  }
}
