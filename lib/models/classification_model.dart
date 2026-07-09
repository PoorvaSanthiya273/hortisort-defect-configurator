class ClassificationModel {
  final String qualityClass;
  final double currentValue;
  final String reason;
  final double confidence;

  const ClassificationModel({
    required this.qualityClass,
    required this.currentValue,
    required this.reason,
    required this.confidence,
  });
}

class OutputModel {
  final String id;
  final String name;
  final String qualityClass;
  final int capacity;

  const OutputModel({
    required this.id,
    required this.name,
    required this.qualityClass,
    required this.capacity,
  });

  static const List<OutputModel> defaults = [
    OutputModel(id: 'O01', name: 'Good', qualityClass: 'Good', capacity: 40),
    OutputModel(
        id: 'O02',
        name: 'Slightly Bad',
        qualityClass: 'Slightly Bad',
        capacity: 35),
    OutputModel(id: 'O03', name: 'Bad', qualityClass: 'Bad', capacity: 25),
  ];
}

class RecommendationModel {
  final String qualityClass;
  final String outputName;
  final String reason;
  final double confidence;

  const RecommendationModel({
    required this.qualityClass,
    required this.outputName,
    required this.reason,
    required this.confidence,
  });
}

class ConfigurationModel {
  final String id;
  final String defectId;
  final String qualityClass;
  final String outputId;
  final String preset;
  final String status;
  final DateTime updatedAt;

  const ConfigurationModel({
    required this.id,
    required this.defectId,
    required this.qualityClass,
    required this.outputId,
    required this.preset,
    required this.status,
    required this.updatedAt,
  });
}
