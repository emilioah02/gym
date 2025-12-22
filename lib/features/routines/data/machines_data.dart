import 'models/machine_model.dart';

/// Complete list of 35 gym machines with descriptions
class MachinesData {
  MachinesData._();

  static const List<MachineModel> allMachines = [
    // CARDIO (5)
    MachineModel(
      id: 'treadmill',
      name: 'Caminadora',
      description: 'Banda motorizada para caminar, trotar o correr en interiores. Ideal para cardio y calentamiento.',
      defaultSets: 1,
      defaultReps: 20,
      category: MachineCategory.cardio,
      imageUrl: 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400&q=80',
    ),
    MachineModel(
      id: 'stationary_bike',
      name: 'Bicicleta Estática',
      description: 'Máquina de ciclismo para cardio de bajo impacto. Resistencia ajustable para variar la intensidad.',
      defaultSets: 1,
      defaultReps: 15,
      category: MachineCategory.cardio,
      imageUrl: 'https://images.unsplash.com/photo-1591741535018-d042cbcd0d73?w=400&q=80',
    ),
    MachineModel(
      id: 'elliptical',
      name: 'Elíptica',
      description: 'Máquina de cardio de bajo impacto que simula caminar, correr o subir escaleras.',
      defaultSets: 1,
      defaultReps: 15,
      category: MachineCategory.cardio,
      imageUrl: 'https://images.unsplash.com/photo-1570829460005-c840387bb1ca?w=400&q=80',
    ),
    MachineModel(
      id: 'rowing_machine',
      name: 'Máquina de Remo',
      description: 'Entrenamiento cardio de cuerpo completo simulando remo. Trabaja piernas, core y tren superior.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.cardio,
      imageUrl: 'https://images.unsplash.com/photo-1519505907962-0a6cb0167c73?w=400&q=80',
    ),
    MachineModel(
      id: 'step_stepper',
      name: 'Escaladora',
      description: 'Simula subir escaleras para cardio y tonificación del tren inferior.',
      defaultSets: 1,
      defaultReps: 15,
      category: MachineCategory.cardio,
      imageUrl: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=400&q=80',
    ),

    // LEGS (8)
    MachineModel(
      id: 'leg_press',
      name: 'Prensa de Piernas',
      description: 'Máquina sentada para empujar peso con las piernas. Trabaja cuádriceps, isquiotibiales y glúteos.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400',
    ),
    MachineModel(
      id: 'smith_machine',
      name: 'Máquina Smith',
      description: 'Barra fija en rieles de acero para sentadillas, press y remos guiados.',
      defaultSets: 4,
      defaultReps: 10,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    ),
    MachineModel(
      id: 'squat_rack',
      name: 'Rack de Sentadillas',
      description: 'Estructura resistente para sentadillas con barra. Esencial para desarrollar fuerza en piernas.',
      defaultSets: 4,
      defaultReps: 10,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
    ),
    MachineModel(
      id: 'hack_squat',
      name: 'Hack Squat',
      description: 'Máquina inclinada para sentadillas. Enfatiza cuádriceps con soporte de espalda.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=400',
    ),
    MachineModel(
      id: 'leg_extension',
      name: 'Extensión de Piernas',
      description: 'Máquina sentada que aísla los cuádriceps mediante extensión de rodilla.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?w=400',
    ),
    MachineModel(
      id: 'leg_curl',
      name: 'Curl de Piernas',
      description: 'Máquina para aislar isquiotibiales mediante flexión de rodilla. Disponible sentado o acostado.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1597452485669-2c7bb5fef90d?w=400',
    ),
    MachineModel(
      id: 'calf_raise',
      name: 'Máquina de Pantorrillas',
      description: 'Trabaja los músculos de la pantorrilla mediante flexión plantar. Versiones de pie o sentado.',
      defaultSets: 4,
      defaultReps: 15,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
    ),
    MachineModel(
      id: 'abductor_adductor',
      name: 'Máquina Abductor/Aductor',
      description: 'Trabaja la parte interna y externa de los muslos. Cambia configuración para abducción o aducción.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.legs,
      imageUrl: 'https://images.unsplash.com/photo-1596357395217-80de13130e92?w=400',
    ),

    // CHEST (5)
    MachineModel(
      id: 'chest_press',
      name: 'Press de Pecho',
      description: 'Máquina sentada para press horizontal. Aísla el pecho con movimiento guiado.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400',
    ),
    MachineModel(
      id: 'pec_deck',
      name: 'Pec Deck',
      description: 'Aísla el pecho mediante aducción horizontal de brazos. Excelente para contracción del pecho.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=400',
    ),
    MachineModel(
      id: 'cable_crossover',
      name: 'Cruce de Cables',
      description: 'Estación de cables dobles para aperturas y cruces de pecho. Tensión constante.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1534368959876-26bf04f2c947?w=400',
    ),
    MachineModel(
      id: 'dumbbell_bench_flat',
      name: 'Banco Plano con Mancuernas',
      description: 'Banco plano para press y aperturas con mancuernas. Trabaja el pecho medio.',
      defaultSets: 4,
      defaultReps: 10,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1534368786749-b63e05c92717?w=400',
    ),
    MachineModel(
      id: 'dumbbell_bench_incline',
      name: 'Banco Inclinado con Mancuernas',
      description: 'Banco inclinado que enfatiza el desarrollo del pecho superior.',
      defaultSets: 4,
      defaultReps: 10,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
    ),

    // BACK (5)
    MachineModel(
      id: 'lat_pulldown',
      name: 'Jalón al Pecho',
      description: 'Máquina de cables para jalón vertical. Trabaja dorsales y espalda alta.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.back,
      imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400',
    ),
    MachineModel(
      id: 'seated_row',
      name: 'Remo Sentado',
      description: 'Máquina de remo con cable para jalón horizontal. Trabaja espalda media y dorsales.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.back,
      imageUrl: 'https://images.unsplash.com/photo-1597347316205-36f6c451902a?w=400',
    ),
    MachineModel(
      id: 'assisted_pullup',
      name: 'Dominadas Asistidas',
      description: 'Máquina con contrapeso para dominadas y chin-ups asistidos.',
      defaultSets: 3,
      defaultReps: 10,
      category: MachineCategory.back,
      imageUrl: 'https://images.unsplash.com/photo-1598266663439-2056e6900339?w=400',
    ),
    MachineModel(
      id: 'iso_row',
      name: 'Remo con Soporte de Pecho',
      description: 'Máquina de remo con soporte que aísla cada lado de forma independiente.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.back,
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400',
    ),
    MachineModel(
      id: 'barbell_rack',
      name: 'Rack de Barras',
      description: 'Rack para barras usado en peso muerto, remos y otros ejercicios compuestos.',
      defaultSets: 4,
      defaultReps: 8,
      category: MachineCategory.back,
      imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=400',
    ),

    // SHOULDERS (2)
    MachineModel(
      id: 'shoulder_press',
      name: 'Press de Hombros',
      description: 'Máquina sentada para press sobre la cabeza. Trabaja deltoides de forma segura.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.shoulders,
      imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
    ),
    MachineModel(
      id: 'lateral_raise',
      name: 'Elevaciones Laterales',
      description: 'Aísla los deltoides laterales mediante elevaciones con movimiento guiado.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.shoulders,
      imageUrl: 'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=400',
    ),

    // ARMS (2)
    MachineModel(
      id: 'triceps_pushdown',
      name: 'Jalón de Tríceps / Fondos',
      description: 'Máquina de cable o asistida para ejercicios de aislamiento de tríceps.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.arms,
      imageUrl: 'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400',
    ),
    MachineModel(
      id: 'biceps_curl',
      name: 'Curl de Bíceps',
      description: 'Máquina sentada que aísla bíceps mediante flexión de codo.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.arms,
      imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=400',
    ),

    // CORE (2)
    MachineModel(
      id: 'ab_crunch',
      name: 'Máquina de Abdominales',
      description: 'Máquina con peso para crunches abdominales con resistencia ajustable.',
      defaultSets: 3,
      defaultReps: 20,
      category: MachineCategory.core,
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
    ),
    MachineModel(
      id: 'glute_machine',
      name: 'Máquina de Glúteos',
      description: 'Trabaja glúteos mediante extensión de cadera. Ideal para desarrollar la cadena posterior.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.core,
      imageUrl: 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=400',
    ),

    // FUNCTIONAL (6)
    MachineModel(
      id: 'battle_ropes',
      name: 'Cuerdas de Batalla',
      description: 'Cuerdas pesadas para acondicionamiento de alta intensidad. Trabaja todo el cuerpo.',
      defaultSets: 3,
      defaultReps: 30,
      category: MachineCategory.functional,
      imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=400',
    ),
    MachineModel(
      id: 'seated_chest_press',
      name: 'Press de Pecho Sentado',
      description: 'Press de pecho alternativo con soporte vertical de espalda.',
      defaultSets: 4,
      defaultReps: 12,
      category: MachineCategory.chest,
      imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400',
    ),
    MachineModel(
      id: 'multi_gym',
      name: 'Estación de Cables Multiusos',
      description: 'Sistema de cables versátil para docenas de ejercicios. Entrenamiento de cuerpo completo.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.functional,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    ),
    MachineModel(
      id: 'kettlebell_station',
      name: 'Estación de Kettlebells',
      description: 'Rack con varios pesos de kettlebell para swings, cleans y press.',
      defaultSets: 3,
      defaultReps: 15,
      category: MachineCategory.functional,
      imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=400',
    ),
    MachineModel(
      id: 'trx_suspension',
      name: 'TRX Suspensión',
      description: 'Sistema de entrenamiento con peso corporal usando correas de suspensión para fitness funcional.',
      defaultSets: 3,
      defaultReps: 12,
      category: MachineCategory.functional,
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
    ),
    MachineModel(
      id: 'plyo_box',
      name: 'Caja Pliométrica',
      description: 'Plataforma para saltos pliométricos y ejercicios de step. Desarrolla potencia explosiva.',
      defaultSets: 3,
      defaultReps: 10,
      category: MachineCategory.functional,
      imageUrl: 'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?w=400',
    ),
  ];

  /// Get machines by category
  static List<MachineModel> getByCategory(MachineCategory category) {
    return allMachines.where((m) => m.category == category).toList();
  }

  /// Get machine by ID
  static MachineModel? getById(String id) {
    try {
      return allMachines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
