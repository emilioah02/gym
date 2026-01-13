import '../../../core/models/machine_model.dart';

/// ============================================================================
/// INVENTARIO COMPLETO DE MÁQUINAS DEL GIMNASIO
/// ============================================================================
///
/// Este archivo contiene el inventario base de todas las máquinas disponibles.
/// Organizado en las siguientes categorías:
///
/// 1. MÁQUINAS GUIADAS - Equipamiento con movimiento guiado por rieles/cables
/// 2. PESO LIBRE - Mancuernas, barras, discos y racks
/// 3. FUNCIONAL - Equipamiento para entrenamiento funcional
/// 4. CARDIO - Equipamiento cardiovascular
///
/// Convenciones de ID:
/// - Máquinas guiadas: nombre_descriptivo (ej: chest_press_horizontal)
/// - Peso libre: tipo_peso_variante (ej: mancuerna_5kg)
/// - Barras: barra_tipo (ej: barra_olimpica)
/// - Discos: disco_peso (ej: disco_20kg)
///
/// Cada máquina incluye:
/// - Grupos musculares principales y secundarios
/// - Imagen local asociada (cuando disponible)
/// - Tips y errores comunes para uso correcto
/// ============================================================================

class MachinesData {
  MachinesData._();

  /// Ruta base para imágenes de máquinas
  static const String _basePath = 'assets/images/maquinas/';

  static const List<MachineModel> allMachines = [
    // =========================================================================
    // SECCIÓN 1: MÁQUINAS DE PIERNA (13)
    // =========================================================================

    // Prensa 45 grados
    MachineModel(
      id: 'prensa_45_grados',
      nombre: 'Prensa 45 Grados',
      descripcion: 'Prensa de piernas inclinada a 45 grados. Permite trabajar cuádriceps, glúteos e isquiotibiales con alta carga y menor estrés lumbar.',
      imageUrl: '${_basePath}Prensa 45 grados.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.pantorrillas],
      tips: [
        'Coloca los pies a la anchura de los hombros',
        'No bloquees completamente las rodillas en la extensión',
        'Mantén la espalda baja pegada al respaldo',
        'Baja hasta que las rodillas formen 90 grados',
      ],
      erroresComunes: [
        'Despegar la espalda baja del asiento',
        'Bloquear las rodillas completamente',
        'Colocar los pies demasiado arriba o abajo',
        'Usar excesivo peso sin control',
      ],
    ),

    // Sentadilla Hack
    MachineModel(
      id: 'hack_squat',
      nombre: 'Sentadilla Hack',
      descripcion: 'Máquina de sentadilla guiada que enfatiza el trabajo de cuádriceps con soporte para la espalda.',
      imageUrl: '${_basePath}Sentadilla Hack.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      tips: [
        'Mantén los hombros firmes contra los soportes',
        'Posición de pies baja para más cuádriceps',
        'Posición alta para más glúteos',
        'Control total en la bajada',
      ],
      erroresComunes: [
        'Dejar que las rodillas colapsen hacia adentro',
        'No bajar lo suficiente',
        'Despegar los talones de la plataforma',
      ],
    ),

    // Sentadilla Péndulo
    MachineModel(
      id: 'sentadilla_pendulo',
      nombre: 'Sentadilla Péndulo',
      descripcion: 'Máquina de sentadilla con movimiento pendular que reduce el estrés en las rodillas y enfatiza glúteos.',
      imageUrl: '${_basePath}Sentadilla péndulo.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      tips: [
        'Ajusta la altura del asiento correctamente',
        'Empuja principalmente con los talones',
        'Mantén el core activado durante todo el movimiento',
      ],
      erroresComunes: [
        'Usar impulso en lugar de control',
        'No ajustar correctamente el asiento',
      ],
    ),

    // Sentadilla Sissy
    MachineModel(
      id: 'sentadilla_sissy',
      nombre: 'Sentadilla Sissy',
      descripcion: 'Banco especializado para sentadilla sissy que aisla intensamente los cuádriceps con extensión completa.',
      imageUrl: '${_basePath}Sentadilla sissy.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.flexoresCadera],
      tips: [
        'Comienza sin peso para dominar la técnica',
        'Mantén la cadera extendida durante todo el movimiento',
        'Baja lentamente controlando la tensión',
      ],
      erroresComunes: [
        'Flexionar la cadera en lugar de mantenerla extendida',
        'Usar demasiado peso antes de dominar la técnica',
        'Movimiento brusco sin control',
      ],
    ),

    // Sentadilla Smith
    MachineModel(
      id: 'smith_machine',
      nombre: 'Sentadilla en Smith',
      descripcion: 'Barra guiada en rieles de acero para sentadillas controladas. Versátil para múltiples ejercicios.',
      imageUrl: '${_basePath}Sentadilla en smith.jpeg',
      categoria: MachineCategory.pierna,
      categoriaSecundaria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
      tips: [
        'Coloca los pies ligeramente adelante de la barra',
        'Usa los seguros de seguridad siempre',
        'Varía la posición de los pies para diferentes énfasis',
      ],
      erroresComunes: [
        'Pies directamente debajo de la barra',
        'No usar los seguros de seguridad',
        'Redondear la espalda baja',
      ],
    ),

    // Sentadilla Libre (Rack)
    MachineModel(
      id: 'squat_rack',
      nombre: 'Rack de Sentadilla Libre',
      descripcion: 'Estructura para sentadillas con barra libre. Ejercicio fundamental para desarrollo de fuerza integral.',
      imageUrl: '${_basePath}Sentadilla libre.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 8,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.core, MuscleGroup.erectoresEspinales],
      tips: [
        'Ajusta la barra a la altura de los hombros',
        'Mantén el pecho arriba y la mirada al frente',
        'Rodillas siguiendo la dirección de los pies',
        'Activa el core antes de iniciar cada repetición',
      ],
      erroresComunes: [
        'Rodillas colapsando hacia adentro',
        'Inclinarse demasiado hacia adelante',
        'No alcanzar profundidad adecuada',
        'Talones despegándose del suelo',
      ],
    ),

    // Extensión de Cuádriceps
    MachineModel(
      id: 'extension_cuadriceps',
      nombre: 'Extensión de Cuádriceps',
      descripcion: 'Máquina de aislamiento para cuádriceps mediante extensión de rodilla. Ideal para definición y rehabilitación.',
      imageUrl: '${_basePath}Extensión para cuádriceps.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [],
      tips: [
        'Ajusta el respaldo para que las rodillas queden alineadas con el eje',
        'Extiende completamente sin hiperextender',
        'Contrae isométricamente arriba por 1-2 segundos',
        'Baja controladamente',
      ],
      erroresComunes: [
        'Usar impulso para levantar el peso',
        'Rodillas no alineadas con el eje de rotación',
        'Movimiento parcial sin extensión completa',
      ],
    ),

    // Femoral Sentado
    MachineModel(
      id: 'femoral_sentado',
      nombre: 'Femoral Sentado',
      descripcion: 'Curl de piernas sentado para aislar isquiotibiales. Posición cómoda y segura.',
      imageUrl: '${_basePath}Femoral sentado.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas],
      tips: [
        'Ajusta el rodillo justo encima de los talones',
        'Mantén la espalda pegada al respaldo',
        'Flexiona completamente las rodillas',
        'Controla la fase excéntrica',
      ],
      erroresComunes: [
        'Levantar los glúteos del asiento',
        'Movimiento incompleto',
        'Usar demasiado peso perdiendo el control',
      ],
    ),

    // Femoral Acostado
    MachineModel(
      id: 'femoral_acostado',
      nombre: 'Femoral Acostado',
      descripcion: 'Curl de piernas acostado boca abajo. Mayor aislamiento de isquiotibiales.',
      imageUrl: '${_basePath}Femoral acostado.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.gluteos],
      tips: [
        'Rodillas justo fuera del borde del banco',
        'Caderas pegadas al banco durante todo el movimiento',
        'Aprieta los glúteos para estabilizar',
      ],
      erroresComunes: [
        'Levantar las caderas del banco',
        'No completar el rango de movimiento',
        'Usar impulso con la espalda',
      ],
    ),

    // Abductor
    MachineModel(
      id: 'abductor_machine',
      nombre: 'Máquina Abductora',
      descripcion: 'Trabaja los músculos abductores (parte externa del muslo) mediante apertura de piernas.',
      imageUrl: '${_basePath}Abducción.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.abductores, MuscleGroup.gluteos],
      musculosSecundarios: [],
      tips: [
        'Mantén la espalda recta contra el respaldo',
        'Abre las piernas de forma controlada',
        'Sostén la contracción máxima 1-2 segundos',
        'Regresa lentamente a la posición inicial',
      ],
      erroresComunes: [
        'Usar impulso para abrir las piernas',
        'Inclinarse hacia adelante',
        'Rango de movimiento incompleto',
      ],
    ),

    // Aductor
    MachineModel(
      id: 'aductor_machine',
      nombre: 'Máquina Aductora',
      descripcion: 'Trabaja los músculos aductores (parte interna del muslo) mediante cierre de piernas.',
      imageUrl: '${_basePath}Aductor.jpeg',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.aductores],
      musculosSecundarios: [],
      tips: [
        'Comienza con las piernas abiertas cómodamente',
        'Junta las piernas de forma controlada',
        'Aprieta al final del movimiento',
        'No dejes que el peso caiga en la vuelta',
      ],
      erroresComunes: [
        'Cerrar las piernas con impulso',
        'No controlar la fase de apertura',
        'Tensar el cuello y los hombros',
      ],
    ),

    // Máquina de Glúteos (Patada)
    MachineModel(
      id: 'glute_kickback',
      nombre: 'Máquina Patada de Glúteo',
      descripcion: 'Máquina especializada para aislar glúteos mediante extensión de cadera.',
      imageUrl: '${_basePath}Máquina patada para glúteo.jpeg',
      categoria: MachineCategory.pierna,
      categoriaSecundaria: MachineCategory.core,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      tips: [
        'Mantén el core activado durante todo el movimiento',
        'Empuja con el talón, no con la punta del pie',
        'Evita arquear excesivamente la espalda baja',
        'Contrae el glúteo en la posición final',
      ],
      erroresComunes: [
        'Arquear la espalda para levantar más peso',
        'Usar impulso en lugar de contracción muscular',
        'No completar la extensión de cadera',
      ],
    ),

    // Costurera para Pantorrillas
    MachineModel(
      id: 'calf_raise_seated',
      nombre: 'Costurera para Pantorrillas',
      descripcion: 'Máquina para elevación de talones sentado. Aisla los músculos de la pantorrilla (sóleo y gastrocnemio).',
      categoria: MachineCategory.pierna,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.pantorrillas],
      musculosSecundarios: [],
      tips: [
        'Coloca las rodillas directamente debajo de los soportes',
        'Baja los talones lo máximo posible para estirar',
        'Sube hasta contraer completamente la pantorrilla',
        'Mantén un ritmo controlado sin rebotes',
      ],
      erroresComunes: [
        'Rebotar en la parte baja del movimiento',
        'No completar el rango de movimiento',
        'Usar demasiado peso sacrificando la forma',
      ],
    ),

    // =========================================================================
    // SECCIÓN 2: MÁQUINAS DE PECHO (7)
    // =========================================================================

    // Press de Pecho Horizontal
    MachineModel(
      id: 'chest_press_horizontal',
      nombre: 'Press de Pecho Horizontal',
      descripcion: 'Press de pecho con movimiento horizontal guiado. Trabaja el pectoral medio de forma segura.',
      imageUrl: '${_basePath}Press de pecho horizontal.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      tips: [
        'Ajusta el asiento para que los agarres queden a la altura del pecho',
        'Mantén los omóplatos retraídos',
        'Empuja hasta extensión completa sin bloquear codos',
        'Controla el peso en la bajada',
      ],
      erroresComunes: [
        'Asiento demasiado alto o bajo',
        'Arquear excesivamente la espalda',
        'Bloquear los codos en la extensión',
      ],
    ),

    // Press de Pecho Inclinado
    MachineModel(
      id: 'chest_press_incline',
      nombre: 'Press de Pecho Inclinado',
      descripcion: 'Press inclinado que enfatiza el desarrollo del pectoral superior.',
      imageUrl: '${_basePath}Press de pecho inclinado.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      tips: [
        'El ángulo inclinado trabaja más el pectoral superior',
        'Mantén los pies firmes en el suelo',
        'Exhala al empujar, inhala al bajar',
      ],
      erroresComunes: [
        'Levantar los glúteos del asiento',
        'Dejar caer el peso rápidamente',
        'Agarre demasiado ancho o estrecho',
      ],
    ),

    // Press de Pecho Declinado
    MachineModel(
      id: 'chest_press_decline',
      nombre: 'Press de Pecho Declinado',
      descripcion: 'Press declinado que enfatiza el desarrollo del pectoral inferior.',
      imageUrl: '${_basePath}Press de pecho declinado.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      tips: [
        'Ideal para desarrollar la parte baja del pecho',
        'Mantén la espalda pegada al respaldo',
        'Movimiento controlado en ambas fases',
      ],
      erroresComunes: [
        'Dejar que los codos bajen demasiado',
        'Perder la retracción escapular',
      ],
    ),

    // Press de Pecho Hammer
    MachineModel(
      id: 'chest_press_hammer',
      nombre: 'Press de Pecho Hammer',
      descripcion: 'Press de pecho tipo Hammer con brazos independientes para trabajo unilateral.',
      imageUrl: '${_basePath}Press de pecho hammer.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      tips: [
        'Los brazos independientes permiten corregir desequilibrios',
        'Puedes trabajar un lado a la vez',
        'Movimiento más natural que máquinas con barra fija',
      ],
      erroresComunes: [
        'Empujar más con un brazo que con otro',
        'No mantener la simetría del movimiento',
      ],
    ),

    // Press de Pecho Peso Integrado
    MachineModel(
      id: 'chest_press_integrated',
      nombre: 'Press de Pecho Peso Integrado',
      descripcion: 'Máquina de press con sistema de peso integrado. Fácil ajuste de carga.',
      imageUrl: '${_basePath}Press de pecho peso integrado.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      tips: [
        'Ideal para principiantes por su facilidad de uso',
        'Ajuste rápido de peso con selector',
        'Movimiento guiado y seguro',
      ],
      erroresComunes: [
        'Seleccionar peso excesivo sin control',
        'Movimiento demasiado rápido',
      ],
    ),

    // Pec Fly / Pec Deck
    MachineModel(
      id: 'pec_fly',
      nombre: 'Pec Fly / Contractora',
      descripcion: 'Máquina para aperturas de pecho. Aisla el pectoral mediante aducción horizontal.',
      imageUrl: '${_basePath}Peck fly.jpeg',
      categoria: MachineCategory.pecho,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.pectoralMenor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior],
      tips: [
        'Mantén un ligero doblez en los codos',
        'Junta los brazos con control, no con impulso',
        'Aprieta el pecho en la contracción máxima',
        'No dejes que los brazos se abran más allá de los hombros',
      ],
      erroresComunes: [
        'Brazos completamente extendidos (riesgo de lesión)',
        'Apertura excesiva que estresa los hombros',
        'Usar impulso del cuerpo',
      ],
    ),

    // Cross Over / Cruce de Cables
    MachineModel(
      id: 'cable_crossover',
      nombre: 'Cross Over / Cruce de Cables',
      descripcion: 'Estación de poleas para cruces de pecho con tensión constante. Muy versátil.',
      imageUrl: '${_basePath}Cross Over.jpeg',
      categoria: MachineCategory.pecho,
      categoriaSecundaria: MachineCategory.brazo,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior, MuscleGroup.biceps],
      tips: [
        'Da un paso adelante para mayor estabilidad',
        'Mantén el torso ligeramente inclinado',
        'Cruza las manos en la posición final',
        'Ajusta la altura de las poleas según el énfasis deseado',
      ],
      erroresComunes: [
        'Usar demasiado peso perdiendo la forma',
        'No cruzar las manos lo suficiente',
        'Movimiento descontrolado',
      ],
    ),

    // =========================================================================
    // SECCIÓN 3: MÁQUINAS DE ESPALDA (3)
    // =========================================================================

    // Jalón Hammer para Espalda
    MachineModel(
      id: 'lat_pulldown_hammer',
      nombre: 'Jalón Hammer para Espalda',
      descripcion: 'Máquina de jalón tipo Hammer con brazos independientes. Excelente para dorsales.',
      imageUrl: '${_basePath}Jalón hammer para espalda.jpeg',
      categoria: MachineCategory.espalda,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.dorsales],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.romboides, MuscleGroup.trapecios],
      tips: [
        'Inicia el movimiento retrayendo los omóplatos',
        'Tira hacia abajo llevando los codos hacia las costillas',
        'Mantén el pecho elevado durante todo el movimiento',
        'Controla la subida del peso',
      ],
      erroresComunes: [
        'Tirar solo con los brazos sin activar la espalda',
        'Inclinarse demasiado hacia atrás',
        'Movimiento incompleto',
      ],
    ),

    // Máquina de Remo para Espalda
    MachineModel(
      id: 'seated_row_machine',
      nombre: 'Máquina de Remo para Espalda',
      descripcion: 'Remo sentado con soporte de pecho para aislamiento de espalda media y dorsales.',
      imageUrl: '${_basePath}Máquina de remo para espalda.jpeg',
      categoria: MachineCategory.espalda,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.trapecios],
      tips: [
        'Mantén el pecho contra el soporte',
        'Junta los omóplatos al final del tirón',
        'Codos cerca del cuerpo',
        'Extensión completa de brazos al inicio',
      ],
      erroresComunes: [
        'Separarse del soporte de pecho',
        'No completar el rango de movimiento',
        'Usar impulso del cuerpo',
      ],
    ),

    // Hiperextensión
    MachineModel(
      id: 'hyperextension',
      nombre: 'Banco de Hiperextensión',
      descripcion: 'Banco para extensiones de espalda baja. Fortalece erectores espinales y glúteos.',
      imageUrl: '${_basePath}Híper extensión.jpeg',
      categoria: MachineCategory.espalda,
      categoriaSecundaria: MachineCategory.core,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.erectoresEspinales],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      tips: [
        'Ajusta el soporte a la altura de la cadera',
        'Baja hasta que el torso esté perpendicular al suelo',
        'Sube hasta la línea del cuerpo, no más',
        'Mantén la mirada neutral, no hacia arriba',
      ],
      erroresComunes: [
        'Hiperextender la espalda (subir demasiado)',
        'Usar impulso para subir',
        'Colocar las manos detrás de la nuca tensando el cuello',
      ],
    ),

    // =========================================================================
    // SECCIÓN 4: MÁQUINAS DE HOMBRO (2)
    // =========================================================================

    // Press de Hombro Hammer
    MachineModel(
      id: 'shoulder_press_hammer',
      nombre: 'Press de Hombro Hammer',
      descripcion: 'Press de hombros tipo Hammer con movimiento convergente. Trabaja deltoides de forma segura.',
      imageUrl: '${_basePath}Press de hombro Hammer.jpeg',
      categoria: MachineCategory.hombro,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 4,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.trapecios],
      tips: [
        'Ajusta el asiento para que los agarres inicien a nivel de los hombros',
        'Empuja hacia arriba sin bloquear los codos',
        'Mantén el core activado',
        'Baja controladamente hasta la posición inicial',
      ],
      erroresComunes: [
        'Arquear la espalda excesivamente',
        'Bloquear los codos en la extensión',
        'Asiento mal ajustado',
      ],
    ),

    // Laterales en Máquina
    MachineModel(
      id: 'lateral_raise_machine',
      nombre: 'Elevaciones Laterales en Máquina',
      descripcion: 'Máquina para elevaciones laterales guiadas. Aisla el deltoides lateral.',
      imageUrl: '${_basePath}Laterales en máquina.jpeg',
      categoria: MachineCategory.hombro,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.trapecios],
      tips: [
        'Codos ligeramente doblados durante todo el movimiento',
        'Eleva hasta la altura de los hombros, no más',
        'Controla la bajada, no dejes caer el peso',
        'Mantén los hombros abajo, no los subas hacia las orejas',
      ],
      erroresComunes: [
        'Elevar los hombros (usar trapecio en lugar de deltoides)',
        'Subir más allá de la línea de los hombros',
        'Usar impulso del cuerpo',
      ],
    ),

    // =========================================================================
    // SECCIÓN 5: MÁQUINAS DE BRAZO (1)
    // =========================================================================

    // Curl Predicador Máquina
    MachineModel(
      id: 'preacher_curl_machine',
      nombre: 'Curl Predicador en Máquina',
      descripcion: 'Curl de bíceps con soporte tipo predicador. Aislamiento total del bíceps.',
      imageUrl: '${_basePath}Curl predicador máquina.jpeg',
      categoria: MachineCategory.brazo,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      tips: [
        'Ajusta el asiento para que los brazos descansen completamente en el soporte',
        'Mantén los codos fijos durante todo el movimiento',
        'Flexiona hasta contracción máxima',
        'Baja controladamente sin extender completamente',
      ],
      erroresComunes: [
        'Despegar los codos del soporte',
        'Extender completamente los brazos (riesgo de lesión)',
        'Usar impulso del cuerpo',
      ],
    ),

    // =========================================================================
    // SECCIÓN 6: PESO LIBRE - MANCUERNAS (10 rangos de peso)
    // =========================================================================

    MachineModel(
      id: 'mancuerna_2_5kg',
      nombre: 'Mancuernas 2.5 kg',
      descripcion: 'Par de mancuernas de 2.5 kg. Ideal para principiantes, calentamiento y ejercicios de aislamiento.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [],
      musculosSecundarios: [],
      tips: [
        'Perfectas para rehabilitación y calentamiento',
        'Ideales para elevaciones laterales ligeras',
      ],
    ),

    MachineModel(
      id: 'mancuerna_5kg',
      nombre: 'Mancuernas 5 kg',
      descripcion: 'Par de mancuernas de 5 kg. Versátiles para múltiples ejercicios de tren superior.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_7_5kg',
      nombre: 'Mancuernas 7.5 kg',
      descripcion: 'Par de mancuernas de 7.5 kg. Peso intermedio para progresión.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_10kg',
      nombre: 'Mancuernas 10 kg',
      descripcion: 'Par de mancuernas de 10 kg. Peso estándar para ejercicios de fuerza moderada.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_12_5kg',
      nombre: 'Mancuernas 12.5 kg',
      descripcion: 'Par de mancuernas de 12.5 kg. Peso intermedio-avanzado.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_15kg',
      nombre: 'Mancuernas 15 kg',
      descripcion: 'Par de mancuernas de 15 kg. Para ejercicios compuestos y usuarios intermedios.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 10,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_17_5kg',
      nombre: 'Mancuernas 17.5 kg',
      descripcion: 'Par de mancuernas de 17.5 kg. Peso avanzado para press y remos.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 8,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_20kg',
      nombre: 'Mancuernas 20 kg',
      descripcion: 'Par de mancuernas de 20 kg. Peso pesado para usuarios avanzados.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 4,
      defaultReps: 8,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_25kg',
      nombre: 'Mancuernas 25 kg',
      descripcion: 'Par de mancuernas de 25 kg. Peso muy pesado para press y remos pesados.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 4,
      defaultReps: 6,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'mancuerna_30kg',
      nombre: 'Mancuernas 30 kg',
      descripcion: 'Par de mancuernas de 30 kg. Peso máximo para usuarios muy avanzados.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 4,
      defaultReps: 6,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    // =========================================================================
    // SECCIÓN 7: PESO LIBRE - BARRAS (4 tipos)
    // =========================================================================

    MachineModel(
      id: 'barra_olimpica',
      nombre: 'Barra Olímpica (20 kg)',
      descripcion: 'Barra olímpica estándar de 20 kg y 2.2 metros. Base para ejercicios compuestos principales.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 8,
      musculosPrincipales: [],
      musculosSecundarios: [],
      tips: [
        'Agarre prono estándar a la anchura de los hombros',
        'Verificar que los seguros estén bien colocados',
        'Usar collarines para asegurar los discos',
      ],
      erroresComunes: [
        'No usar collarines de seguridad',
        'Agarre desbalanceado',
      ],
    ),

    MachineModel(
      id: 'barra_z',
      nombre: 'Barra Z / EZ Curl',
      descripcion: 'Barra curva tipo Z para curl de bíceps y extensiones de tríceps. Reduce estrés en muñecas.',
      categoria: MachineCategory.brazo,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.biceps, MuscleGroup.triceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      tips: [
        'La curvatura reduce el estrés en las muñecas',
        'Ideal para curl y extensiones de tríceps',
        'Agarre en la curva interna para bíceps',
        'Agarre en la curva externa para tríceps',
      ],
    ),

    MachineModel(
      id: 'barra_recta_corta',
      nombre: 'Barra Recta Corta',
      descripcion: 'Barra recta corta de aproximadamente 1.2 metros. Útil para ejercicios de aislamiento.',
      categoria: MachineCategory.brazo,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
    ),

    MachineModel(
      id: 'barra_hexagonal',
      nombre: 'Barra Hexagonal / Trap Bar',
      descripcion: 'Barra hexagonal para peso muerto y encogimientos. Posición más natural y menos estrés lumbar.',
      categoria: MachineCategory.espalda,
      categoriaSecundaria: MachineCategory.pierna,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 4,
      defaultReps: 8,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos, MuscleGroup.trapecios],
      musculosSecundarios: [MuscleGroup.erectoresEspinales, MuscleGroup.antebrazos],
      tips: [
        'El cuerpo queda dentro del hexágono',
        'Agarre neutral (palmas mirándose)',
        'Menor estrés en la espalda baja que peso muerto convencional',
      ],
    ),

    // =========================================================================
    // SECCIÓN 8: PESO LIBRE - DISCOS (8 pesos)
    // =========================================================================

    MachineModel(
      id: 'disco_1_25kg',
      nombre: 'Discos 1.25 kg (Par)',
      descripcion: 'Par de discos de 1.25 kg cada uno. Para microcargas y progresión gradual.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_2_5kg',
      nombre: 'Discos 2.5 kg (Par)',
      descripcion: 'Par de discos de 2.5 kg cada uno. Incremento estándar mínimo.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_5kg',
      nombre: 'Discos 5 kg (Par)',
      descripcion: 'Par de discos de 5 kg cada uno. Incremento estándar para progresión.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_10kg',
      nombre: 'Discos 10 kg (Par)',
      descripcion: 'Par de discos de 10 kg cada uno. Peso medio para cargas moderadas.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_15kg',
      nombre: 'Discos 15 kg (Par)',
      descripcion: 'Par de discos de 15 kg cada uno. Peso intermedio-alto.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_20kg',
      nombre: 'Discos 20 kg (Par)',
      descripcion: 'Par de discos de 20 kg cada uno. Discos olímpicos estándar grandes.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'disco_25kg',
      nombre: 'Discos 25 kg (Par)',
      descripcion: 'Par de discos de 25 kg cada uno. Peso pesado para levantamientos avanzados.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.avanzado,
      defaultSets: 1,
      defaultReps: 1,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    // =========================================================================
    // SECCIÓN 9: CARDIO (5)
    // =========================================================================

    MachineModel(
      id: 'treadmill',
      nombre: 'Caminadora',
      descripcion: 'Banda motorizada para caminar, trotar o correr en interiores. Ideal para cardio y calentamiento.',
      categoria: MachineCategory.cardio,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 20,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.isquiotibiales, MuscleGroup.pantorrillas],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.core],
    ),

    MachineModel(
      id: 'stationary_bike',
      nombre: 'Bicicleta Estática',
      descripcion: 'Máquina de ciclismo para cardio de bajo impacto. Resistencia ajustable.',
      categoria: MachineCategory.cardio,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.gluteos],
    ),

    MachineModel(
      id: 'elliptical',
      nombre: 'Elíptica',
      descripcion: 'Máquina de cardio de bajo impacto que simula caminar, correr o subir escaleras.',
      categoria: MachineCategory.cardio,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.principiante,
      defaultSets: 1,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
    ),

    MachineModel(
      id: 'rowing_machine',
      nombre: 'Máquina de Remo Cardio',
      descripcion: 'Cardio de cuerpo completo simulando remo. Trabaja piernas, core y tren superior.',
      categoria: MachineCategory.cardio,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.core, MuscleGroup.gluteos],
    ),

    MachineModel(
      id: 'step_stepper',
      nombre: 'Escaladora',
      descripcion: 'Simula subir escaleras para cardio y tonificación del tren inferior.',
      categoria: MachineCategory.cardio,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 1,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.isquiotibiales],
    ),

    // =========================================================================
    // SECCIÓN 10: FUNCIONAL (6)
    // =========================================================================

    MachineModel(
      id: 'battle_ropes',
      nombre: 'Cuerdas de Batalla',
      descripcion: 'Cuerdas pesadas para acondicionamiento de alta intensidad. Trabaja todo el cuerpo.',
      categoria: MachineCategory.functional,
      tipo: MachineType.funcional,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 30,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.core],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.triceps, MuscleGroup.antebrazos],
    ),

    MachineModel(
      id: 'kettlebell_station',
      nombre: 'Estación de Kettlebells',
      descripcion: 'Rack con kettlebells de varios pesos para swings, cleans y press.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 15,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.core],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.deltoidesAnterior],
    ),

    MachineModel(
      id: 'trx_suspension',
      nombre: 'TRX Suspensión',
      descripcion: 'Sistema de entrenamiento con peso corporal usando correas de suspensión.',
      categoria: MachineCategory.functional,
      tipo: MachineType.funcional,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [MuscleGroup.core],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'plyo_box',
      nombre: 'Caja Pliométrica',
      descripcion: 'Plataforma para saltos pliométricos y ejercicios de step. Desarrolla potencia explosiva.',
      categoria: MachineCategory.functional,
      tipo: MachineType.funcional,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 10,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.core],
    ),

    MachineModel(
      id: 'dumbbell_rack',
      nombre: 'Rack de Mancuernas',
      descripcion: 'Rack completo con mancuernas de diferentes pesos para ejercicios de cuerpo completo.',
      categoria: MachineCategory.functional,
      tipo: MachineType.pesoLibre,
      nivel: DifficultyLevel.principiante,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),

    MachineModel(
      id: 'multi_gym',
      nombre: 'Estación de Cables Multiusos',
      descripcion: 'Sistema de cables versátil para docenas de ejercicios. Entrenamiento de cuerpo completo.',
      categoria: MachineCategory.functional,
      tipo: MachineType.maquina,
      nivel: DifficultyLevel.intermedio,
      defaultSets: 3,
      defaultReps: 12,
      musculosPrincipales: [],
      musculosSecundarios: [],
    ),
  ];

  // ===========================================================================
  // MÉTODOS DE ACCESO Y BÚSQUEDA
  // ===========================================================================

  /// Obtener máquinas por categoría (incluye categoría secundaria)
  static List<MachineModel> getByCategory(MachineCategory category) {
    return allMachines
        .where((m) => m.categoria == category || m.categoriaSecundaria == category)
        .toList();
  }

  /// Obtener máquina por ID
  static MachineModel? getById(String id) {
    try {
      return allMachines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtener máquinas por tipo
  static List<MachineModel> getByType(MachineType type) {
    return allMachines.where((m) => m.tipo == type).toList();
  }

  /// Obtener máquinas por nivel
  static List<MachineModel> getByLevel(DifficultyLevel level) {
    return allMachines.where((m) => m.nivel == level).toList();
  }

  /// Obtener máquinas por grupo muscular principal
  static List<MachineModel> getByMuscleGroup(MuscleGroup muscle) {
    return allMachines.where((m) {
      return m.musculosPrincipales?.contains(muscle) == true ||
          m.musculosSecundarios?.contains(muscle) == true;
    }).toList();
  }

  /// Buscar máquinas por nombre o descripción
  static List<MachineModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allMachines
        .where((m) =>
            m.nombre.toLowerCase().contains(lowerQuery) ||
            m.descripcion.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Obtener solo máquinas guiadas (con imágenes locales)
  static List<MachineModel> get guidedMachines {
    return allMachines
        .where((m) => m.tipo == MachineType.maquina && m.imageUrl != null)
        .toList();
  }

  /// Obtener solo peso libre (mancuernas, barras, discos)
  static List<MachineModel> get freeWeights {
    return allMachines.where((m) => m.tipo == MachineType.pesoLibre).toList();
  }

  /// Obtener solo mancuernas
  static List<MachineModel> get dumbbells {
    return allMachines.where((m) => m.id.startsWith('mancuerna_')).toList();
  }

  /// Obtener solo barras
  static List<MachineModel> get barbells {
    return allMachines.where((m) => m.id.startsWith('barra_')).toList();
  }

  /// Obtener solo discos
  static List<MachineModel> get plates {
    return allMachines.where((m) => m.id.startsWith('disco_')).toList();
  }

  /// Total de máquinas
  static int get totalMachines => allMachines.length;

  /// Conteo por categoría
  static Map<MachineCategory, int> get countByCategory {
    final counts = <MachineCategory, int>{};
    for (final category in MachineCategory.values) {
      counts[category] = getByCategory(category).length;
    }
    return counts;
  }

  /// Conteo por tipo
  static Map<MachineType, int> get countByType {
    final counts = <MachineType, int>{};
    for (final type in MachineType.values) {
      counts[type] = getByType(type).length;
    }
    return counts;
  }
}
