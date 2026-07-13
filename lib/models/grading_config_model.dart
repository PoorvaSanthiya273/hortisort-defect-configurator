class GradingConfig {
  final Settings settings;
  final List<RepositoryItem> repository;

  GradingConfig({required this.settings, required this.repository});

  factory GradingConfig.fromJson(Map<String, dynamic> json) {
    return GradingConfig(
      settings: Settings.fromJson(json['Settings'] as Map<String, dynamic>),
      repository: (json['Repository'] as List<dynamic>)
          .map((e) => RepositoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Settings {
  final SizeRange sizeRange;
  final WeightRange weightRange;

  Settings({required this.sizeRange, required this.weightRange});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      sizeRange: SizeRange.fromJson(json['SizeRange'] as Map<String, dynamic>),
      weightRange:
          WeightRange.fromJson(json['WeightRange'] as Map<String, dynamic>),
    );
  }
}

class SizeRange {
  final double min;
  final double max;
  SizeRange({required this.min, required this.max});
  factory SizeRange.fromJson(Map<String, dynamic> json) => SizeRange(
      min: (json['Min'] as num).toDouble(),
      max: (json['Max'] as num).toDouble());
}

class WeightRange {
  final double min;
  final double max;
  WeightRange({required this.min, required this.max});
  factory WeightRange.fromJson(Map<String, dynamic> json) => WeightRange(
      min: (json['Min'] as num).toDouble(),
      max: (json['Max'] as num).toDouble());
}

class RepositoryItem {
  final String produceName;
  final bool enableProduce;
  final List<FeatureModel> featureTable;

  RepositoryItem({
    required this.produceName,
    required this.enableProduce,
    required this.featureTable,
  });

  factory RepositoryItem.fromJson(Map<String, dynamic> json) {
    return RepositoryItem(
      produceName: json['ProduceName'] as String,
      enableProduce: json['EnableProduce'] as bool,
      featureTable: (json['FeatureTable'] as List<dynamic>)
          .map((e) => FeatureModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FeatureModel {
  final String modelName;
  final bool pfdubBased;
  final List<FeatureClass> classes;

  FeatureModel({
    required this.modelName,
    required this.pfdubBased,
    required this.classes,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      modelName: json['ModelName'] as String,
      pfdubBased: json['PFDUBased'] as bool,
      classes: (json['Class'] as List<dynamic>)
          .map((e) => FeatureClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FeatureClass {
  final String featureName;
  final bool enable;
  final bool measurableORYesNo;
  final MeasuringAttributes measuringAttributes;

  FeatureClass({
    required this.featureName,
    required this.enable,
    required this.measurableORYesNo,
    required this.measuringAttributes,
  });

  factory FeatureClass.fromJson(Map<String, dynamic> json) {
    return FeatureClass(
      featureName: json['FeatureName'] as String,
      enable: json['Enable'] as bool,
      measurableORYesNo: json['MeasurableORYesNo'] as bool,
      measuringAttributes: MeasuringAttributes.fromJson(
          json['MeasuringAttributes'] as Map<String, dynamic>),
    );
  }
}

class MeasuringAttributes {
  final String units;
  final double measurementMin;
  final double measurementMax;
  final int noOfBands;

  MeasuringAttributes({
    required this.units,
    required this.measurementMin,
    required this.measurementMax,
    required this.noOfBands,
  });

  factory MeasuringAttributes.fromJson(Map<String, dynamic> json) {
    final limit = json['MeasurementLimit'] as Map<String, dynamic>;
    return MeasuringAttributes(
      units: json['Units'] as String,
      measurementMin: (limit['Min'] as num).toDouble(),
      measurementMax: (limit['Max'] as num).toDouble(),
      noOfBands: json['NoOfBands'] as int,
    );
  }
}
