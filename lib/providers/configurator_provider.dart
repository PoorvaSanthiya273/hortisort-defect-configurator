import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/defect_model.dart';

import '../models/histogram_config.dart';
import '../models/classification_model.dart';
import '../models/grading_config_model.dart';
import '../models/program_model.dart';
import '../services/file_service.dart';

class ConfiguratorProvider extends ChangeNotifier {
  final List<DefectModel> _defects = DefectModel.defaults;

  final HistogramConfig _histogramConfig = HistogramConfig();
  final List<OutputModel> _outputs = OutputModel.defaults;
  final List<ConfigurationModel> _configurations = [];

  String _programName = '';
  String _produceName = '';
  String get programName => _programName;
  String get produceName => _produceName;
  void setProgramName(String v) {
    _programName = v;
    notifyListeners();
  }

  void setProduceName(String v) {
    _produceName = v;
    notifyListeners();
  }

  List<DefectModel> get defects => _defects;
  HistogramConfig get histogramConfig => _histogramConfig;
  List<OutputModel> get outputs => _outputs;
  List<ConfigurationModel> get configurations => _configurations;

  // Draggable histogram state
  double _histogramMin = 0;
  double _histogramMax = 120;
  int _histogramNoOfBands = 10;
  final Set<String> _savedDefects = {};
  // Per-defect frequencies: defectId → {bandIndex: frequency}
  final Map<String, Map<int, double>> _defectFrequencies = {};
  // Per-defect band classification: defectId → {bandIndex: 'Good' | 'Defective'}
  final Map<String, Map<int, String>> _bandClasses = {};
  // Selected band indices per defect for batch operations
  final Map<String, Set<int>> _selectedBands = {};

  double get histogramMin => _histogramMin;
  double get histogramMax => _histogramMax;
  int get histogramNoOfBands => _histogramNoOfBands;
  double get bandSize => (_histogramMax - _histogramMin) / _histogramNoOfBands;
  bool get canProceedFromHistogram =>
      _selectedDefectIds.isEmpty ||
      _selectedDefectIds.every((id) => _savedDefects.contains(id));

  List<String> get bandLabels {
    final _fmt = (double v) =>
        v == v.toInt() ? v.toInt().toString() : v.toStringAsFixed(1);
    final labels = <String>[];
    final size = bandSize;
    for (int i = 0; i < _histogramNoOfBands; i++) {
      final start = _histogramMin + (i * size);
      final end = start + size;
      labels.add('${_fmt(start)}–${_fmt(end)}');
    }
    return labels;
  }

  double getDefectMaxFrequency(String defectKey) {
    final freqs = _defectFrequencies[defectKey];
    if (freqs == null || freqs.isEmpty) return 100;
    return freqs.values.reduce((a, b) => a > b ? a : b);
  }

  double getBandFrequency(String defectKey, int index) {
    return _defectFrequencies[defectKey]?[index] ?? 0.0;
  }

  double _computeHistogramThreshold(String defectId) {
    final freqs = _defectFrequencies[defectId];
    if (freqs == null || freqs.isEmpty) return 0;
    int lastGoodBand = -1;
    for (int i = 0; i < _histogramNoOfBands; i++) {
      if ((freqs[i] ?? 0) > 0) lastGoodBand = i;
    }
    if (lastGoodBand < 0) return 0;
    return _histogramMin + (lastGoodBand + 1) * bandSize;
  }

  void setBandFrequency(String defectKey, int index, double value) {
    _defectFrequencies.putIfAbsent(defectKey, () => {});
    _defectFrequencies[defectKey]![index] = value < 0 ? 0.0 : value;
    _savedDefects.remove(defectKey);
    _isSaved = false;
    notifyListeners();
  }

  void initDefectFrequencies(String defectKey) {
    if (_defectFrequencies.containsKey(defectKey)) return;
    _defectFrequencies[defectKey] = {};
    for (int i = 0; i < _histogramNoOfBands; i++) {
      _defectFrequencies[defectKey]![i] = (_histogramNoOfBands - i).toDouble();
    }
    notifyListeners();
  }

  void markAllDefectsSaved() {
    _savedDefects.addAll(_selectedDefectIds);
    notifyListeners();
  }

  void resetDefectFrequencies(String defectKey) {
    _defectFrequencies[defectKey]?.clear();
    _savedDefects.remove(defectKey);
    _isSaved = false;
    notifyListeners();
  }

  Future<void> saveHistogramConfig() async {
    if (_currentDefKey != null) _savedDefects.add(_currentDefKey!);
    _isSaved = true;
    notifyListeners();
  }

  // ── Band selection & classification ─────────────────

  Set<int> selectedBandsFor(String defectKey) =>
      _selectedBands[defectKey] ?? {};

  bool isBandSelected(String defectKey, int index) =>
      _selectedBands[defectKey]?.contains(index) ?? false;

  int selectedBandCount(String defectKey) =>
      (_selectedBands[defectKey]?.length ?? 0);

  void toggleBandSelect(String defectKey, int index) {
    _selectedBands[defectKey] ??= {};
    if (_selectedBands[defectKey]!.contains(index)) {
      _selectedBands[defectKey]!.remove(index);
    } else {
      _selectedBands[defectKey]!.add(index);
    }
    notifyListeners();
  }

  void clearBandSelection(String defectKey) {
    _selectedBands[defectKey]?.clear();
    notifyListeners();
  }

  String? getBandClass(String defectKey, int index) =>
      _bandClasses[defectKey]?[index];

  void markSelectedGood(String defectKey) {
    _bandClasses[defectKey] ??= {};
    for (final i in _selectedBands[defectKey] ?? {}) {
      _bandClasses[defectKey]![i] = 'Good';
    }
    _selectedBands[defectKey]?.clear();
    notifyListeners();
  }

  void markSelectedDefective(String defectKey) {
    _bandClasses[defectKey] ??= {};
    for (final i in _selectedBands[defectKey] ?? {}) {
      _bandClasses[defectKey]![i] = 'Defective';
    }
    _selectedBands[defectKey]?.clear();
    notifyListeners();
  }

  // Step state
  int _currentStep = 0;
  int get currentStep => _currentStep;
  int get totalSteps => 4;

  // Defect selection
  final Set<String> _selectedDefectIds = {};
  Set<String> get selectedDefectIds => _selectedDefectIds;
  int get selectedDefectCount => _selectedDefectIds.length;
  bool get canProceedFromDefects => _selectedDefectIds.isNotEmpty;
  DefectModel? get activeDefect => _selectedDefectIds.isNotEmpty
      ? _defects.firstWhere((d) => d.id == _selectedDefectIds.first)
      : _defects.first;
  List<DefectModel> get selectedDefects =>
      _defects.where((d) => _selectedDefectIds.contains(d.id)).toList();

  // Generated definitions: Cartesian product of Good/Bad across selected defects
  List<String> get definitions {
    final selected = _selectedDefectIds.toList()..sort();
    if (selected.isEmpty) return [];
    final n = selected.length;
    final total = 1 << n;
    return List<String>.generate(total, (i) {
      final parts = List<String>.generate(n, (j) {
        final grade = (i & (1 << j)) != 0 ? 'Good' : 'Bad';
        return '${selected[j]}=$grade';
      });
      return parts.join('|');
    });
  }

  // Per-defect thresholds: defectId → (xThreshold, yFreq)
  final Map<String, ({double xThreshold, double yFreq})> _defThresholds = {};
  String? _currentDefKey;

  String? get currentDefKey => _currentDefKey;

  void setCurrentDefinition(String key) {
    _currentDefKey = key;
    if (!_defThresholds.containsKey(key))
      _defThresholds[key] = (xThreshold: 40, yFreq: 30);
    notifyListeners();
  }

  void autoSuggestThresholds() {
    final k = _currentDefKey;
    if (k == null) return;
    final xs = _sampleData.map((p) => p.x).toList()..sort();
    final ys = _sampleData.map((p) => p.y).toList()..sort();
    _defThresholds[k] =
        (xThreshold: xs[xs.length ~/ 2], yFreq: ys[ys.length ~/ 3]);
    _isSaved = false;
    notifyListeners();
  }

  void resetCurrentDef() {
    final k = _currentDefKey;
    if (k == null) return;
    _defThresholds[k] = (xThreshold: 40, yFreq: 30);
    _isSaved = false;
    notifyListeners();
  }

  void saveCurrentDef() {
    final k = _currentDefKey;
    if (k == null && _selectedDefectIds.isNotEmpty) {
      final defId = _selectedDefectIds.first;
      _defThresholds.putIfAbsent(defId, () => (xThreshold: 40, yFreq: 30));
      _defects.firstWhere((d) => d.id == defId).configured = true;
    } else if (k != null) {
      _defThresholds.putIfAbsent(k, () => (xThreshold: 40, yFreq: 30));
      _defects.firstWhere((d) => d.id == k).configured = true;
    }
    notifyListeners();
  }

  void saveAllDefs() {
    for (final id in _selectedDefectIds) {
      _defects.firstWhere((d) => d.id == id).configured = true;
    }
    _isSaved = false;
    notifyListeners();
  }

  double get currentXThreshold {
    final k = _currentDefKey;
    if (k == null || !_defThresholds.containsKey(k)) return 40;
    return _defThresholds[k]!.xThreshold;
  }

  double get currentYFreq {
    final k = _currentDefKey;
    if (k == null || !_defThresholds.containsKey(k)) return 30;
    return _defThresholds[k]!.yFreq;
  }

  void setCurrentXThreshold(double v) {
    final k = _currentDefKey;
    if (k == null) return;
    final c = _defThresholds[k]!;
    _defThresholds[k] = (xThreshold: v.clamp(10, 90), yFreq: c.yFreq);
    _isSaved = false;
    notifyListeners();
  }

  void setCurrentYFreq(double v) {
    final k = _currentDefKey;
    if (k == null) return;
    final c = _defThresholds[k]!;
    _defThresholds[k] = (xThreshold: c.xThreshold, yFreq: v.clamp(8, 75));
    _isSaved = false;
    notifyListeners();
  }

  // Auto-assign: assign all-combination-Good to O1, all-Bad to O3, mixed to O2
  void autoAssignCombos() {
    for (final dk in definitions) {
      final tokens = dk.split('|');
      final allGood = tokens.every((t) => t.endsWith('=Good'));
      final allBad = tokens.every((t) => t.endsWith('=Bad'));
      _comboOutlets[dk] = {
        allGood
            ? 1
            : allBad
                ? 3
                : 2
      };
    }
    _isSaved = false;
    notifyListeners();
  }

  // Per-combo outlet assignment (drag & drop)
  final Map<String, Set<int>> _comboOutlets = {};
  Map<String, int> get comboOutlets => {}; // Keep backward-compatible, not used
  List<String> combosForOutlet(int n) => _comboOutlets.entries
      .where((e) => e.value.contains(n))
      .map((e) => e.key)
      .toList();
  bool isComboAssigned(String defKey) =>
      _comboOutlets.containsKey(defKey) && _comboOutlets[defKey]!.isNotEmpty;
  bool isComboInOutlet(String defKey, int n) =>
      _comboOutlets[defKey]?.contains(n) ?? false;

  // Batch selection for manual assign
  final Set<String> _selectedForAssign = {};
  Set<String> get selectedForAssign => _selectedForAssign;
  int get selectedCount => _selectedForAssign.length;
  void toggleSelectForAssign(String dk) {
    if (_selectedForAssign.contains(dk))
      _selectedForAssign.remove(dk);
    else
      _selectedForAssign.add(dk);
    notifyListeners();
  }

  void clearBatchSelection() {
    _selectedForAssign.clear();
    notifyListeners();
  }

  void assignSelectedToOutlet(int n) {
    for (final dk in _selectedForAssign) {
      _comboOutlets.putIfAbsent(dk, () => {}).add(n);
    }
    _selectedForAssign.clear();
    _isSaved = false;
    notifyListeners();
  }

  void assignComboToOutlet(String defKey, int outlet) {
    _comboOutlets.putIfAbsent(defKey, () => {}).add(outlet);
    _isSaved = false;
    notifyListeners();
  }

  void removeComboFromOutlet(String defKey, int outlet) {
    _comboOutlets[defKey]?.remove(outlet);
    if (_comboOutlets[defKey]?.isEmpty == true) _comboOutlets.remove(defKey);
    _isSaved = false;
    notifyListeners();
  }

  void removeCombo(String defKey) {
    _comboOutlets.remove(defKey);
    _isSaved = false;
    notifyListeners();
  }

  int get assignedComboCount => _comboOutlets.length;

  // Outlet filters
  String _filterDefect = 'all',
      _filterGrade = 'all',
      _filterOutlet = 'all',
      _filterStatus = 'all';
  String get filterDefect => _filterDefect;
  String get filterGrade => _filterGrade;
  String get filterOutlet => _filterOutlet;
  String get filterStatus => _filterStatus;

  // View mode for Defects step
  String _viewMode = 'grid';
  String get viewMode => _viewMode;
  void setViewMode(String mode) {
    _viewMode = mode;
    notifyListeners();
  }

  List<String> get filteredCombinations {
    var list = definitions;
    if (_searchQuery.isNotEmpty)
      list = list
          .where((dk) =>
              comboLabel(dk).toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    if (_filterDefect != 'all')
      list = list.where((dk) => dk.contains('$_filterDefect=')).toList();
    if (_filterGrade == 'Good')
      list = list
          .where((dk) => dk.split('|').every((t) => t.endsWith('=Good')))
          .toList();
    else if (_filterGrade == 'Bad')
      list = list
          .where((dk) => dk.split('|').every((t) => t.endsWith('=Bad')))
          .toList();
    else if (_filterGrade == 'Mixed')
      list = list
          .where((dk) =>
              dk.split('|').map((t) => t.split('=').last).toSet().length > 1)
          .toList();
    if (_filterOutlet != 'all')
      list = list
          .where((dk) => isComboInOutlet(dk, int.parse(_filterOutlet)))
          .toList();
    if (_filterStatus != 'all')
      list = list.where((dk) => comboStatus(dk) == _filterStatus).toList();
    return list;
  }

  void setFilterDefect(String v) {
    _filterDefect = v;
    notifyListeners();
  }

  void setFilterGrade(String v) {
    _filterGrade = v;
    notifyListeners();
  }

  void setFilterOutlet(String v) {
    _filterOutlet = v;
    notifyListeners();
  }

  void setFilterStatus(String v) {
    _filterStatus = v;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _filterDefect = _filterGrade = _filterOutlet = _filterStatus = 'all';
    notifyListeners();
  }

  // Summary stats
  int get totalCombinations => definitions.length;
  int get goodCount => definitions
      .where((dk) => dk.split('|').every((t) => t.endsWith('=Good')))
      .length;
  int get sbCount => definitions
      .where((dk) =>
          dk.split('|').map((t) => t.split('=').last).toSet().length > 1)
      .length;
  int get badCount => definitions
      .where((dk) => dk.split('|').every((t) => t.endsWith('=Bad')))
      .length;
  int get configuredCount =>
      definitions.where((dk) => comboStatus(dk) == 'Configured').length;
  int get pendingCount =>
      definitions.where((dk) => comboStatus(dk) != 'Configured').length;
  Map<int, int> get outletDistribution => {
        1: combosForOutlet(1).length,
        2: combosForOutlet(2).length,
        3: combosForOutlet(3).length
      };

  // Validation
  String comboStatus(String defKey) {
    return isComboAssigned(defKey) ? 'Configured' : 'Pending';
  }

  // Validation warnings
  List<String> get validationWarnings {
    final w = <String>[];
    // Unassigned combos
    final unassigned =
        definitions.where((dk) => isComboAssigned(dk) == false).toList();
    if (unassigned.isNotEmpty)
      w.add('${unassigned.length} combination(s) not assigned to any outlet');
    // Empty outlets
    if (combosForOutlet(1).isEmpty) w.add('Outlet 1 is empty');
    if (combosForOutlet(2).isEmpty) w.add('Outlet 2 is empty');
    if (combosForOutlet(3).isEmpty) w.add('Outlet 3 is empty');
    // Duplicate assignments
    final dupes = definitions
        .where((dk) => (_comboOutlets[dk]?.length ?? 0) > 1)
        .toList();
    if (dupes.isNotEmpty)
      w.add('${dupes.length} combination(s) assigned to multiple outlets');
    return w;
  }

  // Export JSON
  String exportJSON() {
    final sb = StringBuffer();
    sb.writeln('{');

    // Program info
    sb.writeln('  "ProgramName": "${_programName}",');
    sb.writeln('  "ProduceName": "${_produceName}",');
    sb.writeln('  "DeleteEnable": false,');

    // ColourGrades
    sb.writeln('  "ColourGrades": {');
    sb.writeln('    "ColourGradeTable": [');
    for (int i = 0; i < _colourGrades.colourGradeTable.length; i++) {
      final cg = _colourGrades.colourGradeTable[i];
      sb.writeln('      {');
      sb.writeln('        "ColourGradeName": "${cg.colourGradeName}",');
      sb.writeln('        "Colour": {');
      sb.writeln('          "ColourRange": [');
      for (int j = 0; j < cg.colour.colourRange.length; j++) {
        final r = cg.colour.colourRange[j];
        sb.writeln('            {');
        sb.writeln('              "Name": "${r.name}",');
        sb.writeln('              "ColourPercent": {');
        sb.writeln(
            '                "Min": ${r.colourPercent.min}, "Max": ${r.colourPercent.max}');
        sb.writeln('              }');
        sb.writeln(
            '            }${j < cg.colour.colourRange.length - 1 ? "," : ""}');
      }
      sb.writeln('          ]');
      sb.writeln('        }');
      sb.writeln(
          '      }${i < _colourGrades.colourGradeTable.length - 1 ? "," : ""}');
    }
    sb.writeln('    ]');
    sb.writeln('  },');

    // SizeGrades
    sb.writeln('  "SizeGrades": {');
    if (_sizeGrades.sizeClassification != null) {
      sb.writeln(
          '    "SizeClassification": "${_sizeGrades.sizeClassification}",');
    }
    sb.writeln('    "SizeGradeTable": [');
    for (int i = 0; i < _sizeGrades.sizeGradeTable.length; i++) {
      final sg = _sizeGrades.sizeGradeTable[i];
      sb.writeln('      {');
      sb.writeln('        "Name": "${sg.name}",');
      sb.writeln('        "Min": ${sg.min},');
      sb.writeln('        "Max": ${sg.max}');
      sb.writeln(
          '      }${i < _sizeGrades.sizeGradeTable.length - 1 ? "," : ""}');
    }
    sb.writeln('    ]');
    sb.writeln('  },');

    // WeightGrades
    sb.writeln('  "WeightGrades": {');
    sb.writeln('    "WeightGradeTable": [');
    for (int i = 0; i < _weightGrades.weightGradeTable.length; i++) {
      final wg = _weightGrades.weightGradeTable[i];
      sb.writeln('      {');
      sb.writeln('        "Name": "${wg.name}",');
      sb.writeln('        "Min": ${wg.min},');
      sb.writeln('        "Max": ${wg.max}');
      sb.writeln(
          '      }${i < _weightGrades.weightGradeTable.length - 1 ? "," : ""}');
    }
    sb.writeln('    ]');
    sb.writeln('  },');

    // FeatureTable
    sb.writeln('  "FeatureTable": [');
    for (int i = 0; i < _selectedDefectIds.length; i++) {
      final defectId = _selectedDefectIds.elementAt(i);
      final d = _defects.firstWhere((x) => x.id == defectId);
      final xThresh = _computeHistogramThreshold(defectId);
      final featureName = d.name.toLowerCase().replaceAll(' ', '');
      sb.writeln('    {');
      sb.writeln('      "FeatureName": "$featureName",');
      sb.writeln('      "No(1)/TotalUnit(2)/Histogram(3)": 3,');
      sb.writeln('      "FeatureGradeTable": [');
      sb.writeln('        {');
      sb.writeln('          "FeatureGradeName": "Defective",');
      sb.writeln('          "ValueMin": $xThresh,');
      sb.writeln('          "ValueMax": 10000,');
      sb.writeln('          "BandMin": 0,');
      sb.writeln('          "BandMax": 0');
      sb.writeln('        },');
      sb.writeln('        {');
      sb.writeln('          "FeatureGradeName": "Good",');
      sb.writeln('          "ValueMin": 0,');
      sb.writeln('          "ValueMax": $xThresh,');
      sb.writeln('          "BandMin": 0,');
      sb.writeln('          "BandMax": 0');
      sb.writeln('        }');
      sb.writeln('      ]');
      sb.writeln('    }${i < _selectedDefectIds.length - 1 ? "," : ""}');
    }
    sb.writeln('  ],');

    // SpectroFeatureTable
    sb.writeln('  "SpectroFeatureTable": [],');

    // OutletMapping
    sb.writeln('  "OutletMapping": [');
    final outletNumbers = <int>{};
    for (final entry in _comboOutlets.entries) {
      outletNumbers.addAll(entry.value);
    }
    final sortedOutlets = outletNumbers.toList()..sort();
    for (int oi = 0; oi < sortedOutlets.length; oi++) {
      final n = sortedOutlets[oi];
      final combos = combosForOutlet(n);
      sb.writeln('    {');
      sb.writeln('      "OutletDescription": "Outlet $n",');
      sb.writeln('      "FeatureCombinations": [');
      for (int ci = 0; ci < combos.length; ci++) {
        final dk = combos[ci];
        final tokens = dk.split('|');
        final features = tokens.map((t) {
          final parts = t.split('=');
          final defectModel = _defects.firstWhere((x) => x.id == parts[0]);
          return '${defectModel.name.toLowerCase().replaceAll(' ', '')} - ${parts[1]}';
        }).toList();
        sb.writeln('        {');
        sb.writeln('          "Color": "${_comboColour[dk] ?? ""}",');
        sb.writeln('          "Size": "${_comboSize[dk] ?? ""}",');
        sb.writeln('          "Weight": "${_comboWeight[dk] ?? ""}",');
        sb.writeln('          "Features": [');
        for (int fi = 0; fi < features.length; fi++) {
          sb.writeln(
              '            "${features[fi]}"${fi < features.length - 1 ? "," : ""}');
        }
        sb.writeln('          ]');
        sb.writeln('        }${ci < combos.length - 1 ? "," : ""}');
      }
      sb.writeln('      ]');
      sb.writeln('    }${oi < sortedOutlets.length - 1 ? "," : ""}');
    }
    sb.writeln('  ]');
    sb.writeln('}');
    return sb.toString();
  }

  String comboLabel(String defKey) {
    return defKey.split('|').map((token) {
      final parts = token.split('=');
      final d = _defects.firstWhere((x) => x.id == parts[0]);
      return '${d.name}: ${parts[1]}';
    }).join(', ');
  }

  void resetCombos() {
    _comboOutlets.clear();
    _isSaved = false;
    notifyListeners();
  }

  // Search & filter
  String _searchQuery = '';
  String? _activeCategory;
  String _statusFilter = 'All';
  String _sortBy = 'Name';
  bool _filterExpanded = true;
  String get searchQuery => _searchQuery;
  String? get activeCategory => _activeCategory;
  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  bool get filterExpanded => _filterExpanded;

  List<DefectModel> get filteredDefects {
    var list = _defects.toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
              (d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_activeCategory != null) {
      list = list.where((d) => d.category == _activeCategory).toList();
    }
    if (_statusFilter == 'Selected') {
      list = list.where((d) => _selectedDefectIds.contains(d.id)).toList();
    }
    if (_statusFilter == 'Not Selected') {
      list = list.where((d) => !_selectedDefectIds.contains(d.id)).toList();
    }
    return list;
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategoryFilter(String? cat) {
    _activeCategory = cat;
    notifyListeners();
  }

  void setStatusFilter(String s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setSortBy(String s) {
    _sortBy = s;
    notifyListeners();
  }

  void toggleFilterPanel() {
    _filterExpanded = !_filterExpanded;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _activeCategory = null;
    _statusFilter = 'All';
    _sortBy = 'Name';
    notifyListeners();
  }

  // Preset
  String _selectedPreset = 'Balanced';
  String get selectedPreset => _selectedPreset;

  // Advanced
  bool _showAdvanced = false;
  double _minDefectSize = 5;
  double _minDefectCount = 1;
  double _minConfidence = 70;
  double _minPixelArea = 100;
  bool get showAdvanced => _showAdvanced;
  double get minDefectSize => _minDefectSize;
  double get minDefectCount => _minDefectCount;
  double get minConfidence => _minConfidence;
  double get minPixelArea => _minPixelArea;

  // Login
  String _username = '';
  String _role = '';
  bool _loggedIn = false;
  String get username => _username;
  String get role => _role;
  bool get loggedIn => _loggedIn;

  // Save state
  bool _isSaved = true;
  bool get isSaved => _isSaved;
  String? _saveError;
  String? get saveError => _saveError;

  // Outlet assignments
  final Map<String, int> _outletAssignments = {};
  double _defectiveSplitPct = 100;
  Map<String, int> get outletAssignments =>
      Map.unmodifiable(_outletAssignments);
  double get defectiveSplitPct => _defectiveSplitPct;
  bool get allGradesAssigned =>
      _outletAssignments.containsKey('Good') &&
      _outletAssignments.containsKey('Defective');

  void setOutletAssignment(String qc, int n) {
    _outletAssignments[qc] = n;
    _isSaved = false;
    notifyListeners();
  }

  void setDefectiveSplit(double pct) {
    _defectiveSplitPct = pct.clamp(0, 100);
    _outletAssignments['Defective'] = 0;
    _isSaved = false;
    notifyListeners();
  }

  void autoAssignOutlets() {
    _outletAssignments['Good'] = 1;
    _outletAssignments['Defective'] = 2;
    _defectiveSplitPct = 100;
    _isSaved = false;
    notifyListeners();
  }

  void resetOutlets() {
    _outletAssignments.clear();
    _defectiveSplitPct = 100;
    _isSaved = false;
    notifyListeners();
  }

  // Combo assignments: 'D01-Good' → outletNum (1-3)
  // Combination filters
  bool _filtersExpanded = false;
  String _combinationFilter = 'all';
  final Set<String> _gradeFilters = {};
  bool get filtersExpanded => _filtersExpanded;
  String get combinationFilter => _combinationFilter;
  Set<String> get gradeFilters => _gradeFilters;
  void toggleFilters() {
    _filtersExpanded = !_filtersExpanded;
    notifyListeners();
  }

  void setCombinationFilter(String f) {
    _combinationFilter = f;
    notifyListeners();
  }

  void toggleGradeFilter(String g) {
    if (_gradeFilters.contains(g))
      _gradeFilters.remove(g);
    else
      _gradeFilters.add(g);
    notifyListeners();
  }

  // Sample data (2D: x = defect value, y = frequency)
  final List<({double x, double y})> _sampleData = _genSample2D(200);
  List<({double x, double y})> get sampleData => _sampleData;

  // =================== Computed ===================

  ClassificationModel? get classification {
    if (_sampleData.isEmpty) return null;
    final avgX = _sampleData.map((p) => p.x).reduce((a, b) => a + b) /
        _sampleData.length;
    final avgY = _sampleData.map((p) => p.y).reduce((a, b) => a + b) /
        _sampleData.length;
    final cls = _classify(avgX, avgY);
    final same = _sampleData.where((p) => _classify(p.x, p.y) == cls).length;
    final conf = _sampleData.isNotEmpty
        ? (same / _sampleData.length * 100).clamp(50.0, 99.0)
        : 50.0;
    return ClassificationModel(
        qualityClass: cls,
        currentValue: avgX,
        reason: '$cls: x=${avgX.round()} mm², y=${avgY.round()} freq',
        confidence: conf);
  }

  String _classify(double x, double y) {
    final yT = currentYFreq;
    if (y < yT) return 'Good';
    return 'Bad';
  }

  double get goodPct => _sampleData.isEmpty
      ? 0
      : (_sampleData.where((p) => _classify(p.x, p.y) == 'Good').length /
          _sampleData.length *
          100);
  double get sbPct => _sampleData.isEmpty
      ? 0
      : (_sampleData
              .where((p) => _classify(p.x, p.y) == 'Slightly Bad')
              .length /
          _sampleData.length *
          100);
  double get badPct => _sampleData.isEmpty
      ? 0
      : (_sampleData.where((p) => _classify(p.x, p.y) == 'Bad').length /
          _sampleData.length *
          100);

  RecommendationModel? get recommendation {
    final c = classification;
    if (c == null) return null;
    final out = _outputs.firstWhere((o) => o.qualityClass == c.qualityClass,
        orElse: () => _outputs.first);
    return RecommendationModel(
        qualityClass: c.qualityClass,
        outputName: out.name,
        reason: c.reason,
        confidence: c.confidence);
  }

  // =================== Actions ===================

  // Steps
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps && step <= _currentStep) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void _clearAssignments() {
    _comboOutlets.clear();
    _comboColour.clear();
    _comboSize.clear();
    _comboWeight.clear();
    _defThresholds.clear();
    _currentDefKey = null;
    _savedDefects.clear();
    _defectFrequencies.clear();
  }

  // Defects
  void toggleDefect(String id) {
    if (_selectedDefectIds.contains(id))
      _selectedDefectIds.remove(id);
    else
      _selectedDefectIds.add(id);
    _clearAssignments();
    _isSaved = false;
    notifyListeners();
  }

  void selectAllDefects() {
    _selectedDefectIds.addAll(_defects.map((d) => d.id));
    _clearAssignments();
    _isSaved = false;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDefectIds.clear();
    _clearAssignments();
    _isSaved = false;
    notifyListeners();
  }

  void invertSelection() {
    final s = _selectedDefectIds.toSet();
    _selectedDefectIds.clear();
    for (final d in _defects) {
      if (!s.contains(d.id)) _selectedDefectIds.add(d.id);
    }
    _clearAssignments();
    _isSaved = false;
    notifyListeners();
  }

  // Advanced
  void toggleAdvanced() {
    _showAdvanced = !_showAdvanced;
    notifyListeners();
  }

  void applyPreset(String name) {
    _selectedPreset = name;
    _histogramConfig.applyPreset(name);
    _isSaved = false;
    notifyListeners();
  }

  void setAdvanced(String key, double value) {
    switch (key) {
      case 'histogramMin':
        _histogramConfig.histogramMin = value;
        break;
      case 'histogramMax':
        _histogramConfig.histogramMax = value;
        break;
      case 'bandMin':
        _histogramConfig.bandMin = value;
        break;
      case 'bandMax':
        _histogramConfig.bandMax = value;
        break;
      case 'minDefectSize':
        _minDefectSize = value;
        break;
      case 'minDefectCount':
        _minDefectCount = value;
        break;
      case 'minConfidence':
        _minConfidence = value;
        break;
      case 'minPixelArea':
        _minPixelArea = value;
        break;
    }
    _isSaved = false;
    notifyListeners();
  }

  void loadVisionFeatures(List<FeatureClass> features) {
    _defects.clear();
    for (int i = 0; i < features.length; i++) {
      final f = features[i];
      final id = 'F${(i + 1).toString().padLeft(2, '0')}';
      _defects.add(DefectModel(
        id: id,
        name: _capitalize(f.featureName),
        category: 'Vision Defect',
        description: '${f.featureName} (${f.measuringAttributes.units}: '
            '${f.measuringAttributes.measurementMin}-${f.measuringAttributes.measurementMax})',
      ));
    }
    notifyListeners();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Save
  Future<void> saveConfiguration(
      {String programName = '', String produceName = ''}) async {
    final defect = _defects.firstWhere((d) => _selectedDefectIds.contains(d.id),
        orElse: () => _defects.first);
    final config = ConfigurationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      defectId: defect.id,
      qualityClass: classification?.qualityClass ?? '',
      outputId: recommendation?.outputName ?? '',
      preset: _selectedPreset,
      status: 'Active',
      updatedAt: DateTime.now(),
    );
    _configurations.add(config);
    defect.configured = true;
    _isSaved = true;

    final featureEntries = <FeatureEntry>[];
    for (final defectId in _selectedDefectIds) {
      final d = _defects.firstWhere((x) => x.id == defectId);
      final featureName = d.name.toLowerCase().replaceAll(' ', '');
      final xThresh = _computeHistogramThreshold(defectId);
      final grades = <FeatureGrade>[
        FeatureGrade(
          featureGradeName: 'Defective',
          valueMin: xThresh,
          valueMax: 10000,
        ),
        FeatureGrade(
          featureGradeName: 'Good',
          valueMin: 0,
          valueMax: xThresh,
        ),
      ];
      featureEntries.add(FeatureEntry(
        featureName: featureName,
        gradingMode: 3,
        featureGradeTable: grades,
      ));
    }

    final outletMappingList = <OutletMapping>[];
    for (final n in [1, 2, 3]) {
      final combos = combosForOutlet(n);
      if (combos.isEmpty) continue;
      final fcList = combos.map((dk) {
        final tokens = dk.split('|');
        final features = tokens.map((t) {
          final parts = t.split('=');
          final defectModel = _defects.firstWhere((x) => x.id == parts[0]);
          return '${defectModel.name.toLowerCase().replaceAll(' ', '')} - ${parts[1]}';
        }).toList();
        return FeatureCombination(
          color: _comboColour[dk] ?? '',
          size: _comboSize[dk] ?? '',
          weight: _comboWeight[dk] ?? '',
          features: features,
        );
      }).toList();
      outletMappingList.add(OutletMapping(
        outletDescription: 'Outlet $n',
        featureCombinations: fcList,
      ));
    }

    final program = ProgramModel(
      programName: programName.isNotEmpty ? programName : 'Untitled',
      produceName: produceName,
      deleteEnable: false,
      colourGrades: _colourGrades,
      sizeGrades: _sizeGrades,
      weightGrades: _weightGrades,
      featureTable: featureEntries,
      outletMapping: outletMappingList,
    );

    final jsonStr =
        const JsonEncoder.withIndent('  ').convert(program.toJson());
    try {
      final fileName = programName.isNotEmpty ? programName : 'Untitled';
      await saveProgramFile(fileName, jsonStr);
      _saveError = null;
    } catch (e) {
      _saveError = 'Failed to save: $e';
    }

    notifyListeners();
  }

  void deleteConfig(String id) {
    _configurations.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // =================== Colour / Size / Weight Grades ===================

  ColourGrades _colourGrades = ColourGrades(colourGradeTable: []);
  SizeGrades _sizeGrades = SizeGrades(sizeGradeTable: []);
  WeightGrades _weightGrades = WeightGrades(weightGradeTable: []);

  ColourGrades get colourGrades => _colourGrades;
  SizeGrades get sizeGrades => _sizeGrades;
  WeightGrades get weightGrades => _weightGrades;

  List<String> get colourGradeNames =>
      _colourGrades.colourGradeTable.map((c) => c.colourGradeName).toList();
  List<String> get sizeGradeNames =>
      _sizeGrades.sizeGradeTable.map((s) => s.name).toList();
  List<String> get weightGradeNames =>
      _weightGrades.weightGradeTable.map((w) => w.name).toList();

  // Per-combo colour/size/weight grade assignment: definitionKey -> grade name
  final Map<String, String> _comboColour = {};
  final Map<String, String> _comboSize = {};
  final Map<String, String> _comboWeight = {};

  Map<String, String> get comboColour => _comboColour;
  Map<String, String> get comboSize => _comboSize;
  Map<String, String> get comboWeight => _comboWeight;

  String comboColourFor(String defKey) => _comboColour[defKey] ?? '';
  String comboSizeFor(String defKey) => _comboSize[defKey] ?? '';
  String comboWeightFor(String defKey) => _comboWeight[defKey] ?? '';

  void setComboColour(String defKey, String grade) {
    if (grade.isEmpty)
      _comboColour.remove(defKey);
    else
      _comboColour[defKey] = grade;
    _isSaved = false;
    notifyListeners();
  }

  void setComboSize(String defKey, String grade) {
    if (grade.isEmpty)
      _comboSize.remove(defKey);
    else
      _comboSize[defKey] = grade;
    _isSaved = false;
    notifyListeners();
  }

  void setComboWeight(String defKey, String grade) {
    if (grade.isEmpty)
      _comboWeight.remove(defKey);
    else
      _comboWeight[defKey] = grade;
    _isSaved = false;
    notifyListeners();
  }

  // Colour grade CRUD
  void addColourGrade(String name) {
    _colourGrades.colourGradeTable.add(ColourGradeTable(
      colourGradeName: name,
      colour: Colour(colourRange: ColourRange.defaults),
    ));
    _isSaved = false;
    notifyListeners();
  }

  void removeColourGrade(int index) {
    if (index >= 0 && index < _colourGrades.colourGradeTable.length) {
      _colourGrades.colourGradeTable.removeAt(index);
      _isSaved = false;
      notifyListeners();
    }
  }

  void updateColourGradeName(int index, String name) {
    if (index >= 0 && index < _colourGrades.colourGradeTable.length) {
      _colourGrades.colourGradeTable[index].colourGradeName = name;
      _isSaved = false;
      notifyListeners();
    }
  }

  void updateColourRange(
      int gradeIndex, int rangeIndex, double min, double max) {
    if (gradeIndex >= 0 && gradeIndex < _colourGrades.colourGradeTable.length) {
      final range =
          _colourGrades.colourGradeTable[gradeIndex].colour.colourRange;
      if (rangeIndex >= 0 && rangeIndex < range.length) {
        range[rangeIndex].colourPercent.min = min;
        range[rangeIndex].colourPercent.max = max;
        _isSaved = false;
        notifyListeners();
      }
    }
  }

  // Size grade CRUD
  void addSizeGrade(String name, double min, double max) {
    _sizeGrades.sizeGradeTable
        .add(SizeGradeTable(name: name, min: min, max: max));
    _isSaved = false;
    notifyListeners();
  }

  void removeSizeGrade(int index) {
    if (index >= 0 && index < _sizeGrades.sizeGradeTable.length) {
      _sizeGrades.sizeGradeTable.removeAt(index);
      _isSaved = false;
      notifyListeners();
    }
  }

  void updateSizeGrade(int index, String name, double min, double max) {
    if (index >= 0 && index < _sizeGrades.sizeGradeTable.length) {
      _sizeGrades.sizeGradeTable[index].name = name;
      _sizeGrades.sizeGradeTable[index].min = min;
      _sizeGrades.sizeGradeTable[index].max = max;
      _isSaved = false;
      notifyListeners();
    }
  }

  void setSizeClassification(String v) {
    _sizeGrades.sizeClassification = v;
    _isSaved = false;
    notifyListeners();
  }

  // Weight grade CRUD
  void addWeightGrade(String name, double min, double max) {
    _weightGrades.weightGradeTable
        .add(WeightGradeTable(name: name, min: min, max: max));
    _isSaved = false;
    notifyListeners();
  }

  void removeWeightGrade(int index) {
    if (index >= 0 && index < _weightGrades.weightGradeTable.length) {
      _weightGrades.weightGradeTable.removeAt(index);
      _isSaved = false;
      notifyListeners();
    }
  }

  // Login
  void login(String name, String r) {
    _username = name;
    _role = r;
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = '';
    _role = '';
    _loggedIn = false;
    notifyListeners();
  }

  static List<({double x, double y})> _genSample2D(int count) {
    final r = <({double x, double y})>[];
    for (int i = 0; i < count; i++) {
      final base = ((i % 5) + (i ~/ 5 % 4)) * 8 + ((i * 7) % 100) / 10.0;
      final x = base.clamp(0, 100) + ((i * 7919) % 1000) / 1000.0 * 5;
      final y = 5.0 + ((i * 104729 + 13) % 1000) / 1000.0 * 70;
      r.add((x: x.clamp(0, 100), y: y.clamp(0, 80)));
    }
    r.shuffle();
    return r;
  }
}
