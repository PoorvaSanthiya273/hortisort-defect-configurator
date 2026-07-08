import 'package:flutter/foundation.dart';
import '../models/defect_model.dart';
import '../models/zone_model.dart';
import '../models/histogram_config.dart';
import '../models/classification_model.dart';

class ConfiguratorProvider extends ChangeNotifier {
  final List<DefectModel> _defects = DefectModel.defaults;
  final List<ZoneModel> _zones = ZoneModel.defaults;
  final HistogramConfig _histogramConfig = HistogramConfig();
  final List<OutputModel> _outputs = OutputModel.defaults;
  final List<ConfigurationModel> _configurations = [];

  List<DefectModel> get defects => _defects;
  List<ZoneModel> get zones => _zones;
  HistogramConfig get histogramConfig => _histogramConfig;
  List<OutputModel> get outputs => _outputs;
  List<ConfigurationModel> get configurations => _configurations;

  // Draggable histogram state
  double _histogramMin = 0;
  double _histogramMax = 120;
  int _histogramNoOfBands = 10;
  // Per-defect frequencies: 'defectId-zoneId' → {bandIndex: frequency}
  final Map<String, Map<int, double>> _defectFrequencies = {};

  double get histogramMin => _histogramMin;
  double get histogramMax => _histogramMax;
  int get histogramNoOfBands => _histogramNoOfBands;
  double get bandSize => (_histogramMax - _histogramMin) / _histogramNoOfBands;

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

  void setBandFrequency(String defectKey, int index, double value) {
    _defectFrequencies.putIfAbsent(defectKey, () => {});
    _defectFrequencies[defectKey]![index] = value < 0 ? 0.0 : value;
    _isSaved = false;
    notifyListeners();
  }

  void initDefectFrequencies(String defectKey) {
    if (_defectFrequencies.containsKey(defectKey)) return;
    _defectFrequencies[defectKey] = {};
    final mid = _histogramNoOfBands ~/ 2;
    for (int i = 0; i < _histogramNoOfBands; i++) {
      final dist = (i - mid).abs();
      _defectFrequencies[defectKey]![i] =
          ((mid + 1 - dist) * 12).toDouble().clamp(5, 60);
    }
    notifyListeners();
  }

  void resetDefectFrequencies(String defectKey) {
    _defectFrequencies[defectKey]?.clear();
    _isSaved = false;
    notifyListeners();
  }

  Future<void> saveHistogramConfig() async {
    // In a real app, this would write to a file or API
    // For now, we just mark as saved
    _isSaved = true;
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
  bool get canProceedFromDefects =>
      _selectedDefectIds.isNotEmpty && _selectedZoneIds.isNotEmpty;
  DefectModel? get activeDefect => _selectedDefectIds.isNotEmpty
      ? _defects.firstWhere((d) => d.id == _selectedDefectIds.first)
      : _defects.first;

  // Zone selection (Step 2)
  final Set<String> _selectedZoneIds = {'Z01'};
  Set<String> get selectedZoneIds => _selectedZoneIds;
  int get selectedZoneCount => _selectedZoneIds.length;
  bool get canProceedFromZones => _selectedZoneIds.isNotEmpty;

  // Generated definitions: 'defectId-zoneId' keys
  List<String> get definitions => _selectedDefectIds
      .expand((dId) => _selectedZoneIds.map((zId) => '$dId-$zId'))
      .toList();

  void toggleZone(String id) {
    if (_selectedZoneIds.contains(id))
      _selectedZoneIds.remove(id);
    else
      _selectedZoneIds.add(id);
    _isSaved = false;
    notifyListeners();
  }

  // Per-definition thresholds: 'defectId-zoneId' → (xThreshold, yFreq)
  final Map<String, ({double xThreshold, double yFreq})> _defThresholds = {};
  String? _currentDefKey;

  String? get currentDefKey => _currentDefKey; // for histogram step

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
    var k = _currentDefKey;
    if (k == null && definitions.isNotEmpty) k = definitions.first;
    if (k == null) return;
    if (!_defThresholds.containsKey(k))
      _defThresholds[k] = (xThreshold: 40, yFreq: 30);
    final parts = k.split('-');
    _defects.firstWhere((d) => d.id == parts[0]).configured = true;
    notifyListeners();
  }

  void saveAllDefs() {
    for (final dk in definitions) {
      final parts = dk.split('-');
      _defects.firstWhere((d) => d.id == parts[0]).configured = true;
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

  // Per-definition grades: 'defectId-zoneId' → 'Good'|'Slightly Bad'|'Bad'
  final Map<String, String> _defGrades = {};
  String? gradeFor(String defKey) => _defGrades[defKey];
  void setDefGrade(String defKey, String grade) {
    _defGrades[defKey] = grade;
    _isSaved = false;
    notifyListeners();
  }

  void autoAssignGrades() {
    for (final dk in definitions) {
      if (!_defThresholds.containsKey(dk)) {
        _defThresholds[dk] = (xThreshold: 40, yFreq: 30);
      }
      _defGrades[dk] = _classifyDef(dk);
    }
    _isSaved = false;
    notifyListeners();
  }

  void autoAssignCombos() {
    for (final dk in definitions) {
      _comboOutlets[dk] = {
        _defGrades[dk] == 'Good'
            ? 1
            : _defGrades[dk] == 'Slightly Bad'
                ? 2
                : 3
      };
    }
    _isSaved = false;
    notifyListeners();
  }

  void resetGrades() {
    _defGrades.clear();
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
      _filterZone = 'all',
      _filterGrade = 'all',
      _filterOutlet = 'all',
      _filterStatus = 'all';
  String get filterDefect => _filterDefect;
  String get filterZone => _filterZone;
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
      list = list.where((dk) => dk.startsWith(_filterDefect)).toList();
    if (_filterZone != 'all')
      list = list.where((dk) => dk.endsWith('-$_filterZone')).toList();
    if (_filterGrade != 'all')
      list = list.where((dk) => gradeFor(dk) == _filterGrade).toList();
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

  void setFilterZone(String v) {
    _filterZone = v;
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
    _filterDefect =
        _filterZone = _filterGrade = _filterOutlet = _filterStatus = 'all';
    notifyListeners();
  }

  // Summary stats
  int get totalCombinations => definitions.length;
  int get goodCount => definitions.where((dk) => gradeFor(dk) == 'Good').length;
  int get sbCount =>
      definitions.where((dk) => gradeFor(dk) == 'Slightly Bad').length;
  int get badCount => definitions.where((dk) => gradeFor(dk) == 'Bad').length;
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
    final grade = gradeFor(defKey);
    final assigned = isComboAssigned(defKey);
    if (grade != null && assigned) return 'Configured';
    if (grade == null && !assigned) return 'Missing Both';
    if (grade == null) return 'Missing Grade';
    if (!assigned) return 'Pending';
    return 'Configured';
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

  // Export JSON matching ADANI2025FC16New structure
  String exportJSON() {
    final sb = StringBuffer();
    sb.writeln('{');
    sb.writeln('  "FeatureTable": [');
    for (final dk in definitions) {
      final parts = dk.split('-');
      final d = _defects.firstWhere((x) => x.id == parts[0]);
      final z = _zones.firstWhere((x) => x.id == parts[1]);
      final grade = gradeFor(dk) ?? 'Ungraded';
      final outlets = _comboOutlets[dk]?.toList() ?? [];
      final t = _defThresholds[dk];
      sb.writeln('    {');
      sb.writeln('      "FeatureName": "${d.name}",');
      sb.writeln('      "Zone": "${z.name}",');
      sb.writeln('      "FeatureCombination": "$dk",');
      sb.writeln('      "FeatureGradeName": "$grade",');
      sb.writeln('      "XThreshold": ${t?.xThreshold ?? 40},');
      sb.writeln('      "YThreshold": ${t?.yFreq ?? 30},');
      sb.writeln('      "OutletMapping": [${outlets.join(',')}]');
      sb.writeln('    },');
    }
    sb.writeln('  ],');
    sb.writeln('  "OutletMapping": [');
    for (final n in [1, 2, 3]) {
      final combos = combosForOutlet(n);
      sb.writeln('    {');
      sb.writeln('      "OutletNumber": $n,');
      sb.writeln('      "OutletDescription": "Outlet $n",');
      sb.writeln('      "Combinations": [');
      for (final dk in combos) {
        sb.writeln('        "$dk",');
      }
      sb.writeln('      ]');
      sb.writeln('    },');
    }
    sb.writeln('  ]');
    sb.writeln('}');
    return sb.toString();
  }

  String comboLabel(String defKey) {
    final parts = defKey.split('-');
    final d = _defects.firstWhere((x) => x.id == parts[0]),
        z = _zones.firstWhere((x) => x.id == parts[1]);
    return '${d.name} @ ${z.name}';
  }

  void resetCombos() {
    _comboOutlets.clear();
    _isSaved = false;
    notifyListeners();
  }

  int get assignedGradeCount => _defGrades.length;

  // Search & filter
  String _searchQuery = '';
  String? _activeCategory;
  String _statusFilter = 'All';
  String _sortBy = 'Name';
  bool _filterExpanded = false;
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

  // Zone selection
  String _selectedZoneId = 'Z01';
  String get selectedZoneId => _selectedZoneId;

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

  String _classifyDef(String defKey) {
    final t = _defThresholds[defKey];
    if (t == null) return 'Bad';
    final yT = t.yFreq;
    final avgY = _sampleData.map((p) => p.y).reduce((a, b) => a + b) /
        _sampleData.length;
    return avgY < yT ? 'Good' : 'Bad';
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

  // Defects
  void toggleDefect(String id) {
    if (_selectedDefectIds.contains(id))
      _selectedDefectIds.remove(id);
    else
      _selectedDefectIds.add(id);
    _isSaved = false;
    notifyListeners();
  }

  void selectAllDefects() {
    _selectedDefectIds.addAll(_defects.map((d) => d.id));
    _isSaved = false;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDefectIds.clear();
    _isSaved = false;
    notifyListeners();
  }

  void invertSelection() {
    final s = _selectedDefectIds.toSet();
    _selectedDefectIds.clear();
    for (final d in _defects) {
      if (!s.contains(d.id)) _selectedDefectIds.add(d.id);
    }
    _isSaved = false;
    notifyListeners();
  }

  // Zone
  void selectZone(String id) {
    _selectedZoneId = id;
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

  // Save
  void saveConfiguration() {
    final defect = _defects.firstWhere((d) => _selectedDefectIds.contains(d.id),
        orElse: () => _defects.first);
    final config = ConfigurationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      defectId: defect.id,
      zoneId: _selectedZoneId,
      qualityClass: classification?.qualityClass ?? '',
      outputId: recommendation?.outputName ?? '',
      preset: _selectedPreset,
      status: 'Active',
      updatedAt: DateTime.now(),
    );
    _configurations.add(config);
    defect.configured = true;
    _isSaved = true;
    notifyListeners();
  }

  void deleteConfig(String id) {
    _configurations.removeWhere((c) => c.id == id);
    notifyListeners();
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
