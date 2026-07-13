import 'grading_config_model.dart';

class ProgramModel {
  String programName;
  String produceName;
  String gradingBasedOn;
  bool deleteEnable;
  ColourGrades colourGrades;
  SizeGrades sizeGrades;
  WeightGrades weightGrades;
  List<FeatureEntry> featureTable;
  List<SpectroFeatureEntry> spectroFeatureTable;
  List<OutletMapping> outletMapping;

  ProgramModel({
    required this.programName,
    required this.produceName,
    this.gradingBasedOn = 'Defect Feature',
    this.deleteEnable = false,
    ColourGrades? colourGrades,
    SizeGrades? sizeGrades,
    WeightGrades? weightGrades,
    List<FeatureEntry>? featureTable,
    List<SpectroFeatureEntry>? spectroFeatureTable,
    List<OutletMapping>? outletMapping,
  })  : colourGrades = colourGrades ?? ColourGrades(colourGradeTable: []),
        sizeGrades = sizeGrades ?? SizeGrades(sizeGradeTable: []),
        weightGrades = weightGrades ?? WeightGrades(weightGradeTable: []),
        featureTable = featureTable ?? [],
        spectroFeatureTable = spectroFeatureTable ?? [],
        outletMapping = outletMapping ?? [];

  Map<String, dynamic> toJson() => {
        'ProgramName': programName,
        'ProduceName': produceName,
        'GradingBasedOn': gradingBasedOn,
        'DeleteEnable': deleteEnable,
        'ColourGrades': colourGrades.toJson(),
        'SizeGrades': sizeGrades.toJson(),
        'WeightGrades': weightGrades.toJson(),
        'FeatureTable': featureTable.map((e) => e.toJson()).toList(),
        'SpectroFeatureTable':
            spectroFeatureTable.map((e) => e.toJson()).toList(),
        'OutletMapping': outletMapping.map((e) => e.toJson()).toList(),
      };

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
        programName: json['ProgramName'] as String,
        produceName: json['ProduceName'] as String,
        gradingBasedOn: json['GradingBasedOn'] as String? ?? 'Defect Feature',
        deleteEnable: json['DeleteEnable'] as bool? ?? false,
        colourGrades: json['ColourGrades'] != null
            ? ColourGrades.fromJson(
                json['ColourGrades'] as Map<String, dynamic>)
            : null,
        sizeGrades: json['SizeGrades'] != null
            ? SizeGrades.fromJson(json['SizeGrades'] as Map<String, dynamic>)
            : null,
        weightGrades: json['WeightGrades'] != null
            ? WeightGrades.fromJson(
                json['WeightGrades'] as Map<String, dynamic>)
            : null,
        featureTable: (json['FeatureTable'] as List<dynamic>?)
                ?.map((e) => FeatureEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        spectroFeatureTable: (json['SpectroFeatureTable'] as List<dynamic>?)
                ?.map((e) =>
                    SpectroFeatureEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        outletMapping: (json['OutletMapping'] as List<dynamic>?)
                ?.map((e) => OutletMapping.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ColourGrades {
  List<ColourGradeTable> colourGradeTable;
  ColourGrades({required this.colourGradeTable});
  Map<String, dynamic> toJson() =>
      {'ColourGradeTable': colourGradeTable.map((e) => e.toJson()).toList()};
  factory ColourGrades.fromJson(Map<String, dynamic> json) => ColourGrades(
        colourGradeTable: (json['ColourGradeTable'] as List<dynamic>)
            .map((e) => ColourGradeTable.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ColourGradeTable {
  String colourGradeName;
  Colour colour;
  ColourGradeTable({required this.colourGradeName, required this.colour});
  Map<String, dynamic> toJson() => {
        'ColourGradeName': colourGradeName,
        'Colour': colour.toJson(),
      };
  factory ColourGradeTable.fromJson(Map<String, dynamic> json) =>
      ColourGradeTable(
        colourGradeName: json['ColourGradeName'] as String,
        colour: Colour.fromJson(json['Colour'] as Map<String, dynamic>),
      );
}

class Colour {
  List<ColourRange> colourRange;
  Colour({required this.colourRange});
  Map<String, dynamic> toJson() =>
      {'ColourRange': colourRange.map((e) => e.toJson()).toList()};
  factory Colour.fromJson(Map<String, dynamic> json) => Colour(
        colourRange: (json['ColourRange'] as List<dynamic>)
            .map((e) => ColourRange.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ColourRange {
  String name;
  ColourPercent colourPercent;
  ColourRange({required this.name, required this.colourPercent});

  static List<ColourRange> get defaults => [
        ColourRange(
            name: 'Red', colourPercent: ColourPercent(min: 0, max: 100)),
        ColourRange(
            name: 'Yellow', colourPercent: ColourPercent(min: 0, max: 100)),
        ColourRange(
            name: 'Green', colourPercent: ColourPercent(min: 0, max: 100)),
        ColourRange(
            name: 'White', colourPercent: ColourPercent(min: 0, max: 100)),
        ColourRange(
            name: 'Unmapped', colourPercent: ColourPercent(min: 0, max: 100)),
        ColourRange(
            name: 'Unclassified',
            colourPercent: ColourPercent(min: 0, max: 100)),
      ];

  Map<String, dynamic> toJson() => {
        'Name': name,
        'ColourPercent': colourPercent.toJson(),
      };
  factory ColourRange.fromJson(Map<String, dynamic> json) => ColourRange(
        name: json['Name'] as String,
        colourPercent: ColourPercent.fromJson(
            json['ColourPercent'] as Map<String, dynamic>),
      );
}

class ColourPercent {
  double min;
  double max;
  ColourPercent({required this.min, required this.max});
  Map<String, dynamic> toJson() => {'Min': min, 'Max': max};
  factory ColourPercent.fromJson(Map<String, dynamic> json) => ColourPercent(
        min: (json['Min'] as num).toDouble(),
        max: (json['Max'] as num).toDouble(),
      );
}

class SizeGrades {
  String? sizeClassification;
  List<SizeGradeTable> sizeGradeTable;
  SizeGrades({this.sizeClassification, required this.sizeGradeTable});
  Map<String, dynamic> toJson() => {
        if (sizeClassification != null)
          'SizeClassification': sizeClassification,
        'SizeGradeTable': sizeGradeTable.map((e) => e.toJson()).toList(),
      };
  factory SizeGrades.fromJson(Map<String, dynamic> json) => SizeGrades(
        sizeClassification: json['SizeClassification'] as String?,
        sizeGradeTable: (json['SizeGradeTable'] as List<dynamic>)
            .map((e) => SizeGradeTable.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SizeGradeTable {
  String name;
  double min;
  double max;
  SizeGradeTable({required this.name, required this.min, required this.max});
  Map<String, dynamic> toJson() => {'Name': name, 'Min': min, 'Max': max};
  factory SizeGradeTable.fromJson(Map<String, dynamic> json) => SizeGradeTable(
        name: json['Name'] as String,
        min: (json['Min'] as num).toDouble(),
        max: (json['Max'] as num).toDouble(),
      );
}

class WeightGrades {
  List<WeightGradeTable> weightGradeTable;
  WeightGrades({required this.weightGradeTable});
  Map<String, dynamic> toJson() =>
      {'WeightGradeTable': weightGradeTable.map((e) => e.toJson()).toList()};
  factory WeightGrades.fromJson(Map<String, dynamic> json) => WeightGrades(
        weightGradeTable: (json['WeightGradeTable'] as List<dynamic>)
            .map((e) => WeightGradeTable.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WeightGradeTable {
  String name;
  double min;
  double max;
  WeightGradeTable({required this.name, required this.min, required this.max});
  Map<String, dynamic> toJson() => {'Name': name, 'Min': min, 'Max': max};
  factory WeightGradeTable.fromJson(Map<String, dynamic> json) =>
      WeightGradeTable(
        name: json['Name'] as String,
        min: (json['Min'] as num).toDouble(),
        max: (json['Max'] as num).toDouble(),
      );
}

class FeatureEntry {
  String featureName;
  int gradingMode;
  List<FeatureGrade> featureGradeTable;

  FeatureEntry({
    required this.featureName,
    this.gradingMode = 1,
    required this.featureGradeTable,
  });

  Map<String, dynamic> toJson() => {
        'FeatureName': featureName,
        'No(1)/TotalUnit(2)/Histogram(3)': gradingMode,
        'FeatureGradeTable': featureGradeTable.map((e) => e.toJson()).toList(),
      };

  factory FeatureEntry.fromJson(Map<String, dynamic> json) => FeatureEntry(
        featureName: json['FeatureName'] as String,
        gradingMode: json['No(1)/TotalUnit(2)/Histogram(3)'] as int? ?? 1,
        featureGradeTable: (json['FeatureGradeTable'] as List<dynamic>)
            .map((e) => FeatureGrade.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FeatureGrade {
  String featureGradeName;
  double valueMin;
  double valueMax;
  double bandMin;
  double bandMax;

  FeatureGrade({
    required this.featureGradeName,
    required this.valueMin,
    required this.valueMax,
    this.bandMin = 0,
    this.bandMax = 0,
  });

  Map<String, dynamic> toJson() => {
        'FeatureGradeName': featureGradeName,
        'ValueMin': valueMin,
        'ValueMax': valueMax,
        'BandMin': bandMin,
        'BandMax': bandMax,
      };

  factory FeatureGrade.fromJson(Map<String, dynamic> json) => FeatureGrade(
        featureGradeName: json['FeatureGradeName'] as String,
        valueMin: (json['ValueMin'] as num).toDouble(),
        valueMax: (json['ValueMax'] as num).toDouble(),
        bandMin: (json['BandMin'] as num?)?.toDouble() ?? 0,
        bandMax: (json['BandMax'] as num?)?.toDouble() ?? 0,
      );
}

class SpectroFeatureEntry {
  List<SpectroClass> classes;
  SpectroFeatureEntry({required this.classes});
  Map<String, dynamic> toJson() =>
      {'Class': classes.map((e) => e.toJson()).toList()};
  factory SpectroFeatureEntry.fromJson(Map<String, dynamic> json) =>
      SpectroFeatureEntry(
        classes: (json['Class'] as List<dynamic>)
            .map((e) => SpectroClass.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SpectroClass {
  String featureName;
  bool enable;
  bool measurableORYesNo;
  MeasuringAttributes measuringAttributes;
  SpectroClass({
    required this.featureName,
    required this.enable,
    required this.measurableORYesNo,
    required this.measuringAttributes,
  });
  Map<String, dynamic> toJson() => {
        'FeatureName': featureName,
        'Enable': enable,
        'MeasurableORYesNo': measurableORYesNo,
        'MeasuringAttributes': {
          'Units': measuringAttributes.units,
          'MeasurementLimit': {
            'Min': measuringAttributes.measurementMin,
            'Max': measuringAttributes.measurementMax,
          },
          'NoOfBands': measuringAttributes.noOfBands,
        },
      };
  factory SpectroClass.fromJson(Map<String, dynamic> json) => SpectroClass(
        featureName: json['FeatureName'] as String,
        enable: json['Enable'] as bool,
        measurableORYesNo: json['MeasurableORYesNo'] as bool,
        measuringAttributes: MeasuringAttributes.fromJson(
            json['MeasuringAttributes'] as Map<String, dynamic>),
      );
}

class OutletMapping {
  String outletDescription;
  List<FeatureCombination> featureCombinations;

  OutletMapping(
      {required this.outletDescription, required this.featureCombinations});

  Map<String, dynamic> toJson() => {
        'OutletDescription': outletDescription,
        'FeatureCombinations':
            featureCombinations.map((e) => e.toJson()).toList(),
      };

  factory OutletMapping.fromJson(Map<String, dynamic> json) => OutletMapping(
        outletDescription: json['OutletDescription'] as String,
        featureCombinations: (json['FeatureCombinations'] as List<dynamic>)
            .map((e) => FeatureCombination.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class FeatureCombination {
  String color;
  String size;
  String weight;
  List<String> features;

  FeatureCombination({
    required this.color,
    required this.size,
    required this.weight,
    required this.features,
  });

  Map<String, dynamic> toJson() => {
        'Color': color,
        'Size': size,
        'Weight': weight,
        'Features': features,
      };

  factory FeatureCombination.fromJson(Map<String, dynamic> json) =>
      FeatureCombination(
        color: json['Color'] as String? ?? '',
        size: json['Size'] as String? ?? '',
        weight: json['Weight'] as String? ?? '',
        features: (json['Features'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );
}
