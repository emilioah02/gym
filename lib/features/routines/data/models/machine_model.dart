/// Model representing a gym machine/exercise
class MachineModel {
  final String id;
  final String name;
  final String description;
  final int defaultSets;
  final int defaultReps;
  final String? imageUrl;
  final MachineCategory category;

  const MachineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultSets,
    required this.defaultReps,
    this.imageUrl,
    required this.category,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'imageUrl': imageUrl,
      'category': category.name,
    };
  }
}

/// Categories for gym machines
enum MachineCategory {
  cardio,
  legs,
  chest,
  back,
  shoulders,
  arms,
  core,
  functional,
}

extension MachineCategoryExtension on MachineCategory {
  String get displayName {
    switch (this) {
      case MachineCategory.cardio:
        return 'Cardio';
      case MachineCategory.legs:
        return 'Legs';
      case MachineCategory.chest:
        return 'Chest';
      case MachineCategory.back:
        return 'Back';
      case MachineCategory.shoulders:
        return 'Shoulders';
      case MachineCategory.arms:
        return 'Arms';
      case MachineCategory.core:
        return 'Core';
      case MachineCategory.functional:
        return 'Functional';
    }
  }
}
