import 'dart:convert';
import 'dart:io' show Directory, File, Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grading_config_model.dart';
import '../models/program_model.dart';
import '../services/file_service.dart';
import '../services/api_client.dart';

class ProgramConfigProvider extends ChangeNotifier {
  GradingConfig? _gradingConfig;
  bool _configLoaded = false;

  String _programName = '';
  final Set<String> _gradingBasedOn = {'Feature'};
  String _produceName = '';

  final List<String> _savedProgramNames = [];

  String get programName => _programName;
  String get gradingBasedOn => _gradingBasedOn.join(', ');
  Set<String> get selectedGradingBasedOn => Set.unmodifiable(_gradingBasedOn);
  String get produceName => _produceName;
  bool get configLoaded => _configLoaded;
  GradingConfig? get gradingConfig => _gradingConfig;

  List<String> get availableProduceNames {
    if (_gradingConfig == null) return [];
    return _gradingConfig!.repository
        .where((r) => r.enableProduce)
        .map((r) => r.produceName)
        .toList();
  }

  static const List<String> gradingOptions = ['Defect Feature'];

  List<FeatureClass> get visionFeatures {
    if (_gradingConfig == null || _produceName.isEmpty) return [];
    final repo = _gradingConfig!.repository.cast<RepositoryItem?>().firstWhere(
          (r) => r!.produceName == _produceName,
          orElse: () => null,
        );
    if (repo == null) return [];
    final visionModels = repo.featureTable.where((m) => m.pfdubBased);
    final features = <FeatureClass>[];
    for (final model in visionModels) {
      features.addAll(model.classes.where((c) => c.enable));
    }
    return features;
  }

  Future<void> loadGradingConfig() async {
    try {
      if (kIsWeb) {
        final json = await ApiClient.fetchConfig();
        _gradingConfig = GradingConfig.fromJson(json);
      } else {
        final jsonStr =
            await rootBundle.loadString('assets/config/gradingconfig.json');
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _gradingConfig = GradingConfig.fromJson(json);
      }
      _configLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load grading config: $e');
    }
  }

  Future<void> loadExistingPrograms() async {
    if (kIsWeb) {
      try {
        _savedProgramNames
          ..clear()
          ..addAll(await ApiClient.fetchPrograms());
      } catch (e) {
        _savedProgramNames.clear();
      }
      return;
    }
    try {
      final dir = Directory('programs');
      if (await dir.exists()) {
        final files = dir.listSync().whereType<File>();
        _savedProgramNames.clear();
        for (final f in files) {
          if (f.path.endsWith('.json')) {
            _savedProgramNames.add(f.path
                .split(Platform.pathSeparator)
                .last
                .replaceAll('.json', ''));
          }
        }
      }
    } catch (e) {
      _savedProgramNames.clear();
    }
  }

  void setProgramName(String v) {
    _programName = v;
    notifyListeners();
  }

  void toggleGradingOn(String v) {
    if (_gradingBasedOn.contains(v)) {
      _gradingBasedOn.remove(v);
    } else {
      _gradingBasedOn.add(v);
    }
    notifyListeners();
  }

  void setGradingOnAll(List<String> values) {
    _gradingBasedOn
      ..clear()
      ..addAll(values);
    notifyListeners();
  }

  bool isGradingSelected(String v) => _gradingBasedOn.contains(v);

  void setProduceName(String v) {
    _produceName = v;
    notifyListeners();
  }

  bool get canProceed =>
      _programName.isNotEmpty &&
      _gradingBasedOn.isNotEmpty &&
      _produceName.isNotEmpty;

  List<String> get savedProgramNames => List.unmodifiable(_savedProgramNames);
  bool get isDuplicateName => _savedProgramNames.contains(_programName);

  Future<void> saveProgram() async {
    final program = ProgramModel(
      programName: _programName,
      produceName: _produceName,
      gradingBasedOn: _gradingBasedOn.join(', '),
      deleteEnable: false,
    );
    final jsonStr =
        const JsonEncoder.withIndent('  ').convert(program.toJson());
    try {
      if (kIsWeb) {
        await ApiClient.saveProgram(
            _programName, jsonDecode(jsonStr) as Map<String, dynamic>);
      } else {
        await saveProgramFile(_programName, jsonStr);
      }
      if (!_savedProgramNames.contains(_programName)) {
        _savedProgramNames.add(_programName);
      }
    } catch (e) {
      debugPrint('Failed to save program: $e');
    }
  }

  Future<Map<String, dynamic>?> loadProgram(String name) async {
    try {
      if (kIsWeb) {
        return await ApiClient.loadProgram(name);
      } else {
        final file = File('programs/$name.json');
        if (!await file.exists()) return null;
        final json = jsonDecode(await file.readAsString());
        return json as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to load program: $e');
      return null;
    }
  }

  Future<void> deleteProgram(String name) async {
    try {
      if (kIsWeb) {
        await ApiClient.deleteProgram(name);
      } else {
        final file = File('programs/$name.json');
        if (await file.exists()) await file.delete();
      }
      _savedProgramNames.remove(name);
    } catch (e) {
      debugPrint('Failed to delete program: $e');
    }
  }

  void reset() {
    _programName = '';
    _gradingBasedOn.clear();
    _gradingBasedOn.add('Feature');
    _produceName = '';
    notifyListeners();
  }
}
