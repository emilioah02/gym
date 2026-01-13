import '../../../core/models/models.dart';

/// ============================================================================
/// CATÁLOGO COMPLETO DE EJERCICIOS DEL GIMNASIO
/// ============================================================================
///
/// Este archivo contiene todos los ejercicios disponibles organizados por
/// máquina/equipamiento. Cada ejercicio está diseñado para aprovechar
/// las máquinas del inventario (machines_data.dart).
///
/// Estructura de cada ejercicio:
/// - Identificador único basado en máquina + variante
/// - Clasificación por patrón de movimiento (MovementType)
/// - Grupos musculares principales y secundarios tipados
/// - Campo de animación preparado para futuras implementaciones
/// - Indicadores de seguridad cuando aplica
/// - Diferenciación por género cuando es relevante
///
/// Convenciones de ID:
/// - [machineId]_[variante] (ej: prensa_45_grados_standard)
/// - Para ejercicios con mancuernas: db_[ejercicio] (ej: db_press_inclinado)
/// - Para ejercicios con barra: bb_[ejercicio] (ej: bb_sentadilla)
///
/// ============================================================================

class ExercisesData {
  ExercisesData._();

  static const List<ExerciseModel> allExercises = [
    // =========================================================================
    // SECCIÓN 1: EJERCICIOS DE PIERNA - PRENSA 45 GRADOS
    // =========================================================================

    ExerciseModel(
      id: 'prensa_45_standard',
      nombre: 'Prensa 45° Estándar',
      descripcion: 'Ejercicio compuesto para desarrollo general del tren inferior. Pies a la anchura de hombros en el centro de la plataforma.',
      machineId: 'prensa_45_grados',
      machineName: 'Prensa 45 Grados',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 40,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.pantorrillas],
      instrucciones: [
        'Siéntate con la espalda bien apoyada en el respaldo',
        'Coloca los pies a la anchura de los hombros en el centro de la plataforma',
        'Desbloquea los seguros y baja el peso controladamente',
        'Baja hasta que las rodillas formen un ángulo de 90 grados',
        'Empuja hacia arriba sin bloquear las rodillas completamente',
      ],
      tips: [
        'Mantén la espalda baja siempre pegada al respaldo',
        'No dejes que las rodillas colapsen hacia adentro',
        'Exhala al empujar, inhala al bajar',
        'Controla la fase excéntrica (bajada)',
      ],
      erroresComunes: [
        'Despegar la espalda baja del asiento',
        'Bloquear las rodillas en la extensión',
        'Usar demasiado peso perdiendo la forma',
        'Rango de movimiento incompleto',
      ],
      variaciones: ['Pies altos', 'Pies bajos', 'Pies juntos', 'Unilateral'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: false,
        precauciones: ['No bloquear rodillas', 'Mantener espalda baja en contacto'],
      ),
      tempoRecomendado: 3010,
    ),

    ExerciseModel(
      id: 'prensa_45_gluteos',
      nombre: 'Prensa 45° Énfasis Glúteos',
      descripcion: 'Variante con pies altos en la plataforma para mayor activación de glúteos e isquiotibiales.',
      machineId: 'prensa_45_grados',
      machineName: 'Prensa 45 Grados',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.mujer,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 30,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.cuadriceps],
      instrucciones: [
        'Coloca los pies en la parte alta de la plataforma',
        'Sepáralos ligeramente más que el ancho de hombros',
        'Mantén las puntas ligeramente hacia afuera',
        'Baja controladamente sintiendo el estiramiento en glúteos',
        'Empuja principalmente con los talones',
      ],
      tips: [
        'Concéntrate en empujar con los talones',
        'Aprieta los glúteos en la parte superior',
        'Baja más profundo para mayor estiramiento',
      ],
      erroresComunes: [
        'Empujar con las puntas de los pies',
        'No bajar lo suficiente',
      ],
      variaciones: ['Con banda en rodillas', 'Pies muy separados (sumo)'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 3011,
    ),

    ExerciseModel(
      id: 'prensa_45_cuadriceps',
      nombre: 'Prensa 45° Énfasis Cuádriceps',
      descripcion: 'Variante con pies bajos y juntos para máxima activación de cuádriceps.',
      machineId: 'prensa_45_grados',
      machineName: 'Prensa 45 Grados',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 35,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.gluteos],
      instrucciones: [
        'Coloca los pies en la parte baja de la plataforma',
        'Junta los pies a la anchura de las caderas o menos',
        'Baja hasta 90 grados de flexión de rodilla',
        'Empuja extendiendo las rodillas',
      ],
      tips: [
        'Esta posición genera más estrés en rodillas, usar peso moderado',
        'Ideal para finalizar el entrenamiento de cuádriceps',
      ],
      erroresComunes: [
        'Usar el mismo peso que la versión estándar',
        'Forzar la profundidad si hay molestias en rodillas',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: false,
        precauciones: ['Mayor estrés en rodillas', 'Usar peso moderado'],
        contraindicaciones: ['Lesiones de rodilla', 'Dolor patelar'],
      ),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'prensa_45_unilateral',
      nombre: 'Prensa 45° Unilateral',
      descripcion: 'Variante a una pierna para corregir desequilibrios y aumentar la intensidad.',
      machineId: 'prensa_45_grados',
      machineName: 'Prensa 45 Grados',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 20,
      restSeconds: 60,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
      instrucciones: [
        'Coloca un solo pie en el centro de la plataforma',
        'La pierna libre puede estar flexionada o extendida',
        'Mantén la cadera nivelada durante todo el movimiento',
        'Realiza el mismo número de repeticiones por pierna',
      ],
      tips: [
        'Empieza con la pierna más débil',
        'Usa significativamente menos peso que bilateral',
        'Excelente para corregir desequilibrios',
      ],
      erroresComunes: [
        'Rotar la cadera durante el movimiento',
        'Usar demasiado peso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 3010,
    ),

    // =========================================================================
    // SECCIÓN 2: EJERCICIOS DE PIERNA - HACK SQUAT
    // =========================================================================

    ExerciseModel(
      id: 'hack_squat_standard',
      nombre: 'Sentadilla Hack Estándar',
      descripcion: 'Sentadilla guiada con énfasis en cuádriceps. El soporte de espalda permite mayor carga segura.',
      machineId: 'hack_squat',
      machineName: 'Sentadilla Hack',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 40,
      restSeconds: 120,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      instrucciones: [
        'Apoya los hombros firmemente en los soportes',
        'Pies a la anchura de hombros, ligeramente adelante',
        'Desbloquea la máquina y baja controladamente',
        'Baja hasta que los muslos queden paralelos al suelo o más',
        'Empuja hacia arriba manteniendo la tensión',
      ],
      tips: [
        'Mantén las rodillas alineadas con los pies',
        'No dejes que las rodillas se adelanten excesivamente',
        'Exhala al subir con fuerza',
      ],
      erroresComunes: [
        'Despegar los talones de la plataforma',
        'Rodillas colapsando hacia adentro',
        'Rango de movimiento parcial',
      ],
      variaciones: ['Pies altos', 'Pies bajos', 'Stance estrecho', 'Stance ancho'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: false,
      ),
      tempoRecomendado: 3010,
    ),

    ExerciseModel(
      id: 'hack_squat_profundo',
      nombre: 'Sentadilla Hack Profunda',
      descripcion: 'Variante con máximo rango de movimiento para desarrollo completo del cuádriceps.',
      machineId: 'hack_squat',
      machineName: 'Sentadilla Hack',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 35,
      restSeconds: 120,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      instrucciones: [
        'Configura igual que el hack squat estándar',
        'Baja lo más profundo posible manteniendo la forma',
        'Los glúteos deben casi tocar los talones',
        'Sube explosivamente pero con control',
      ],
      tips: [
        'Requiere buena movilidad de tobillo y cadera',
        'Usa menos peso que la versión estándar',
        'La profundidad extra activa más glúteos',
      ],
      erroresComunes: [
        'Forzar la profundidad sin movilidad suficiente',
        'Perder la curvatura lumbar',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Requiere buena movilidad', 'Progresar gradualmente'],
      ),
      tempoRecomendado: 4010,
    ),

    // =========================================================================
    // SECCIÓN 3: EJERCICIOS DE PIERNA - SENTADILLA PÉNDULO
    // =========================================================================

    ExerciseModel(
      id: 'sentadilla_pendulo_standard',
      nombre: 'Sentadilla Péndulo Estándar',
      descripcion: 'Sentadilla con movimiento pendular que reduce estrés en rodillas y enfatiza glúteos.',
      machineId: 'sentadilla_pendulo',
      machineName: 'Sentadilla Péndulo',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 30,
      restSeconds: 90,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      instrucciones: [
        'Ajusta el asiento a tu altura',
        'Apoya los hombros en los soportes',
        'Pies en la plataforma a la anchura de hombros',
        'Baja siguiendo el arco natural de la máquina',
        'Empuja a través de los talones',
      ],
      tips: [
        'El movimiento pendular es más natural para las articulaciones',
        'Ideal si tienes molestias en rodillas con otras máquinas',
        'Concéntrate en la contracción de glúteos',
      ],
      erroresComunes: [
        'No ajustar correctamente el asiento',
        'Empujar con las puntas de los pies',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 3010,
    ),

    // =========================================================================
    // SECCIÓN 4: EJERCICIOS DE PIERNA - SENTADILLA SISSY
    // =========================================================================

    ExerciseModel(
      id: 'sentadilla_sissy_standard',
      nombre: 'Sentadilla Sissy',
      descripcion: 'Ejercicio de aislamiento extremo para cuádriceps. Movimiento avanzado que requiere buena técnica.',
      machineId: 'sentadilla_sissy',
      machineName: 'Sentadilla Sissy',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.flexoresCadera],
      instrucciones: [
        'Asegura los pies/tobillos en el soporte',
        'Mantén la cadera completamente extendida',
        'Inclínate hacia atrás bajando las rodillas hacia el suelo',
        'Mantén el torso y muslos en línea recta',
        'Sube contrayendo los cuádriceps',
      ],
      tips: [
        'Comienza sin peso adicional',
        'El estiramiento debe sentirse intenso en cuádriceps',
        'Progresa agregando un disco al pecho',
      ],
      erroresComunes: [
        'Flexionar la cadera (romper la línea del cuerpo)',
        'Bajar demasiado rápido',
        'Agregar peso antes de dominar la técnica',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: true,
        precauciones: ['Dominar técnica sin peso primero', 'Alto estrés en rodillas'],
        contraindicaciones: ['Problemas de rodilla', 'Lesiones de cuádriceps'],
      ),
      tempoRecomendado: 4020,
    ),

    // =========================================================================
    // SECCIÓN 5: EJERCICIOS DE PIERNA - SMITH MACHINE
    // =========================================================================

    ExerciseModel(
      id: 'smith_sentadilla_standard',
      nombre: 'Sentadilla en Smith',
      descripcion: 'Sentadilla guiada en máquina Smith. Ideal para principiantes o trabajo pesado seguro.',
      machineId: 'smith_machine',
      machineName: 'Sentadilla en Smith',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 20,
      restSeconds: 120,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
      instrucciones: [
        'Coloca la barra sobre los trapecios',
        'Pies ligeramente adelante de la línea de la barra',
        'Desbloquea girando la barra',
        'Baja manteniendo el torso lo más vertical posible',
        'Sube empujando a través de los talones',
      ],
      tips: [
        'Los pies adelante reducen el estrés en rodillas',
        'Usa los seguros de seguridad siempre',
        'Permite enfocarte en los músculos sin preocuparte del balance',
      ],
      erroresComunes: [
        'Pies directamente bajo la barra (aumenta estrés en rodillas)',
        'No usar los seguros',
        'Inclinarse demasiado hacia adelante',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Usar seguros de seguridad'],
      ),
      tempoRecomendado: 3010,
    ),

    ExerciseModel(
      id: 'smith_zancada',
      nombre: 'Zancada en Smith',
      descripcion: 'Zancada estática con barra guiada. Excelente para glúteos y cuádriceps unilateralmente.',
      machineId: 'smith_machine',
      machineName: 'Sentadilla en Smith',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      instrucciones: [
        'Posición de zancada con un pie adelante y otro atrás',
        'La barra descansa sobre los trapecios',
        'Baja verticalmente hasta que la rodilla trasera casi toque el suelo',
        'Sube empujando con la pierna delantera',
        'Completa todas las reps de un lado antes de cambiar',
      ],
      tips: [
        'La estabilidad del Smith permite mayor carga',
        'Mantén el torso vertical',
        'Empieza con la pierna más débil',
      ],
      erroresComunes: [
        'Inclinarse hacia adelante',
        'Rodilla delantera pasando la punta del pie',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'smith_hip_thrust',
      nombre: 'Hip Thrust en Smith',
      descripcion: 'Empuje de cadera con barra guiada. Máximo aislamiento de glúteos.',
      machineId: 'smith_machine',
      machineName: 'Sentadilla en Smith',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.mujer,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 40,
      restSeconds: 90,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
      instrucciones: [
        'Coloca un banco perpendicular a la Smith',
        'Apoya la espalda alta en el banco',
        'La barra debe quedar sobre la cadera (usa pad)',
        'Pies firmes en el suelo, rodillas a 90 grados arriba',
        'Empuja la cadera hacia arriba contrayendo glúteos',
        'Baja controladamente',
      ],
      tips: [
        'Usa un pad para proteger la cadera',
        'Aprieta fuerte los glúteos arriba',
        'Mira hacia el techo, no hacia adelante',
        'Mantén el mentón hacia el pecho',
      ],
      erroresComunes: [
        'Hiperextender la espalda baja',
        'No llegar a extensión completa de cadera',
        'Pies demasiado cerca o lejos del cuerpo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Usar pad para la cadera'],
      ),
      equipamientoAdicional: 'Pad para cadera, banco',
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 6: EJERCICIOS DE PIERNA - RACK SENTADILLA LIBRE
    // =========================================================================

    ExerciseModel(
      id: 'bb_sentadilla_libre',
      nombre: 'Sentadilla Libre con Barra',
      descripcion: 'El ejercicio rey para el desarrollo del tren inferior. Requiere técnica y experiencia.',
      machineId: 'squat_rack',
      machineName: 'Rack de Sentadilla Libre',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 40,
      restSeconds: 180,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.core, MuscleGroup.erectoresEspinales],
      instrucciones: [
        'Coloca la barra sobre los trapecios superiores',
        'Agarra la barra firmemente y retrae los omóplatos',
        'Pies a la anchura de hombros, puntas ligeramente afuera',
        'Activa el core, inhala y baja controladamente',
        'Baja hasta que los muslos estén paralelos o más',
        'Empuja a través de todo el pie, mantén el pecho arriba',
      ],
      tips: [
        'Mira a un punto fijo adelante',
        'Las rodillas siguen la dirección de los pies',
        'Mantén la barra sobre la mitad del pie',
        'Usa cinturón en cargas pesadas',
      ],
      erroresComunes: [
        'Rodillas colapsando hacia adentro',
        'Inclinarse demasiado hacia adelante',
        'Talones despegándose',
        'Perder la curvatura lumbar (buttwink excesivo)',
      ],
      variaciones: ['Sentadilla frontal', 'Pausa squat', 'Box squat'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: true,
        highInjuryRisk: true,
        precauciones: ['Usar seguros del rack', 'Spotter para cargas pesadas'],
      ),
      equipamientoAdicional: 'Cinturón de levantamiento (opcional)',
      tempoRecomendado: 3010,
    ),

    ExerciseModel(
      id: 'bb_sentadilla_frontal',
      nombre: 'Sentadilla Frontal',
      descripcion: 'Sentadilla con barra al frente sobre deltoides. Mayor énfasis en cuádriceps y core.',
      machineId: 'squat_rack',
      machineName: 'Rack de Sentadilla Libre',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 30,
      restSeconds: 150,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.core],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.erectoresEspinales],
      instrucciones: [
        'Barra apoyada en deltoides anteriores y clavículas',
        'Agarre limpio (dedos bajo la barra) o cruzado',
        'Codos altos, paralelos al suelo',
        'Baja mantiendo el torso muy vertical',
        'Profundidad completa si la movilidad lo permite',
      ],
      tips: [
        'Requiere buena movilidad de muñecas y hombros',
        'Los codos altos mantienen la barra en posición',
        'Menos peso que sentadilla trasera, pero más activación de core',
      ],
      erroresComunes: [
        'Dejar caer los codos (la barra se rueda)',
        'Inclinarse hacia adelante',
        'Falta de movilidad de muñeca',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: true,
        precauciones: ['Dominar primero la técnica con barra vacía'],
      ),
      tempoRecomendado: 3010,
    ),

    // =========================================================================
    // SECCIÓN 7: EJERCICIOS DE PIERNA - EXTENSIÓN CUÁDRICEPS
    // =========================================================================

    ExerciseModel(
      id: 'extension_cuad_standard',
      nombre: 'Extensión de Cuádriceps',
      descripcion: 'Ejercicio de aislamiento para cuádriceps. Ideal para calentamiento, finalizador o rehabilitación.',
      machineId: 'extension_cuadriceps',
      machineName: 'Extensión de Cuádriceps',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 20,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [],
      instrucciones: [
        'Ajusta el respaldo para que las rodillas queden alineadas con el eje',
        'El rodillo debe quedar justo encima de los tobillos',
        'Extiende las piernas completamente',
        'Mantén la contracción arriba 1-2 segundos',
        'Baja controladamente sin dejar caer el peso',
      ],
      tips: [
        'Aprieta los cuádriceps fuerte en la contracción máxima',
        'No uses impulso, el movimiento debe ser fluido',
        'Excelente para conexión mente-músculo',
      ],
      erroresComunes: [
        'Rodillas no alineadas con el eje de la máquina',
        'Usar impulso para levantar',
        'Dejar caer el peso en la bajada',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['No hiperextender', 'Peso moderado para principiantes'],
      ),
      tempoRecomendado: 2012,
    ),

    ExerciseModel(
      id: 'extension_cuad_unilateral',
      nombre: 'Extensión de Cuádriceps Unilateral',
      descripcion: 'Variante a una pierna para corregir desequilibrios y aumentar intensidad.',
      machineId: 'extension_cuadriceps',
      machineName: 'Extensión de Cuádriceps',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 12,
      restSeconds: 45,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.cuadriceps],
      musculosSecundarios: [],
      instrucciones: [
        'Misma configuración que la versión bilateral',
        'Trabaja una pierna mientras la otra descansa',
        'Completa todas las repeticiones de un lado antes de cambiar',
      ],
      tips: [
        'Empieza con la pierna más débil',
        'Excelente para igualar fuerza entre piernas',
      ],
      erroresComunes: [
        'Usar el mismo peso que bilateral por pierna',
        'Compensar con movimiento del cuerpo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 8: EJERCICIOS DE PIERNA - FEMORAL SENTADO
    // =========================================================================

    ExerciseModel(
      id: 'femoral_sentado_standard',
      nombre: 'Curl Femoral Sentado',
      descripcion: 'Aislamiento de isquiotibiales en posición sentada. Cómodo y efectivo.',
      machineId: 'femoral_sentado',
      machineName: 'Femoral Sentado',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 25,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas],
      instrucciones: [
        'Ajusta el respaldo para que las rodillas queden en el borde del asiento',
        'El rodillo superior va sobre los muslos',
        'El rodillo inferior va justo encima de los talones',
        'Flexiona las rodillas llevando los talones hacia los glúteos',
        'Controla la extensión de vuelta',
      ],
      tips: [
        'Mantén la espalda pegada al respaldo',
        'Apunta los pies (flexión plantar) para más activación',
        'Sostén la contracción máxima brevemente',
      ],
      erroresComunes: [
        'Levantar los glúteos del asiento',
        'Rango de movimiento incompleto',
        'Usar impulso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 9: EJERCICIOS DE PIERNA - FEMORAL ACOSTADO
    // =========================================================================

    ExerciseModel(
      id: 'femoral_acostado_standard',
      nombre: 'Curl Femoral Acostado',
      descripcion: 'Curl de isquiotibiales boca abajo. Mayor estiramiento y activación de glúteos.',
      machineId: 'femoral_acostado',
      machineName: 'Femoral Acostado',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 20,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.gluteos],
      instrucciones: [
        'Acuéstate boca abajo con las rodillas justo fuera del banco',
        'El rodillo va justo encima de los talones',
        'Agarra los agarres frontales para estabilidad',
        'Flexiona las rodillas llevando los talones hacia los glúteos',
        'Baja controladamente hasta casi extensión completa',
      ],
      tips: [
        'Mantén las caderas pegadas al banco',
        'Aprieta los glúteos para estabilizar',
        'Mayor estiramiento en esta posición que sentado',
      ],
      erroresComunes: [
        'Levantar las caderas del banco',
        'Hiperextender en la bajada',
        'Usar impulso con la espalda',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 10: EJERCICIOS DE PIERNA - ABDUCTOR
    // =========================================================================

    ExerciseModel(
      id: 'abductor_standard',
      nombre: 'Abducción de Cadera en Máquina',
      descripcion: 'Aislamiento de abductores y glúteo medio. Importante para estabilidad de cadera.',
      machineId: 'abductor_machine',
      machineName: 'Máquina Abductora',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.mujer,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 30,
      restSeconds: 45,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.abductores, MuscleGroup.gluteos],
      musculosSecundarios: [],
      instrucciones: [
        'Siéntate con la espalda recta contra el respaldo',
        'Coloca las piernas en los soportes',
        'Abre las piernas hacia afuera contra la resistencia',
        'Sostén la contracción máxima 1-2 segundos',
        'Cierra las piernas de forma controlada',
      ],
      tips: [
        'Inclínate ligeramente hacia adelante para más glúteo',
        'No uses impulso, movimiento fluido',
        'Excelente para warming up antes de sentadillas',
      ],
      erroresComunes: [
        'Usar impulso para abrir',
        'Rango de movimiento incompleto',
        'Tensar el cuello y hombros',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 11: EJERCICIOS DE PIERNA - ADUCTOR
    // =========================================================================

    ExerciseModel(
      id: 'aductor_standard',
      nombre: 'Aducción de Cadera en Máquina',
      descripcion: 'Aislamiento de aductores (interior del muslo). Complemento importante para balance muscular.',
      machineId: 'aductor_machine',
      machineName: 'Máquina Aductora',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.mujer,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 35,
      restSeconds: 45,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.aductores],
      musculosSecundarios: [],
      instrucciones: [
        'Siéntate con la espalda recta',
        'Piernas abiertas en los soportes (posición inicial)',
        'Junta las piernas contra la resistencia',
        'Aprieta en la contracción máxima',
        'Abre de forma controlada sin golpear el peso',
      ],
      tips: [
        'Mantén el core activo',
        'Controla especialmente la fase de apertura',
        'Complementa siempre con abducción',
      ],
      erroresComunes: [
        'Usar impulso',
        'Dejar que el peso golpee en la apertura',
        'Tensión en cuello y hombros',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 12: EJERCICIOS DE PIERNA - GLUTE KICKBACK
    // =========================================================================

    ExerciseModel(
      id: 'glute_kickback_standard',
      nombre: 'Patada de Glúteo en Máquina',
      descripcion: 'Aislamiento puro de glúteos mediante extensión de cadera. Ejercicio favorito para desarrollo de glúteos.',
      machineId: 'glute_kickback',
      machineName: 'Máquina Patada de Glúteo',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.mujer,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 20,
      restSeconds: 45,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      instrucciones: [
        'Posiciónate en la máquina según el diseño',
        'Mantén el core activado para estabilizar',
        'Empuja con el talón hacia atrás extendiendo la cadera',
        'Aprieta fuerte el glúteo en la contracción máxima',
        'Regresa controladamente sin perder tensión',
      ],
      tips: [
        'Enfócate en la contracción del glúteo, no solo el movimiento',
        'No arquees excesivamente la espalda baja',
        'Empuja con el talón, no con la punta',
      ],
      erroresComunes: [
        'Arquear la espalda para levantar más',
        'Usar impulso',
        'No completar la extensión de cadera',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2012,
    ),

    // =========================================================================
    // SECCIÓN 13: EJERCICIOS DE PECHO - PRESS HORIZONTAL
    // =========================================================================

    ExerciseModel(
      id: 'chest_press_horizontal_standard',
      nombre: 'Press de Pecho Horizontal',
      descripcion: 'Press de pecho en máquina con movimiento horizontal. Enfatiza el pectoral medio.',
      machineId: 'chest_press_horizontal',
      machineName: 'Press de Pecho Horizontal',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 30,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Ajusta el asiento para que los agarres queden a la altura del pecho',
        'Siéntate con la espalda bien apoyada',
        'Retrae los omóplatos antes de empujar',
        'Empuja hasta extensión casi completa',
        'Baja controladamente sintiendo el estiramiento',
      ],
      tips: [
        'Mantén los omóplatos juntos durante todo el movimiento',
        'No bloquees los codos completamente',
        'Exhala al empujar',
      ],
      erroresComunes: [
        'Asiento mal ajustado',
        'Perder la retracción escapular',
        'Bloquear los codos',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 14: EJERCICIOS DE PECHO - PRESS INCLINADO
    // =========================================================================

    ExerciseModel(
      id: 'chest_press_incline_standard',
      nombre: 'Press de Pecho Inclinado',
      descripcion: 'Press inclinado para desarrollo del pectoral superior y deltoides anterior.',
      machineId: 'chest_press_incline',
      machineName: 'Press de Pecho Inclinado',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 25,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.deltoidesAnterior],
      musculosSecundarios: [MuscleGroup.triceps],
      instrucciones: [
        'Ajusta el asiento para que los agarres queden a la altura de las clavículas',
        'El ángulo inclinado trabaja más la porción clavicular del pecho',
        'Empuja hacia arriba y ligeramente hacia adelante',
        'Controla la bajada hasta sentir estiramiento',
      ],
      tips: [
        'Usarás menos peso que en press horizontal',
        'Excelente para desarrollar el pecho superior',
        'Mantén los pies firmes en el suelo',
      ],
      erroresComunes: [
        'Usar el mismo peso que press horizontal',
        'Arquear excesivamente la espalda',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 15: EJERCICIOS DE PECHO - PRESS DECLINADO
    // =========================================================================

    ExerciseModel(
      id: 'chest_press_decline_standard',
      nombre: 'Press de Pecho Declinado',
      descripcion: 'Press declinado para énfasis en la porción inferior del pectoral.',
      machineId: 'chest_press_decline',
      machineName: 'Press de Pecho Declinado',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 35,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'El ángulo declinado enfatiza la porción esternal/inferior',
        'Mantén los omóplatos retraídos',
        'Empuja hasta extensión casi completa',
        'Baja hasta que los codos estén paralelos al torso',
      ],
      tips: [
        'Puedes usar más peso que en inclinado',
        'Complementa con inclinado para pecho completo',
      ],
      erroresComunes: [
        'Dejar que los codos bajen demasiado',
        'Perder la retracción escapular',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 16: EJERCICIOS DE PECHO - PRESS HAMMER
    // =========================================================================

    ExerciseModel(
      id: 'chest_press_hammer_standard',
      nombre: 'Press de Pecho Hammer',
      descripcion: 'Press con brazos independientes para trabajo unilateral y corrección de desequilibrios.',
      machineId: 'chest_press_hammer',
      machineName: 'Press de Pecho Hammer',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 15,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Los brazos independientes se mueven de forma convergente',
        'Empuja ambos lados simultáneamente o alternado',
        'Mantén la simetría del movimiento',
        'El movimiento es más natural que máquinas con barra fija',
      ],
      tips: [
        'Ideal para corregir desequilibrios de fuerza',
        'Puedes trabajar un lado a la vez si es necesario',
        'Movimiento convergente simula mejor el press con mancuernas',
      ],
      erroresComunes: [
        'Empujar más con un brazo que con otro',
        'No mantener el core estable',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'chest_press_hammer_unilateral',
      nombre: 'Press de Pecho Hammer Unilateral',
      descripcion: 'Variante a un brazo para máxima concentración y corrección de desbalances.',
      machineId: 'chest_press_hammer',
      machineName: 'Press de Pecho Hammer',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior, MuscleGroup.core],
      instrucciones: [
        'Trabaja un brazo mientras el otro sostiene el agarre',
        'Mantén el core muy activado para evitar rotación',
        'Completa todas las reps de un lado antes de cambiar',
        'Empieza siempre con el lado más débil',
      ],
      tips: [
        'Mayor activación del core por la anti-rotación',
        'Excelente para igualar fuerza entre lados',
      ],
      erroresComunes: [
        'Rotar el torso durante el empuje',
        'Usar demasiado peso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 17: EJERCICIOS DE PECHO - PEC FLY
    // =========================================================================

    ExerciseModel(
      id: 'pec_fly_standard',
      nombre: 'Aperturas en Máquina (Pec Fly)',
      descripcion: 'Aislamiento de pectorales mediante aducción horizontal. Excelente para definición.',
      machineId: 'pec_fly',
      machineName: 'Pec Fly / Contractora',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 25,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.pectoralMenor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Ajusta el asiento para que los brazos queden paralelos al suelo',
        'Codos ligeramente flexionados durante todo el movimiento',
        'Junta los brazos frente al pecho',
        'Aprieta los pectorales en la contracción máxima',
        'Abre controladamente sin ir más allá de los hombros',
      ],
      tips: [
        'Imagina que abrazas un árbol grande',
        'Mantén un ligero doblez en los codos siempre',
        'La apertura excesiva puede estresar los hombros',
      ],
      erroresComunes: [
        'Brazos completamente rectos (riesgo)',
        'Apertura excesiva más allá de los hombros',
        'Usar impulso del cuerpo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener codos flexionados', 'No abrir más allá de hombros'],
      ),
      tempoRecomendado: 2012,
    ),

    // =========================================================================
    // SECCIÓN 18: EJERCICIOS DE PECHO - CABLE CROSSOVER
    // =========================================================================

    ExerciseModel(
      id: 'cable_crossover_alto',
      nombre: 'Cruce de Cables Alto',
      descripcion: 'Cruce de cables desde poleas altas para énfasis en pectoral inferior.',
      machineId: 'cable_crossover',
      machineName: 'Cross Over / Cruce de Cables',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 10,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Poleas en posición alta',
        'Da un paso adelante para estabilidad',
        'Inclina ligeramente el torso hacia adelante',
        'Trae los cables hacia abajo y hacia el centro',
        'Cruza las manos en la posición final',
        'Regresa controladamente',
      ],
      tips: [
        'El cruce final maximiza la contracción',
        'Poleas altas = énfasis en pecho inferior',
        'Mantén tensión constante',
      ],
      erroresComunes: [
        'No cruzar las manos',
        'Usar demasiado peso perdiendo forma',
        'No mantener el ángulo del torso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'cable_crossover_bajo',
      nombre: 'Cruce de Cables Bajo',
      descripcion: 'Cruce de cables desde poleas bajas para énfasis en pectoral superior.',
      machineId: 'cable_crossover',
      machineName: 'Cross Over / Cruce de Cables',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 8,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.deltoidesAnterior],
      musculosSecundarios: [],
      instrucciones: [
        'Poleas en posición baja',
        'Da un paso adelante para estabilidad',
        'Trae los cables hacia arriba y hacia el centro',
        'Junta las manos a la altura del pecho o más arriba',
        'Regresa controladamente',
      ],
      tips: [
        'Poleas bajas = énfasis en pecho superior',
        'Excelente complemento del press inclinado',
        'Mantén el core activo para estabilidad',
      ],
      erroresComunes: [
        'Usar impulso del cuerpo',
        'No alcanzar suficiente altura',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'cable_crossover_medio',
      nombre: 'Cruce de Cables Medio',
      descripcion: 'Cruce de cables a altura media para desarrollo general del pectoral.',
      machineId: 'cable_crossover',
      machineName: 'Cross Over / Cruce de Cables',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 10,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Poleas a la altura del pecho',
        'Da un paso adelante para estabilidad',
        'Trae los cables al frente manteniendo altura',
        'Cruza ligeramente las manos',
        'Regresa controladamente',
      ],
      tips: [
        'Altura media = desarrollo general',
        'Tensión constante durante todo el ROM',
        'Varía la altura para estimulación completa',
      ],
      erroresComunes: [
        'Cambiar el ángulo durante el movimiento',
        'Usar impulso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 19: EJERCICIOS DE ESPALDA - JALÓN HAMMER
    // =========================================================================

    ExerciseModel(
      id: 'lat_pulldown_hammer_standard',
      nombre: 'Jalón Hammer para Dorsales',
      descripcion: 'Jalón con brazos independientes tipo Hammer. Excelente para desarrollo de dorsales.',
      machineId: 'lat_pulldown_hammer',
      machineName: 'Jalón Hammer para Espalda',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 30,
      restSeconds: 90,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.romboides, MuscleGroup.trapecios],
      instrucciones: [
        'Siéntate con los muslos bajo los soportes',
        'Agarra las manijas con agarre neutral',
        'Inicia retrayendo los omóplatos',
        'Tira hacia abajo llevando los codos hacia las costillas',
        'Aprieta la espalda en la contracción',
        'Sube controladamente extendiendo completamente',
      ],
      tips: [
        'Piensa en tirar con los codos, no con las manos',
        'Mantén el pecho alto durante todo el movimiento',
        'Los brazos independientes permiten identificar desbalances',
      ],
      erroresComunes: [
        'Tirar solo con los brazos',
        'Inclinarse demasiado hacia atrás',
        'Movimiento incompleto',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'lat_pulldown_hammer_unilateral',
      nombre: 'Jalón Hammer Unilateral',
      descripcion: 'Variante a un brazo para máxima concentración y rango de movimiento.',
      machineId: 'lat_pulldown_hammer',
      machineName: 'Jalón Hammer para Espalda',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 20,
      restSeconds: 60,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.romboides],
      instrucciones: [
        'Trabaja un brazo mientras el otro descansa',
        'Permite mayor rango de movimiento y rotación',
        'Completa todas las reps de un lado antes de cambiar',
        'Empieza con el lado más débil',
      ],
      tips: [
        'Mayor estiramiento y contracción que bilateral',
        'Excelente para conexión mente-músculo',
        'Permite ligera rotación del torso',
      ],
      erroresComunes: [
        'Rotar excesivamente el torso',
        'Usar impulso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 20: EJERCICIOS DE ESPALDA - REMO MÁQUINA
    // =========================================================================

    ExerciseModel(
      id: 'seated_row_standard',
      nombre: 'Remo Sentado en Máquina',
      descripcion: 'Remo con soporte de pecho para aislamiento de espalda. Elimina el uso de impulso.',
      machineId: 'seated_row_machine',
      machineName: 'Máquina de Remo para Espalda',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 35,
      restSeconds: 90,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.trapecios],
      instrucciones: [
        'Ajusta el soporte de pecho a tu altura',
        'Pecho contra el soporte durante todo el movimiento',
        'Extiende los brazos completamente al inicio',
        'Tira llevando los codos hacia atrás',
        'Junta los omóplatos al final',
        'Regresa controladamente',
      ],
      tips: [
        'El soporte de pecho elimina la tentación de usar impulso',
        'Concéntrate en apretar los omóplatos',
        'Codos cerca del cuerpo para más dorsales',
      ],
      erroresComunes: [
        'Separarse del soporte de pecho',
        'Rango de movimiento incompleto',
        'Tirar solo con los brazos',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 21: EJERCICIOS DE ESPALDA - HIPEREXTENSIÓN
    // =========================================================================

    ExerciseModel(
      id: 'hyperextension_standard',
      nombre: 'Hiperextensión',
      descripcion: 'Extensión de espalda para fortalecer erectores espinales. Fundamental para salud de espalda baja.',
      machineId: 'hyperextension',
      machineName: 'Banco de Hiperextensión',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.erectoresEspinales],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      instrucciones: [
        'Ajusta el soporte a la altura de la cadera',
        'Engancha los pies/tobillos en los soportes',
        'Cruza los brazos sobre el pecho o detrás de la cabeza',
        'Baja el torso hasta quedar perpendicular al suelo',
        'Sube hasta la línea del cuerpo, no más arriba',
        'Mantén la mirada neutral durante el movimiento',
      ],
      tips: [
        'No hiperextendas (subir más allá de la línea del cuerpo)',
        'Movimiento controlado, sin impulso',
        'Para mayor dificultad, sostén un disco contra el pecho',
      ],
      erroresComunes: [
        'Hiperextender la espalda (subir demasiado)',
        'Usar impulso para subir',
        'Manos detrás de la nuca tirando del cuello',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['No hiperextender', 'Mantener cuello neutral'],
      ),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'hyperextension_gluteos',
      nombre: 'Hiperextensión con Énfasis en Glúteos',
      descripcion: 'Variante que enfatiza la activación de glúteos mediante posición de pies.',
      machineId: 'hyperextension',
      machineName: 'Banco de Hiperextensión',
      categoria: MachineCategory.espalda,
      categoriaSecundaria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.mujer,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.erectoresEspinales],
      musculosSecundarios: [MuscleGroup.isquiotibiales],
      instrucciones: [
        'Misma posición que hiperextensión estándar',
        'Rota los pies hacia afuera (talones juntos, puntas afuera)',
        'Aprieta los glúteos antes de iniciar el movimiento',
        'Sube liderando con los glúteos, no con la espalda baja',
        'Mantén la contracción de glúteos arriba',
      ],
      tips: [
        'La rotación externa activa más los glúteos',
        'Piensa en empujar la cadera hacia el soporte al bajar',
        'Excelente para activación de glúteos',
      ],
      erroresComunes: [
        'Olvidar la rotación externa de pies',
        'Subir solo con espalda baja',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 22: EJERCICIOS DE HOMBRO - PRESS HAMMER
    // =========================================================================

    ExerciseModel(
      id: 'shoulder_press_hammer_standard',
      nombre: 'Press de Hombro Hammer',
      descripcion: 'Press de hombros con movimiento convergente. Seguro y efectivo para deltoides.',
      machineId: 'shoulder_press_hammer',
      machineName: 'Press de Hombro Hammer',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 12,
      defaultWeight: 20,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.trapecios],
      instrucciones: [
        'Ajusta el asiento para que los agarres inicien a la altura de los hombros',
        'Siéntate con la espalda bien apoyada',
        'Empuja hacia arriba sin bloquear los codos',
        'El movimiento convergente es más natural para los hombros',
        'Baja controladamente hasta la posición inicial',
      ],
      tips: [
        'Mantén el core activo para estabilidad',
        'No arquees la espalda para ayudarte',
        'Exhala al empujar',
      ],
      erroresComunes: [
        'Arquear excesivamente la espalda',
        'Bloquear los codos',
        'Asiento mal ajustado',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 23: EJERCICIOS DE HOMBRO - LATERALES MÁQUINA
    // =========================================================================

    ExerciseModel(
      id: 'lateral_raise_machine_standard',
      nombre: 'Elevaciones Laterales en Máquina',
      descripcion: 'Aislamiento del deltoides lateral con movimiento guiado. Tensión constante.',
      machineId: 'lateral_raise_machine',
      machineName: 'Elevaciones Laterales en Máquina',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.trapecios],
      instrucciones: [
        'Ajusta el asiento para que los soportes queden a la altura de los codos',
        'Codos ligeramente flexionados',
        'Eleva los brazos hasta la altura de los hombros',
        'Mantén la contracción arriba brevemente',
        'Baja controladamente sin dejar caer el peso',
      ],
      tips: [
        'Hombros abajo, no los subas hacia las orejas',
        'No eleves más allá de los hombros',
        'Lídera con los codos, no con las manos',
      ],
      erroresComunes: [
        'Elevar los hombros (usar trapecio)',
        'Subir más allá de la línea de los hombros',
        'Usar impulso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 24: EJERCICIOS DE BRAZO - CURL PREDICADOR
    // =========================================================================

    ExerciseModel(
      id: 'preacher_curl_standard',
      nombre: 'Curl Predicador en Máquina',
      descripcion: 'Curl de bíceps con soporte tipo predicador. Aislamiento total sin posibilidad de impulso.',
      machineId: 'preacher_curl_machine',
      machineName: 'Curl Predicador en Máquina',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      instrucciones: [
        'Ajusta el asiento para que los brazos descansen completamente en el soporte',
        'Los codos deben quedar fijos durante todo el movimiento',
        'Flexiona hasta contracción máxima',
        'Baja controladamente sin extender completamente',
        'Mantén la muñeca neutral o ligeramente flexionada',
      ],
      tips: [
        'La posición predicador elimina completamente el impulso',
        'Excelente para conexión mente-músculo',
        'No extiendas completamente para mantener tensión',
      ],
      erroresComunes: [
        'Despegar los codos del soporte',
        'Extender completamente los brazos',
        'Usar peso excesivo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['No hiperextender codos'],
      ),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 25: EJERCICIOS CON MANCUERNAS - PECHO
    // =========================================================================

    ExerciseModel(
      id: 'db_press_plano',
      nombre: 'Press con Mancuernas Plano',
      descripcion: 'Press de pecho con mancuernas en banco plano. Mayor rango de movimiento que barra.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Acuéstate en banco plano con mancuernas sobre el pecho',
        'Retrae los omóplatos y arquea ligeramente',
        'Baja las mancuernas hasta la altura del pecho',
        'Empuja hacia arriba juntando ligeramente las mancuernas',
      ],
      tips: [
        'Mayor rango de movimiento que con barra',
        'Cada brazo trabaja independientemente',
        'Excelente para desarrollo y simetría',
      ],
      erroresComunes: [
        'Bajar demasiado estresando los hombros',
        'No retraer los omóplatos',
        'Rebotar las mancuernas abajo',
      ],
      variaciones: ['Agarre neutro', 'Rotación durante el press'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: true,
        precauciones: ['Cuidado al subir/bajar mancuernas pesadas'],
      ),
      equipamientoAdicional: 'Banco plano',
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_press_inclinado',
      nombre: 'Press con Mancuernas Inclinado',
      descripcion: 'Press inclinado con mancuernas para desarrollo del pectoral superior.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 10,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.deltoidesAnterior],
      musculosSecundarios: [MuscleGroup.triceps],
      instrucciones: [
        'Banco inclinado a 30-45 grados',
        'Mancuernas sobre el pecho con brazos extendidos',
        'Baja hasta la altura de los hombros',
        'Empuja hacia arriba y ligeramente hacia el centro',
      ],
      tips: [
        'Ángulo de 30° para más pecho, 45° para más hombro',
        'Usarás menos peso que en plano',
        'Excelente para el pecho superior',
      ],
      erroresComunes: [
        'Ángulo excesivo (más de 45°)',
        'Usar el mismo peso que en plano',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: true),
      equipamientoAdicional: 'Banco inclinado',
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_apertura_plano',
      nombre: 'Aperturas con Mancuernas',
      descripcion: 'Aperturas en banco plano para estiramiento y aislamiento del pectoral.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Acuéstate con mancuernas arriba, brazos casi extendidos',
        'Codos ligeramente flexionados (posición fija)',
        'Abre los brazos en arco hasta la altura del pecho',
        'Siente el estiramiento en el pecho',
        'Junta las mancuernas arriba contrayendo el pecho',
      ],
      tips: [
        'El doblez del codo no cambia durante el movimiento',
        'Imagina que abrazas un barril',
        'Usa peso moderado para mantener la forma',
      ],
      erroresComunes: [
        'Bajar demasiado (estrés en hombros)',
        'Convertirlo en press doblando más los codos',
        'Usar peso excesivo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['No bajar demasiado'],
      ),
      equipamientoAdicional: 'Banco plano',
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 26: EJERCICIOS CON MANCUERNAS - ESPALDA
    // =========================================================================

    ExerciseModel(
      id: 'db_remo_unilateral',
      nombre: 'Remo con Mancuerna a Una Mano',
      descripcion: 'Remo unilateral para desarrollo de dorsales y espalda media.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 60,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.trapecios],
      instrucciones: [
        'Apoya una mano y rodilla en el banco',
        'Espalda paralela al suelo',
        'Mancuerna colgando con brazo extendido',
        'Tira del codo hacia el techo/cadera',
        'Aprieta la espalda arriba',
        'Baja controladamente',
      ],
      tips: [
        'Piensa en tirar con el codo, no con la mano',
        'Permite ligera rotación del torso',
        'Mantén el core activo para no rotar excesivamente',
      ],
      erroresComunes: [
        'Rotar excesivamente el torso',
        'Tirar solo con el brazo',
        'Espalda redondeada',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      equipamientoAdicional: 'Banco plano',
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 27: EJERCICIOS CON MANCUERNAS - HOMBRO
    // =========================================================================

    ExerciseModel(
      id: 'db_press_hombro',
      nombre: 'Press de Hombro con Mancuernas',
      descripcion: 'Press militar con mancuernas para desarrollo de deltoides.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.trapecios],
      instrucciones: [
        'Sentado en banco con respaldo vertical',
        'Mancuernas a la altura de los hombros',
        'Empuja hacia arriba sin bloquear codos',
        'Baja hasta la altura de las orejas',
      ],
      tips: [
        'Mantén el core muy activo',
        'No arquees la espalda',
        'Puedes hacerlo de pie para más core',
      ],
      erroresComunes: [
        'Arquear la espalda',
        'Mancuernas desbalanceadas',
        'Bloquear codos arriba',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener espalda recta'],
      ),
      equipamientoAdicional: 'Banco con respaldo',
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_elevacion_lateral',
      nombre: 'Elevación Lateral con Mancuernas',
      descripcion: 'Aislamiento del deltoides lateral para anchura de hombros.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.trapecios],
      instrucciones: [
        'De pie con mancuernas a los lados',
        'Codos ligeramente flexionados',
        'Eleva los brazos lateralmente hasta los hombros',
        'Lídera con los codos, no con las manos',
        'Baja controladamente',
      ],
      tips: [
        'Hombros abajo durante todo el movimiento',
        'Imagina verter agua de una jarra',
        'Peso ligero, ejecución perfecta',
      ],
      erroresComunes: [
        'Elevar los hombros hacia las orejas',
        'Subir más allá de los hombros',
        'Usar impulso del cuerpo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'db_elevacion_frontal',
      nombre: 'Elevación Frontal con Mancuernas',
      descripcion: 'Aislamiento del deltoides anterior.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior],
      musculosSecundarios: [MuscleGroup.pectoralMayor],
      instrucciones: [
        'De pie con mancuernas frente a los muslos',
        'Eleva un brazo o ambos al frente',
        'Sube hasta la altura de los hombros',
        'Baja controladamente',
      ],
      tips: [
        'Alternando permite mejor control',
        'Mantén el core activo para no balancearte',
        'Palmas hacia abajo o neutras',
      ],
      erroresComunes: [
        'Usar impulso del cuerpo',
        'Subir más allá de los hombros',
        'Arquear la espalda',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_pajaros',
      nombre: 'Pájaros / Elevación Posterior',
      descripcion: 'Aislamiento del deltoides posterior, fundamental para hombros completos.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.deltoidesPosterior],
      musculosSecundarios: [MuscleGroup.romboides, MuscleGroup.trapecios],
      instrucciones: [
        'Inclinado hacia adelante, espalda recta',
        'Mancuernas colgando, brazos casi extendidos',
        'Eleva los brazos lateralmente (alas de pájaro)',
        'Aprieta los omóplatos arriba',
        'Baja controladamente',
      ],
      tips: [
        'Puede hacerse sentado en banco inclinado',
        'Codos ligeramente flexionados',
        'Aprieta los omóplatos juntos arriba',
      ],
      erroresComunes: [
        'No inclinarse lo suficiente',
        'Usar impulso',
        'Levantar el torso durante el movimiento',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 28: EJERCICIOS CON MANCUERNAS - BRAZO
    // =========================================================================

    ExerciseModel(
      id: 'db_curl_biceps',
      nombre: 'Curl de Bíceps con Mancuernas',
      descripcion: 'Ejercicio clásico para desarrollo de bíceps.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      instrucciones: [
        'De pie con mancuernas a los lados, palmas al frente',
        'Codos pegados al cuerpo',
        'Flexiona los brazos subiendo las mancuernas',
        'Aprieta el bíceps arriba',
        'Baja controladamente',
      ],
      tips: [
        'Los codos no se mueven durante el curl',
        'Alternando o simultáneo',
        'Supina la muñeca para más activación',
      ],
      erroresComunes: [
        'Balancear el cuerpo para ayudarse',
        'Mover los codos hacia adelante',
        'Bajar demasiado rápido',
      ],
      variaciones: ['Martillo', 'Alternado', 'Concentrado'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'db_curl_martillo',
      nombre: 'Curl Martillo con Mancuernas',
      descripcion: 'Variante de curl con agarre neutro para braquial y antebrazos.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.biceps, MuscleGroup.antebrazos],
      musculosSecundarios: [],
      instrucciones: [
        'De pie con mancuernas a los lados, palmas mirándose',
        'Mantén el agarre neutro durante todo el movimiento',
        'Flexiona llevando las mancuernas hacia los hombros',
        'Los pulgares apuntan hacia arriba',
      ],
      tips: [
        'El agarre neutro trabaja más el braquial',
        'Mayor énfasis en antebrazos',
        'Puedes usar más peso que curl tradicional',
      ],
      erroresComunes: [
        'Rotar las muñecas durante el movimiento',
        'Usar impulso del cuerpo',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_extension_triceps',
      nombre: 'Extensión de Tríceps con Mancuerna',
      descripcion: 'Extensión sobre la cabeza para desarrollo del tríceps.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.triceps],
      musculosSecundarios: [],
      instrucciones: [
        'Sentado o de pie, una mancuerna sobre la cabeza',
        'Sostén con ambas manos la parte superior de la mancuerna',
        'Baja la mancuerna detrás de la cabeza flexionando codos',
        'Extiende los brazos volviendo a la posición inicial',
      ],
      tips: [
        'Codos apuntan al techo y no se mueven',
        'Baja hasta sentir el estiramiento',
        'Puede hacerse a una o dos manos',
      ],
      erroresComunes: [
        'Codos abriéndose hacia afuera',
        'Mover los hombros/brazos superiores',
        'No completar la extensión',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Controlar el peso sobre la cabeza'],
      ),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'db_patada_triceps',
      nombre: 'Patada de Tríceps con Mancuerna',
      descripcion: 'Extensión de tríceps inclinado para aislamiento de la cabeza lateral.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 45,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.triceps],
      musculosSecundarios: [],
      instrucciones: [
        'Apoya una mano y rodilla en el banco',
        'Brazo de trabajo paralelo al suelo, codo flexionado',
        'Extiende el brazo hacia atrás (patada)',
        'Aprieta el tríceps en extensión completa',
        'Flexiona volviendo a la posición inicial',
      ],
      tips: [
        'El brazo superior permanece inmóvil',
        'Aprieta fuerte arriba',
        'Usa peso ligero para buena forma',
      ],
      erroresComunes: [
        'Mover todo el brazo en lugar de solo el antebrazo',
        'No extender completamente',
        'Usar demasiado peso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      equipamientoAdicional: 'Banco plano',
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 29: EJERCICIOS CON MANCUERNAS - PIERNA
    // =========================================================================

    ExerciseModel(
      id: 'db_sentadilla_goblet',
      nombre: 'Sentadilla Goblet',
      descripcion: 'Sentadilla sosteniendo una mancuerna frente al pecho. Ideal para aprender el patrón.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 90,
      tipoMovimiento: MovementType.sentadilla,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.core, MuscleGroup.isquiotibiales],
      instrucciones: [
        'Sostén una mancuerna verticalmente frente al pecho',
        'Pies a la anchura de hombros o más',
        'Baja manteniendo el torso vertical',
        'Codos entre las rodillas en la posición baja',
        'Sube empujando a través de los talones',
      ],
      tips: [
        'Excelente para aprender el patrón de sentadilla',
        'El contrapeso ayuda a mantener el torso vertical',
        'Permite profundidad sin caer hacia adelante',
      ],
      erroresComunes: [
        'Inclinarse hacia adelante',
        'Rodillas colapsando hacia adentro',
        'No bajar lo suficiente',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 3010,
    ),

    ExerciseModel(
      id: 'db_zancada',
      nombre: 'Zancadas con Mancuernas',
      descripcion: 'Zancadas caminando o estáticas con mancuernas para piernas y glúteos.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 90,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.core],
      instrucciones: [
        'De pie con mancuernas a los lados',
        'Da un paso largo hacia adelante',
        'Baja hasta que la rodilla trasera casi toque el suelo',
        'Empuja con la pierna delantera para volver',
        'Alterna piernas o haz todas de un lado',
      ],
      tips: [
        'Mantén el torso vertical',
        'Rodilla delantera no pasa la punta del pie',
        'Paso largo para más glúteos, corto para más cuádriceps',
      ],
      erroresComunes: [
        'Inclinarse hacia adelante',
        'Paso demasiado corto',
        'Rodilla delantera muy adelante',
      ],
      variaciones: ['Estáticas', 'Caminando', 'Reversas', 'Laterales'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'db_peso_muerto_rumano',
      nombre: 'Peso Muerto Rumano con Mancuernas',
      descripcion: 'Peso muerto con piernas semi-rígidas para isquiotibiales y glúteos.',
      machineId: 'dumbbell_rack',
      machineName: 'Rack de Mancuernas',
      categoria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      restSeconds: 90,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.isquiotibiales, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.erectoresEspinales],
      instrucciones: [
        'De pie con mancuernas frente a los muslos',
        'Rodillas ligeramente flexionadas (posición fija)',
        'Empuja la cadera hacia atrás bajando el torso',
        'Mancuernas bajan cerca de las piernas',
        'Siente el estiramiento en isquiotibiales',
        'Vuelve contrayendo glúteos',
      ],
      tips: [
        'La flexión de rodilla no cambia durante el movimiento',
        'La espalda permanece recta siempre',
        'Baja hasta donde la flexibilidad permita',
      ],
      erroresComunes: [
        'Redondear la espalda',
        'Flexionar demasiado las rodillas (convertirlo en squat)',
        'No empujar la cadera hacia atrás',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener espalda recta'],
      ),
      tempoRecomendado: 3010,
    ),

    // =========================================================================
    // SECCIÓN 30: EJERCICIOS CON BARRA - COMPUESTOS PRINCIPALES
    // =========================================================================

    ExerciseModel(
      id: 'bb_press_banca',
      nombre: 'Press de Banca con Barra',
      descripcion: 'El ejercicio rey para el pecho. Fundamental para fuerza y masa del tren superior.',
      machineId: 'barra_olimpica',
      machineName: 'Barra Olímpica (20 kg)',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 40,
      restSeconds: 180,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Acuéstate en el banco con ojos bajo la barra',
        'Agarre ligeramente más ancho que los hombros',
        'Retrae los omóplatos y arquea ligeramente',
        'Desrackea la barra y posiciónala sobre el pecho',
        'Baja hasta tocar el pecho (parte baja del esternón)',
        'Empuja hacia arriba y ligeramente hacia atrás',
      ],
      tips: [
        'Los pies firmes en el suelo',
        'Trayectoria de la barra: diagonal, no vertical',
        'Mantén los glúteos en contacto con el banco',
      ],
      erroresComunes: [
        'Rebotar la barra en el pecho',
        'Trayectoria vertical de la barra',
        'Levantar los glúteos del banco',
        'Agarre demasiado ancho o estrecho',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: true,
        highInjuryRisk: true,
        precauciones: ['Siempre usar spotter con cargas pesadas', 'Usar collares'],
      ),
      equipamientoAdicional: 'Banco plano, collares, discos',
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'bb_peso_muerto',
      nombre: 'Peso Muerto Convencional',
      descripcion: 'El ejercicio más completo para fuerza posterior. Trabaja prácticamente todo el cuerpo.',
      machineId: 'barra_olimpica',
      machineName: 'Barra Olímpica (20 kg)',
      categoria: MachineCategory.espalda,
      categoriaSecundaria: MachineCategory.pierna,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 5,
      defaultWeight: 60,
      restSeconds: 180,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.erectoresEspinales, MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.cuadriceps, MuscleGroup.dorsales, MuscleGroup.trapecios, MuscleGroup.antebrazos, MuscleGroup.core],
      instrucciones: [
        'Barra sobre la mitad del pie, pies a la anchura de caderas',
        'Agarra la barra justo fuera de las piernas',
        'Baja la cadera, pecho arriba, espalda recta',
        'Activa los dorsales tirando la barra hacia ti',
        'Empuja el suelo con los pies mientras extiendes caderas',
        'Bloquea arriba con glúteos contraídos',
      ],
      tips: [
        'La barra debe mantenerse pegada al cuerpo',
        'Piensa en empujar el suelo, no en tirar la barra',
        'Inhala y activa el core antes de cada rep',
      ],
      erroresComunes: [
        'Redondear la espalda',
        'Barra alejada del cuerpo',
        'Hiperextender la espalda arriba',
        'Levantar primero las caderas (sentadilla mañanera)',
      ],
      variaciones: ['Sumo', 'Déficit', 'Rack pull'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: true,
        precauciones: ['Dominar técnica antes de subir peso', 'Usar cinturón en cargas pesadas'],
        contraindicaciones: ['Lesiones de espalda baja activas'],
      ),
      equipamientoAdicional: 'Cinturón de levantamiento, tiza',
      tempoRecomendado: 1010,
    ),

    ExerciseModel(
      id: 'bb_remo_inclinado',
      nombre: 'Remo con Barra Inclinado',
      descripcion: 'Remo para desarrollo de espalda media y dorsales.',
      machineId: 'barra_olimpica',
      machineName: 'Barra Olímpica (20 kg)',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 10,
      defaultWeight: 40,
      restSeconds: 120,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.trapecios, MuscleGroup.erectoresEspinales],
      instrucciones: [
        'De pie con la barra, inclínate hasta que el torso esté casi paralelo al suelo',
        'Rodillas ligeramente flexionadas',
        'Agarre prono ligeramente más ancho que los hombros',
        'Tira la barra hacia el abdomen inferior',
        'Aprieta los omóplatos juntos arriba',
        'Baja controladamente',
      ],
      tips: [
        'Mantén la espalda recta durante todo el movimiento',
        'Piensa en tirar con los codos',
        'El ángulo del torso afecta qué músculos trabajan más',
      ],
      erroresComunes: [
        'Usar impulso del cuerpo',
        'Torso muy vertical (menos dorsales)',
        'Redondear la espalda',
      ],
      variaciones: ['Agarre supino', 'Pendlay row', 'T-bar row'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener espalda recta'],
      ),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'bb_press_militar',
      nombre: 'Press Militar con Barra',
      descripcion: 'Press de hombros de pie para desarrollo de deltoides y estabilidad del core.',
      machineId: 'barra_olimpica',
      machineName: 'Barra Olímpica (20 kg)',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.hombre,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 30,
      restSeconds: 120,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.deltoidesLateral],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.trapecios, MuscleGroup.core],
      instrucciones: [
        'Barra en posición de rack frontal sobre clavículas',
        'Pies a la anchura de caderas',
        'Core y glúteos apretados',
        'Empuja la barra verticalmente pasando la cara',
        'Bloquea arriba con la barra sobre la cabeza',
        'Baja controladamente a la posición inicial',
      ],
      tips: [
        'Mueve la cabeza hacia atrás y adelante, no la barra',
        'Mantén el core muy activo',
        'La barra sube en línea recta',
      ],
      erroresComunes: [
        'Inclinarse hacia atrás (press inclinado)',
        'No bloquear completamente arriba',
        'Usar las piernas para impulso (push press)',
      ],
      variaciones: ['Push press', 'Press sentado'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener core activo', 'No hiperextender'],
      ),
      tempoRecomendado: 2010,
    ),

    // =========================================================================
    // SECCIÓN 31: EJERCICIOS CON BARRA Z
    // =========================================================================

    ExerciseModel(
      id: 'ez_curl_biceps',
      nombre: 'Curl de Bíceps con Barra Z',
      descripcion: 'Curl de bíceps con barra curva que reduce el estrés en muñecas.',
      machineId: 'barra_z',
      machineName: 'Barra Z / EZ Curl',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      instrucciones: [
        'De pie con agarre en la curva interior de la barra',
        'Codos pegados al cuerpo',
        'Flexiona los brazos subiendo la barra',
        'Aprieta los bíceps arriba',
        'Baja controladamente',
      ],
      tips: [
        'La curvatura reduce el estrés en muñecas',
        'Puedes usar más peso que con barra recta',
        'Agarre interno para más bíceps, externo para más braquial',
      ],
      erroresComunes: [
        'Balancear el cuerpo',
        'Mover los codos hacia adelante',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'ez_skull_crusher',
      nombre: 'Rompecráneos con Barra Z',
      descripcion: 'Extensión de tríceps acostado. Uno de los mejores ejercicios para masa de tríceps.',
      machineId: 'barra_z',
      machineName: 'Barra Z / EZ Curl',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.triceps],
      musculosSecundarios: [],
      instrucciones: [
        'Acostado en banco, barra extendida sobre el pecho',
        'Brazos verticales o ligeramente inclinados hacia atrás',
        'Baja la barra flexionando los codos hacia la frente',
        'Los codos apuntan al techo y no se mueven',
        'Extiende los brazos volviendo a la posición inicial',
      ],
      tips: [
        'Baja hacia la frente, no hacia la nariz',
        'Ligera inclinación de brazos hacia atrás aumenta la tensión',
        'La barra Z es más cómoda que la recta',
      ],
      erroresComunes: [
        'Codos abriéndose hacia afuera',
        'Mover los brazos superiores',
        'Bajar hacia la nariz (peligroso)',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: false,
        precauciones: ['Control del peso sobre la cara'],
      ),
      equipamientoAdicional: 'Banco plano',
      tempoRecomendado: 2011,
    ),

    // =========================================================================
    // SECCIÓN 32: EJERCICIOS CON BARRA HEXAGONAL
    // =========================================================================

    ExerciseModel(
      id: 'hex_peso_muerto',
      nombre: 'Peso Muerto con Barra Hexagonal',
      descripcion: 'Peso muerto con agarre neutral. Menos estrés en espalda baja que convencional.',
      machineId: 'barra_hexagonal',
      machineName: 'Barra Hexagonal / Trap Bar',
      categoria: MachineCategory.pierna,
      categoriaSecundaria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 8,
      defaultWeight: 60,
      restSeconds: 150,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.trapecios, MuscleGroup.erectoresEspinales, MuscleGroup.antebrazos],
      instrucciones: [
        'Entra dentro del hexágono',
        'Pies a la anchura de caderas',
        'Agarra las manijas con agarre neutral',
        'Baja la cadera, pecho arriba',
        'Empuja el suelo y levanta',
        'Bloquea caderas arriba',
      ],
      tips: [
        'El centro de gravedad está dentro del cuerpo (más seguro)',
        'Más trabajo de cuádriceps que peso muerto convencional',
        'Ideal para principiantes en peso muerto',
      ],
      erroresComunes: [
        'Redondear la espalda',
        'Inclinarse hacia adelante o atrás',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener espalda recta'],
      ),
      tempoRecomendado: 1010,
    ),

    ExerciseModel(
      id: 'hex_encogimientos',
      nombre: 'Encogimientos con Barra Hexagonal',
      descripcion: 'Encogimientos de trapecios con barra hexagonal. Agarre neutral y posición cómoda.',
      machineId: 'barra_hexagonal',
      machineName: 'Barra Hexagonal / Trap Bar',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.hombre,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 50,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.trapecios],
      musculosSecundarios: [],
      instrucciones: [
        'De pie dentro de la barra hexagonal',
        'Brazos extendidos a los lados',
        'Eleva los hombros hacia las orejas',
        'Mantén la contracción arriba',
        'Baja controladamente',
      ],
      tips: [
        'El agarre neutral es más cómodo para los hombros',
        'No rotar los hombros (sube y baja vertical)',
        'Sostén la contracción arriba 1-2 segundos',
      ],
      erroresComunes: [
        'Rotar los hombros (innecesario)',
        'Flexionar los codos',
        'Usar impulso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2012,
    ),

    // =========================================================================
    // SECCIÓN 33: EJERCICIOS DE CARDIO
    // =========================================================================

    ExerciseModel(
      id: 'cardio_caminadora_intervalos',
      nombre: 'Intervalos en Caminadora',
      descripcion: 'Entrenamiento de intervalos alternando velocidades para mayor quema calórica.',
      machineId: 'treadmill',
      machineName: 'Caminadora',
      categoria: MachineCategory.cardio,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 8,
      defaultReps: 1,
      restSeconds: 60,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.isquiotibiales, MuscleGroup.pantorrillas],
      musculosSecundarios: [MuscleGroup.gluteos, MuscleGroup.core],
      instrucciones: [
        'Calienta 5 minutos caminando',
        'Alterna 30 segundos de sprint con 60 segundos caminando',
        'Repite los intervalos 8-10 veces',
        'Enfría 5 minutos caminando',
      ],
      tips: [
        'HIIT quema más calorías en menos tiempo',
        'Ajusta la intensidad a tu nivel',
        'Puedes agregar inclinación para mayor dificultad',
      ],
      erroresComunes: [
        'Saltarse el calentamiento',
        'Intervalos de alta intensidad demasiado largos al inicio',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Usar clip de seguridad', 'Calentamiento adecuado'],
      ),
    ),

    ExerciseModel(
      id: 'cardio_bicicleta_resistencia',
      nombre: 'Ciclismo de Resistencia',
      descripcion: 'Sesión de ciclismo estático para resistencia cardiovascular.',
      machineId: 'stationary_bike',
      machineName: 'Bicicleta Estática',
      categoria: MachineCategory.cardio,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 1,
      defaultReps: 30,
      restSeconds: 0,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.gluteos],
      instrucciones: [
        'Ajusta la altura del asiento (pierna casi extendida abajo)',
        'Mantén una cadencia constante de 70-90 RPM',
        'Ajusta la resistencia para mantener esfuerzo moderado',
        'Mantén la postura erguida',
      ],
      tips: [
        'Bajo impacto, ideal para recuperación activa',
        'Aumenta resistencia gradualmente',
        'Hidrátate durante la sesión',
      ],
      erroresComunes: [
        'Asiento demasiado bajo o alto',
        'Resistencia muy baja (pedaleo ineficiente)',
        'Postura encorvada',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
    ),

    ExerciseModel(
      id: 'cardio_remo_intervalos',
      nombre: 'Intervalos en Remo',
      descripcion: 'Entrenamiento de intervalos en máquina de remo para cardio de cuerpo completo.',
      machineId: 'rowing_machine',
      machineName: 'Máquina de Remo Cardio',
      categoria: MachineCategory.cardio,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 6,
      defaultReps: 1,
      restSeconds: 60,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.cuadriceps],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.core, MuscleGroup.gluteos],
      instrucciones: [
        'Calienta 3-5 minutos a ritmo suave',
        'Rema fuerte 500m o 2 minutos',
        'Recupera remando suave 1-2 minutos',
        'Repite 6-8 intervalos',
        'Enfría 3-5 minutos suave',
      ],
      tips: [
        'Secuencia correcta: piernas, core, brazos (tirón) / brazos, core, piernas (regreso)',
        'La potencia viene principalmente de las piernas',
        'Mantén la espalda recta',
      ],
      erroresComunes: [
        'Tirar solo con los brazos',
        'Espalda redondeada',
        'Apresurarse en la recuperación',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Mantener espalda recta', 'Técnica antes de intensidad'],
      ),
    ),

    ExerciseModel(
      id: 'cardio_eliptica',
      nombre: 'Entrenamiento en Elíptica',
      descripcion: 'Ejercicio cardiovascular de bajo impacto que trabaja todo el cuerpo.',
      machineId: 'elliptical',
      machineName: 'Elíptica',
      categoria: MachineCategory.cardio,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 1,
      defaultReps: 30,
      restSeconds: 0,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.isquiotibiales, MuscleGroup.pantorrillas, MuscleGroup.core],
      instrucciones: [
        'Sube a la máquina y agarra las manijas móviles',
        'Comienza a pedalear con un movimiento fluido',
        'Mantén la espalda recta y el core activo',
        'Ajusta la resistencia según tu nivel',
        'Mantén una cadencia constante de 60-80 RPM',
      ],
      tips: [
        'Bajo impacto, ideal para articulaciones sensibles',
        'Trabaja brazos y piernas simultáneamente',
        'Aumenta la inclinación para mayor intensidad en glúteos',
      ],
      erroresComunes: [
        'Apoyarse demasiado en las manijas fijas',
        'Cadencia muy rápida con poca resistencia',
        'Postura encorvada',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
    ),

    ExerciseModel(
      id: 'cardio_step_stepper',
      nombre: 'Entrenamiento en Step/Stepper',
      descripcion: 'Ejercicio de escalones para fortalecer piernas y mejorar resistencia cardiovascular.',
      machineId: 'step_stepper',
      machineName: 'Step/Stepper',
      categoria: MachineCategory.cardio,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 1,
      defaultReps: 20,
      restSeconds: 0,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.core],
      instrucciones: [
        'Sube a la máquina y agarra las manijas para estabilidad',
        'Comienza a pisar alternando los pies',
        'Mantén un ritmo constante y controlado',
        'Ajusta la resistencia según tu nivel',
        'No bloquees las rodillas al extender',
      ],
      tips: [
        'Excelente para tonificar glúteos y piernas',
        'Mayor quema calórica que la caminadora plana',
        'Simula subir escaleras de forma continua',
      ],
      erroresComunes: [
        'Apoyarse demasiado en las manijas',
        'Pasos muy cortos que reducen efectividad',
        'Velocidad excesiva sin control',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
    ),

    // =========================================================================
    // SECCIÓN 34: EJERCICIOS FUNCIONALES
    // =========================================================================

    ExerciseModel(
      id: 'battle_ropes_ondas',
      nombre: 'Ondas con Cuerdas de Batalla',
      descripcion: 'Ejercicio de alta intensidad con cuerdas pesadas para acondicionamiento.',
      machineId: 'battle_ropes',
      machineName: 'Cuerdas de Batalla',
      categoria: MachineCategory.functional,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 30,
      restSeconds: 60,
      tipoMovimiento: MovementType.cardio,
      musculosPrincipales: [MuscleGroup.deltoidesAnterior, MuscleGroup.core],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.triceps, MuscleGroup.antebrazos],
      instrucciones: [
        'Agarra un extremo de cada cuerda',
        'Posición atlética: rodillas flexionadas, core activo',
        'Crea ondas alternando los brazos arriba y abajo',
        'Mantén la intensidad por el tiempo especificado',
      ],
      tips: [
        'Las ondas deben llegar hasta el punto de anclaje',
        'Mantén el core activado para proteger la espalda',
        'Varía entre ondas alternas, simultáneas y slams',
      ],
      erroresComunes: [
        'Ondas muy pequeñas que no viajan',
        'Perder la postura atlética',
        'Aguantar la respiración',
      ],
      variaciones: ['Ondas alternas', 'Ondas simultáneas', 'Slams', 'Círculos'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
    ),

    ExerciseModel(
      id: 'kettlebell_swing',
      nombre: 'Swing con Kettlebell',
      descripcion: 'Movimiento explosivo de bisagra de cadera con kettlebell.',
      machineId: 'kettlebell_station',
      machineName: 'Estación de Kettlebells',
      categoria: MachineCategory.functional,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.bisagra,
      musculosPrincipales: [MuscleGroup.gluteos, MuscleGroup.isquiotibiales],
      musculosSecundarios: [MuscleGroup.core, MuscleGroup.deltoidesAnterior, MuscleGroup.antebrazos],
      instrucciones: [
        'Pies más anchos que los hombros',
        'Kettlebell entre las piernas o ligeramente adelante',
        'Bisagra de cadera: empuja la cadera hacia atrás',
        'Explosión de cadera hacia adelante, swinging la KB',
        'Brazos extendidos, KB llega hasta los hombros o más',
        'Deja que la KB caiga, controlando con las caderas',
      ],
      tips: [
        'El poder viene de las caderas, no de los brazos',
        'Aprieta los glúteos fuerte en la extensión',
        'Mantén la espalda recta siempre',
      ],
      erroresComunes: [
        'Levantar con los brazos en lugar de las caderas',
        'Sentadilla en lugar de bisagra',
        'Redondear la espalda',
      ],
      variaciones: ['American swing', 'One-arm swing', 'Alternating'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Dominar la bisagra de cadera primero'],
      ),
    ),

    ExerciseModel(
      id: 'trx_remo',
      nombre: 'Remo con TRX',
      descripcion: 'Remo horizontal usando el peso corporal con correas de suspensión.',
      machineId: 'trx_suspension',
      machineName: 'TRX Suspensión',
      categoria: MachineCategory.espalda,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.dorsales, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.biceps, MuscleGroup.core],
      instrucciones: [
        'Agarra las manijas con brazos extendidos',
        'Inclínate hacia atrás manteniendo el cuerpo recto',
        'Cuanto más horizontal, más difícil',
        'Tira del cuerpo hacia las manijas',
        'Aprieta los omóplatos arriba',
        'Baja controladamente',
      ],
      tips: [
        'Mantén el cuerpo completamente recto (como una tabla)',
        'Acerca los pies al punto de anclaje para más dificultad',
        'Excelente para principiantes en dominadas',
      ],
      erroresComunes: [
        'Caderas cayendo o subiendo',
        'Tirar solo con los brazos',
        'Rango de movimiento incompleto',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'trx_push_up',
      nombre: 'Flexiones con TRX',
      descripcion: 'Flexiones con pies en las correas para mayor inestabilidad y activación del core.',
      machineId: 'trx_suspension',
      machineName: 'TRX Suspensión',
      categoria: MachineCategory.pecho,
      nivel: DifficultyLevel.avanzado,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      restSeconds: 60,
      tipoMovimiento: MovementType.empuje,
      musculosPrincipales: [MuscleGroup.pectoralMayor, MuscleGroup.core],
      musculosSecundarios: [MuscleGroup.triceps, MuscleGroup.deltoidesAnterior],
      instrucciones: [
        'Coloca los pies en los estribos del TRX',
        'Posición de plancha con manos en el suelo',
        'Baja el pecho hacia el suelo',
        'El core debe trabajar para mantener estabilidad',
        'Empuja hacia arriba',
      ],
      tips: [
        'La inestabilidad incrementa dramáticamente la dificultad',
        'Mantén el core muy activo para no balancearte',
        'Comienza con las correas más largas (más fácil)',
      ],
      erroresComunes: [
        'Caderas cayendo o subiendo',
        'Perder el control por falta de estabilidad',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        precauciones: ['Dominar flexiones regulares primero'],
      ),
      tempoRecomendado: 2010,
    ),

    ExerciseModel(
      id: 'box_jump',
      nombre: 'Salto al Cajón',
      descripcion: 'Salto pliométrico para desarrollo de potencia explosiva del tren inferior.',
      machineId: 'plyo_box',
      machineName: 'Caja Pliométrica',
      categoria: MachineCategory.functional,
      categoriaSecundaria: MachineCategory.pierna,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 4,
      defaultReps: 8,
      restSeconds: 90,
      tipoMovimiento: MovementType.pliometrico,
      musculosPrincipales: [MuscleGroup.cuadriceps, MuscleGroup.gluteos],
      musculosSecundarios: [MuscleGroup.pantorrillas, MuscleGroup.core],
      instrucciones: [
        'De pie frente a la caja a distancia de un paso',
        'Posición atlética, brazos atrás',
        'Salta explosivamente usando brazos y piernas',
        'Aterriza suavemente con ambos pies en la caja',
        'Extiende las caderas arriba',
        'Baja caminando (no saltar hacia abajo)',
      ],
      tips: [
        'Aterriza suavemente, no con ruido',
        'Comienza con altura baja y progresa',
        'Baja caminando para proteger las articulaciones',
      ],
      erroresComunes: [
        'Aterrizar con rodillas colapsando',
        'Saltar hacia abajo (alto impacto)',
        'Altura excesiva sin técnica',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(
        requiresSpotter: false,
        highInjuryRisk: false,
        precauciones: ['Bajar caminando', 'Aterrizar suave'],
        contraindicaciones: ['Problemas de rodilla'],
      ),
    ),

    // =========================================================================
    // SECCIÓN 35: EJERCICIOS DE CABLE MULTIUSOS
    // =========================================================================

    ExerciseModel(
      id: 'cable_triceps_pushdown',
      nombre: 'Extensión de Tríceps en Polea',
      descripcion: 'Extensión de tríceps con cable. Tensión constante durante todo el movimiento.',
      machineId: 'multi_gym',
      machineName: 'Estación de Cables Multiusos',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 20,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.triceps],
      musculosSecundarios: [],
      instrucciones: [
        'Polea alta con barra recta o en V',
        'Codos pegados al cuerpo',
        'Extiende los brazos empujando hacia abajo',
        'Aprieta los tríceps en la extensión completa',
        'Regresa controladamente',
      ],
      tips: [
        'Los codos no se mueven durante el ejercicio',
        'Mantén el torso ligeramente inclinado',
        'Usa cuerda para mayor rango de movimiento',
      ],
      erroresComunes: [
        'Mover los codos hacia adelante y atrás',
        'Usar impulso del cuerpo',
        'Rango de movimiento incompleto',
      ],
      variaciones: ['Con cuerda', 'Agarre inverso', 'Un brazo'],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'cable_curl_biceps',
      nombre: 'Curl de Bíceps en Polea',
      descripcion: 'Curl de bíceps con cable para tensión constante.',
      machineId: 'multi_gym',
      machineName: 'Estación de Cables Multiusos',
      categoria: MachineCategory.brazo,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 12,
      defaultWeight: 15,
      restSeconds: 60,
      tipoMovimiento: MovementType.aislamiento,
      musculosPrincipales: [MuscleGroup.biceps],
      musculosSecundarios: [MuscleGroup.antebrazos],
      instrucciones: [
        'Polea baja con barra recta o manija',
        'Codos pegados al cuerpo',
        'Flexiona los brazos subiendo el peso',
        'Aprieta el bíceps arriba',
        'Baja controladamente',
      ],
      tips: [
        'El cable mantiene tensión en todo el rango',
        'Excelente para finalizador de bíceps',
        'Prueba desde polea alta para variedad',
      ],
      erroresComunes: [
        'Balancear el cuerpo',
        'Mover los codos',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2011,
    ),

    ExerciseModel(
      id: 'cable_face_pull',
      nombre: 'Face Pull con Cable',
      descripcion: 'Tirón hacia la cara para deltoides posterior y salud de hombros.',
      machineId: 'multi_gym',
      machineName: 'Estación de Cables Multiusos',
      categoria: MachineCategory.hombro,
      nivel: DifficultyLevel.principiante,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 15,
      defaultWeight: 12,
      restSeconds: 60,
      tipoMovimiento: MovementType.tiron,
      musculosPrincipales: [MuscleGroup.deltoidesPosterior, MuscleGroup.romboides],
      musculosSecundarios: [MuscleGroup.trapecios],
      instrucciones: [
        'Polea alta con cuerda',
        'Agarra los extremos de la cuerda',
        'Tira hacia la cara separando los extremos',
        'Codos altos, rotación externa en la posición final',
        'Aprieta los omóplatos',
        'Regresa controladamente',
      ],
      tips: [
        'Excelente para salud de hombros',
        'Incluir en cada sesión de tren superior',
        'Piensa en rotar externamente los hombros',
      ],
      erroresComunes: [
        'Codos demasiado bajos (se convierte en remo)',
        'No separar la cuerda al final',
        'Usar demasiado peso',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2012,
    ),

    ExerciseModel(
      id: 'cable_pallof_press',
      nombre: 'Pallof Press con Cable',
      descripcion: 'Ejercicio anti-rotación para estabilidad del core.',
      machineId: 'multi_gym',
      machineName: 'Estación de Cables Multiusos',
      categoria: MachineCategory.core,
      nivel: DifficultyLevel.intermedio,
      genero: RoutineGender.unisex,
      defaultSets: 3,
      defaultReps: 10,
      defaultWeight: 10,
      restSeconds: 60,
      tipoMovimiento: MovementType.isometrico,
      musculosPrincipales: [MuscleGroup.core, MuscleGroup.oblicuos],
      musculosSecundarios: [MuscleGroup.transversoAbdominal],
      instrucciones: [
        'Polea a la altura del pecho, de pie perpendicular',
        'Agarra la manija con ambas manos frente al pecho',
        'Extiende los brazos al frente resistiendo la rotación',
        'Mantén la posición 2-3 segundos',
        'Regresa las manos al pecho',
        'Repite y luego cambia de lado',
      ],
      tips: [
        'El core trabaja para resistir la rotación',
        'Mantén las caderas y hombros al frente',
        'Excelente para prevención de lesiones',
      ],
      erroresComunes: [
        'Permitir que el cuerpo rote',
        'Usar demasiado peso',
        'No mantener la posición extendida',
      ],
      animacion: ExerciseAnimation(status: AnimationStatus.pendiente),
      seguridad: SafetyIndicators(requiresSpotter: false),
      tempoRecomendado: 2020,
    ),
  ];

  // ===========================================================================
  // MÉTODOS DE ACCESO Y BÚSQUEDA
  // ===========================================================================

  /// Obtener ejercicios por máquina
  static List<ExerciseModel> getByMachine(String machineId) {
    return allExercises.where((e) => e.machineId == machineId).toList();
  }

  /// Obtener ejercicio por ID
  static ExerciseModel? getById(String id) {
    try {
      return allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtener el primer ejercicio para una máquina por su ID o nombre
  /// Útil para obtener las instrucciones del ejercicio
  static ExerciseModel? getExerciseForMachine(String machineIdOrName) {
    try {
      // Primero buscar por machineId
      final byId = allExercises.firstWhere(
        (e) => e.machineId == machineIdOrName,
      );
      return byId;
    } catch (_) {
      // Si no encuentra por ID, buscar por nombre de máquina
      try {
        return allExercises.firstWhere(
          (e) => e.machineName.toLowerCase() == machineIdOrName.toLowerCase(),
        );
      } catch (_) {
        // Buscar coincidencia parcial en nombre
        try {
          return allExercises.firstWhere(
            (e) => e.machineName.toLowerCase().contains(machineIdOrName.toLowerCase()) ||
                   machineIdOrName.toLowerCase().contains(e.machineName.toLowerCase()),
          );
        } catch (_) {
          return null;
        }
      }
    }
  }

  /// Obtener ejercicios por categoría
  static List<ExerciseModel> getByCategory(MachineCategory category) {
    return allExercises
        .where((e) => e.categoria == category || e.categoriaSecundaria == category)
        .toList();
  }

  /// Obtener ejercicios por nivel de dificultad
  static List<ExerciseModel> getByLevel(DifficultyLevel level) {
    return allExercises.where((e) => e.nivel == level).toList();
  }

  /// Obtener ejercicios por género objetivo
  /// Si se selecciona unisex, devuelve TODOS los ejercicios (74)
  /// Si se selecciona hombre o mujer, devuelve los específicos + unisex
  static List<ExerciseModel> getByGender(RoutineGender gender) {
    // Unisex = mostrar todos los 74 ejercicios
    if (gender == RoutineGender.unisex) {
      return allExercises.toList();
    }
    // Para hombre o mujer, incluir los específicos de ese género + unisex
    return allExercises
        .where((e) => e.genero == gender || e.genero == RoutineGender.unisex)
        .toList();
  }

  /// Obtener ejercicios por grupo muscular principal
  static List<ExerciseModel> getByMuscleGroup(MuscleGroup muscle) {
    return allExercises.where((e) {
      return e.musculosPrincipales?.contains(muscle) == true ||
          e.musculosSecundarios?.contains(muscle) == true;
    }).toList();
  }

  /// Obtener ejercicios por tipo de movimiento
  static List<ExerciseModel> getByMovementType(MovementType type) {
    return allExercises.where((e) => e.tipoMovimiento == type).toList();
  }

  /// Buscar ejercicios por nombre o descripción
  static List<ExerciseModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allExercises
        .where((e) =>
            e.nombre.toLowerCase().contains(lowerQuery) ||
            e.descripcion.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Obtener ejercicios con animación disponible
  static List<ExerciseModel> get withAnimation {
    return allExercises
        .where((e) => e.animacion?.hasAnimation == true)
        .toList();
  }

  /// Obtener ejercicios que requieren spotter
  static List<ExerciseModel> get requiresSpotter {
    return allExercises
        .where((e) => e.seguridad?.requiresSpotter == true)
        .toList();
  }

  /// Total de ejercicios
  static int get totalExercises => allExercises.length;

  /// Conteo por categoría
  static Map<MachineCategory, int> get countByCategory {
    final counts = <MachineCategory, int>{};
    for (final category in MachineCategory.values) {
      counts[category] = getByCategory(category).length;
    }
    return counts;
  }

  /// Conteo por nivel
  static Map<DifficultyLevel, int> get countByLevel {
    final counts = <DifficultyLevel, int>{};
    for (final level in DifficultyLevel.values) {
      counts[level] = getByLevel(level).length;
    }
    return counts;
  }

  /// Conteo por tipo de movimiento
  static Map<MovementType, int> get countByMovementType {
    final counts = <MovementType, int>{};
    for (final type in MovementType.values) {
      counts[type] = getByMovementType(type).length;
    }
    return counts;
  }

  // ===========================================================================
  // MAPEO DE IMÁGENES POR MÁQUINA
  // ===========================================================================

  /// Mapeo de machineId/machineName a la ruta de imagen del asset
  static const Map<String, String> _machineImageMap = {
    // =========================================================================
    // PIERNA - Máquinas y equipamiento para tren inferior
    // =========================================================================
    'prensa_45_grados': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    'Prensa 45 Grados': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    // Alias adicionales para prensa de piernas (compatibilidad con migration_service)
    'leg_press': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    'Prensa de Piernas': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    // Nombres de ejercicios de prensa
    'Prensa 45° Estándar': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    'Prensa 45° Énfasis Glúteos': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    'Prensa 45° Énfasis Cuádriceps': 'assets/images/maquinas/Prensa 45 grados.jpeg',
    'Prensa 45° Pies Juntos': 'assets/images/maquinas/Prensa 45 grados.jpeg',

    // Sentadilla Hack - ambos IDs para compatibilidad
    'hack_squat': 'assets/images/maquinas/Sentadilla Hack.jpeg',
    'sentadilla_hack': 'assets/images/maquinas/Sentadilla Hack.jpeg',
    'Sentadilla Hack': 'assets/images/maquinas/Sentadilla Hack.jpeg',
    // Nombres de ejercicios de Hack Squat
    'Hack Squat Estándar': 'assets/images/maquinas/Sentadilla Hack.jpeg',
    'Hack Squat Pies Altos': 'assets/images/maquinas/Sentadilla Hack.jpeg',

    'sentadilla_pendulo': 'assets/images/maquinas/Sentadilla péndulo.jpeg',
    'Sentadilla Péndulo': 'assets/images/maquinas/Sentadilla péndulo.jpeg',
    // Nombres de ejercicios de péndulo
    'Sentadilla Péndulo Estándar': 'assets/images/maquinas/Sentadilla péndulo.jpeg',
    'Sentadilla Péndulo Profunda': 'assets/images/maquinas/Sentadilla péndulo.jpeg',

    'sentadilla_sissy': 'assets/images/maquinas/Sentadilla sissy.jpeg',
    'Sentadilla Sissy': 'assets/images/maquinas/Sentadilla sissy.jpeg',
    // Nombres de ejercicios de sissy squat
    'Sentadilla Sissy Estándar': 'assets/images/maquinas/Sentadilla sissy.jpeg',
    'Sentadilla Sissy con Peso': 'assets/images/maquinas/Sentadilla sissy.jpeg',
    'smith_machine': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    'Sentadilla en Smith': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    // Alias adicionales para Smith Machine
    'Smith Machine': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    // Nombres de ejercicios en Smith
    'Sentadilla Smith Estándar': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    'Sentadilla Smith Sumo': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    'Sentadilla Smith Pies Adelante': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    'Zancada Smith': 'assets/images/maquinas/Sentadilla en smith.jpeg',
    'squat_rack': 'assets/images/maquinas/Sentadilla libre.jpeg',
    'Rack de Sentadilla Libre': 'assets/images/maquinas/Sentadilla libre.jpeg',
    // Nombres de ejercicios de sentadilla libre
    'Sentadilla Libre con Barra': 'assets/images/maquinas/Sentadilla libre.jpeg',
    'Sentadilla Frontal': 'assets/images/maquinas/Sentadilla libre.jpeg',
    'Sentadilla Libre': 'assets/images/maquinas/Sentadilla libre.jpeg',
    'extension_cuadriceps': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',
    'Extensión de Cuádriceps': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',
    // Nombres de ejercicios de extensión
    'Extensión de Cuádriceps Estándar': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',
    'Extensión de Cuádriceps Unilateral': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',
    'Extensión de Cuádriceps Pies Adentro': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',
    'Extensión de Cuádriceps Pies Afuera': 'assets/images/maquinas/Extensión para cuádriceps.jpeg',

    // Femoral - curl de piernas
    'femoral_sentado': 'assets/images/maquinas/Femoral sentado.jpeg',
    'Femoral Sentado': 'assets/images/maquinas/Femoral sentado.jpeg',
    'Curl de Piernas': 'assets/images/maquinas/Femoral sentado.jpeg',
    // Nombres de ejercicios de femoral sentado
    'Curl Femoral Sentado Estándar': 'assets/images/maquinas/Femoral sentado.jpeg',
    'Curl Femoral Sentado Unilateral': 'assets/images/maquinas/Femoral sentado.jpeg',

    'femoral_acostado': 'assets/images/maquinas/Femoral acostado.jpeg',
    'Femoral Acostado': 'assets/images/maquinas/Femoral acostado.jpeg',
    // Nombres de ejercicios de femoral acostado
    'Curl Femoral Acostado Estándar': 'assets/images/maquinas/Femoral acostado.jpeg',
    'Curl Femoral Acostado Unilateral': 'assets/images/maquinas/Femoral acostado.jpeg',

    // Abductor/Aductor - ambos IDs para compatibilidad
    'abductor_machine': 'assets/images/maquinas/Abducción.jpeg',
    'abductora': 'assets/images/maquinas/Abducción.jpeg',
    'Máquina Abductora': 'assets/images/maquinas/Abducción.jpeg',
    // Nombres de ejercicios de abducción
    'Abducción de Cadera Estándar': 'assets/images/maquinas/Abducción.jpeg',
    'Abducción de Cadera Inclinada': 'assets/images/maquinas/Abducción.jpeg',
    'Abducción': 'assets/images/maquinas/Abducción.jpeg',

    'aductor_machine': 'assets/images/maquinas/Aductor.jpeg',
    'aductora': 'assets/images/maquinas/Aductor.jpeg',
    'Máquina Aductora': 'assets/images/maquinas/Aductor.jpeg',
    // Nombres de ejercicios de aducción
    'Aducción de Cadera Estándar': 'assets/images/maquinas/Aductor.jpeg',
    'Aducción de Cadera con Pausa': 'assets/images/maquinas/Aductor.jpeg',
    'Aducción': 'assets/images/maquinas/Aductor.jpeg',

    // Glúteo
    'glute_kickback': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',
    'patada_gluteo': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',
    'Máquina Patada de Glúteo': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',
    // Nombres de ejercicios de glúteo
    'Patada de Glúteo Estándar': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',
    'Patada de Glúteo con Pausa': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',
    'Kickback de Glúteo': 'assets/images/maquinas/Máquina patada para glúteo.jpeg',

    // =========================================================================
    // PECHO - Press y contractoras
    // =========================================================================
    'chest_press_horizontal': 'assets/images/maquinas/Press de pecho horizontal.jpeg',
    'press_pecho_horizontal': 'assets/images/maquinas/Press de pecho horizontal.jpeg',
    'Press de Pecho Horizontal': 'assets/images/maquinas/Press de pecho horizontal.jpeg',
    // Nombres de ejercicios de press horizontal
    'Press Horizontal Estándar': 'assets/images/maquinas/Press de pecho horizontal.jpeg',
    'Press Horizontal Agarre Cerrado': 'assets/images/maquinas/Press de pecho horizontal.jpeg',

    'chest_press_incline': 'assets/images/maquinas/Press de pecho inclinado.jpeg',
    'press_pecho_inclinado': 'assets/images/maquinas/Press de pecho inclinado.jpeg',
    'Press de Pecho Inclinado': 'assets/images/maquinas/Press de pecho inclinado.jpeg',
    // Nombres de ejercicios de press inclinado
    'Press Inclinado Estándar': 'assets/images/maquinas/Press de pecho inclinado.jpeg',
    'Press Inclinado Agarre Ancho': 'assets/images/maquinas/Press de pecho inclinado.jpeg',

    'chest_press_decline': 'assets/images/maquinas/Press de pecho declinado.jpeg',
    'press_pecho_declinado': 'assets/images/maquinas/Press de pecho declinado.jpeg',
    'Press de Pecho Declinado': 'assets/images/maquinas/Press de pecho declinado.jpeg',
    // Nombres de ejercicios de press declinado
    'Press Declinado Estándar': 'assets/images/maquinas/Press de pecho declinado.jpeg',

    'chest_press_hammer': 'assets/images/maquinas/Press de pecho hammer.jpeg',
    'press_pecho_hammer': 'assets/images/maquinas/Press de pecho hammer.jpeg',
    'Press de Pecho Hammer': 'assets/images/maquinas/Press de pecho hammer.jpeg',
    // Nombres de ejercicios de press hammer
    'Press Hammer Estándar': 'assets/images/maquinas/Press de pecho hammer.jpeg',
    'Press Hammer Unilateral': 'assets/images/maquinas/Press de pecho hammer.jpeg',

    'chest_press_integrated': 'assets/images/maquinas/Press de pecho peso integrado.jpeg',
    'Press de Pecho Peso Integrado': 'assets/images/maquinas/Press de pecho peso integrado.jpeg',

    'pec_fly': 'assets/images/maquinas/Peck fly.jpeg',
    'Pec Fly / Contractora': 'assets/images/maquinas/Peck fly.jpeg',
    // Alias adicionales para compatibilidad
    'Pec Fly': 'assets/images/maquinas/Peck fly.jpeg',
    'Contractora': 'assets/images/maquinas/Peck fly.jpeg',
    'peck_fly': 'assets/images/maquinas/Peck fly.jpeg',
    // Nombres de ejercicios
    'Pec Fly / Aperturas Estándar': 'assets/images/maquinas/Peck fly.jpeg',
    'Pec Fly Isométrico': 'assets/images/maquinas/Peck fly.jpeg',

    'cable_crossover': 'assets/images/maquinas/Cross Over.jpeg',
    'cross_over': 'assets/images/maquinas/Cross Over.jpeg',
    'Cross Over / Cruce de Cables': 'assets/images/maquinas/Cross Over.jpeg',
    // Alias adicionales para Cross Over
    'Cross Over': 'assets/images/maquinas/Cross Over.jpeg',
    'Cruce de Cables': 'assets/images/maquinas/Cross Over.jpeg',
    // Nombres de ejercicios de cables
    'Cross Over Alto': 'assets/images/maquinas/Cross Over.jpeg',
    'Cross Over Medio': 'assets/images/maquinas/Cross Over.jpeg',
    'Cross Over Bajo': 'assets/images/maquinas/Cross Over.jpeg',
    'Cruce de Cables Unilateral': 'assets/images/maquinas/Cross Over.jpeg',

    // =========================================================================
    // ESPALDA - Jalones y remos
    // =========================================================================
    'lat_pulldown_hammer': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    'jalon_hammer': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    'Jalón Hammer para Espalda': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    // Alias adicionales para compatibilidad con rutinas existentes
    'Jalón Hammer': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    'Jalon Hammer': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    // Nombres de ejercicios
    'Jalón Hammer Agarre Neutro': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',
    'Jalón Hammer Unilateral': 'assets/images/maquinas/Jalón hammer para espalda.jpeg',

    'seated_row_machine': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    'remo_maquina': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    'Máquina de Remo para Espalda': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    // Alias adicionales para compatibilidad con rutinas existentes
    'Remo Sentado': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    'Remo en Máquina': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    // Nombres de ejercicios
    'Remo Sentado Agarre Cerrado': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    'Remo Sentado Agarre Ancho': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',
    'Remo Unilateral en Máquina': 'assets/images/maquinas/Máquina de remo para espalda.jpeg',

    'hyperextension': 'assets/images/maquinas/Híper extensión.jpeg',
    'hiperextension': 'assets/images/maquinas/Híper extensión.jpeg',
    'Banco de Hiperextensión': 'assets/images/maquinas/Híper extensión.jpeg',
    // Nombres de ejercicios de hiperextensión
    'Hiperextensión Estándar': 'assets/images/maquinas/Híper extensión.jpeg',
    'Hiperextensión con Rotación': 'assets/images/maquinas/Híper extensión.jpeg',
    'Hiperextensión Inversa': 'assets/images/maquinas/Híper extensión.jpeg',

    // =========================================================================
    // HOMBRO - Press y elevaciones
    // =========================================================================
    'shoulder_press_hammer': 'assets/images/maquinas/Press de hombro Hammer.jpeg',
    'press_hombro_hammer': 'assets/images/maquinas/Press de hombro Hammer.jpeg',
    'Press de Hombro Hammer': 'assets/images/maquinas/Press de hombro Hammer.jpeg',
    // Nombres de ejercicios de press de hombro
    'Press de Hombro Estándar': 'assets/images/maquinas/Press de hombro Hammer.jpeg',
    'Press de Hombro Unilateral': 'assets/images/maquinas/Press de hombro Hammer.jpeg',

    'lateral_raise_machine': 'assets/images/maquinas/Laterales en máquina.jpeg',
    'laterales_maquina': 'assets/images/maquinas/Laterales en máquina.jpeg',
    'Elevaciones Laterales en Máquina': 'assets/images/maquinas/Laterales en máquina.jpeg',
    // Nombres de ejercicios de laterales
    'Elevaciones Laterales Estándar': 'assets/images/maquinas/Laterales en máquina.jpeg',
    'Elevaciones Laterales Unilateral': 'assets/images/maquinas/Laterales en máquina.jpeg',

    // =========================================================================
    // BRAZO - Curl y extensiones
    // =========================================================================
    'preacher_curl_machine': 'assets/images/maquinas/Curl predicador máquina.jpeg',
    'curl_predicador': 'assets/images/maquinas/Curl predicador máquina.jpeg',
    'Curl Predicador en Máquina': 'assets/images/maquinas/Curl predicador máquina.jpeg',
    // Alias adicionales para compatibilidad con rutinas existentes
    'Curl Predicador': 'assets/images/maquinas/Curl predicador máquina.jpeg',
    // Nombres de ejercicios
    'Curl Predicador Estándar': 'assets/images/maquinas/Curl predicador máquina.jpeg',
    'Curl Predicador Agarre Inverso': 'assets/images/maquinas/Curl predicador máquina.jpeg',

    // =========================================================================
    // PESO LIBRE - Mancuernas, barras y discos
    // =========================================================================
    'dumbbell_rack': 'assets/images/maquinas/Rack de mancuernas.jpeg',
    'Rack de Mancuernas': 'assets/images/maquinas/Rack de mancuernas.jpeg',

    'barra_olimpica': 'assets/images/maquinas/Barra olimpica.jpeg',
    'olympic_bar': 'assets/images/maquinas/Barra olimpica.jpeg',
    'Barra Olímpica (20 kg)': 'assets/images/maquinas/Barra olimpica.jpeg',

    'barra_z': 'assets/images/maquinas/Barra Z.jpeg',
    'ez_curl_bar': 'assets/images/maquinas/Barra Z.jpeg',
    'Barra Z / EZ Curl': 'assets/images/maquinas/Barra Z.jpeg',

    'barra_hexagonal': 'assets/images/maquinas/Barra hexagonal.jpeg',
    'hex_bar': 'assets/images/maquinas/Barra hexagonal.jpeg',
    'Barra Hexagonal / Trap Bar': 'assets/images/maquinas/Barra hexagonal.jpeg',

    // =========================================================================
    // CARDIO - Equipamiento cardiovascular
    // =========================================================================
    'treadmill': 'assets/images/maquinas/Caminadora.jpeg',
    'Caminadora': 'assets/images/maquinas/Caminadora.jpeg',

    'stationary_bike': 'assets/images/maquinas/Bicicleta estatica.jpeg',
    'Bicicleta Estática': 'assets/images/maquinas/Bicicleta estatica.jpeg',

    'rowing_machine': 'assets/images/maquinas/Remo cardio.jpeg',
    'rowing_cardio': 'assets/images/maquinas/Remo cardio.jpeg',
    'Máquina de Remo Cardio': 'assets/images/maquinas/Remo cardio.jpeg',

    'elliptical': 'assets/images/maquinas/Eliptica.jpeg',
    'Elíptica': 'assets/images/maquinas/Eliptica.jpeg',

    'step_stepper': 'assets/images/maquinas/Step stepper.jpeg',
    'Step/Stepper': 'assets/images/maquinas/Step stepper.jpeg',

    // =========================================================================
    // FUNCIONAL - Equipamiento para entrenamiento funcional
    // =========================================================================
    'battle_ropes': 'assets/images/maquinas/Cuerdas de batalla.jpeg',
    'Cuerdas de Batalla': 'assets/images/maquinas/Cuerdas de batalla.jpeg',

    'kettlebell_station': 'assets/images/maquinas/Kettlebells.jpeg',
    'Estación de Kettlebells': 'assets/images/maquinas/Kettlebells.jpeg',

    'trx_suspension': 'assets/images/maquinas/TRX suspension.jpeg',
    'TRX Suspensión': 'assets/images/maquinas/TRX suspension.jpeg',

    'plyo_box': 'assets/images/maquinas/Caja pliometrica.jpeg',
    'Caja Pliométrica': 'assets/images/maquinas/Caja pliometrica.jpeg',

    'multi_gym': 'assets/images/maquinas/Estacion de cables.jpeg',
    'Estación de Cables Multiusos': 'assets/images/maquinas/Estacion de cables.jpeg',
  };

  /// Obtener la imagen de una máquina por su ID o nombre
  static String? getImageForMachine(String machineIdOrName) {
    return _machineImageMap[machineIdOrName];
  }

  /// Obtener la imagen para un ejercicio (por su máquina asociada)
  static String? getImageForExercise(ExerciseModel exercise) {
    // Primero intentar por machineId
    final byId = _machineImageMap[exercise.machineId];
    if (byId != null) return byId;

    // Luego intentar por machineName
    final byName = _machineImageMap[exercise.machineName];
    if (byName != null) return byName;

    // Finalmente intentar por nombre del ejercicio
    return _machineImageMap[exercise.nombre];
  }

  // ===========================================================================
  // IMÁGENES PARA RUTINAS POR GÉNERO
  // ===========================================================================

  /// Mapeo de imágenes de rutinas por género
  static const Map<String, String> _routineImageMap = {
    'hombre': 'assets/images/rutinas/hombre_workout.jpeg',
    'mujer': 'assets/images/rutinas/mujer_workout.jpeg',
    'unisex': 'assets/images/rutinas/unisex_workout.jpeg',
  };

  /// Obtener imagen de rutina basada en el género
  static String getImageForRoutineGender(RoutineGender gender) {
    switch (gender) {
      case RoutineGender.hombre:
        return _routineImageMap['hombre']!;
      case RoutineGender.mujer:
        return _routineImageMap['mujer']!;
      case RoutineGender.unisex:
        return _routineImageMap['unisex']!;
    }
  }
}
