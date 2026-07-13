import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/program_config_provider.dart';
import '../services/api_client.dart';

class ProgramConfigStep extends StatefulWidget {
  const ProgramConfigStep({super.key});
  @override
  State<ProgramConfigStep> createState() => _ProgramConfigStepState();
}

class _ProgramConfigStepState extends State<ProgramConfigStep> {
  final _nameController = TextEditingController();

  static const _features = <_FeatureCardData>[
    _FeatureCardData('Colour', Icons.palette_outlined),
    _FeatureCardData('Size', Icons.straighten),
    _FeatureCardData('Weight', Icons.scale),
    _FeatureCardData('Feature', Icons.track_changes),
    _FeatureCardData('Spectro', Icons.insert_chart_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<ProgramConfigProvider>();
    _nameController.text = p.programName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramConfigProvider>(builder: (context, p, _) {
      final progNameValid = _nameController.text.trim().isNotEmpty;
      final produceValid = p.produceName.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: _buildLeftPanel(p, progNameValid, produceValid),
      );
    });
  }

  Widget _buildLeftPanel(
      ProgramConfigProvider p, bool progNameValid, bool produceValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        _buildSubtitle(),
        const Spacer(),
        _buildProgramDetailsCard(p, progNameValid, produceValid),
        const SizedBox(height: 70),
        _buildGradingSection(p),
        const SizedBox(height: 28),
        _buildActionToolbar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Text('Program Configuration', style: AppTheme.headingXLarge);
  }

  Widget _buildSubtitle() {
    return Text(
      'Configure the basic grading settings before defining defects.',
      style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
    );
  }

  Widget _buildProgramDetailsCard(
      ProgramConfigProvider p, bool progNameValid, bool produceValid) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardPrimary,
        borderRadius: BorderRadius.circular(12),
        border: AppTheme.defaultBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: AppTheme.hortisortGreen, size: 18),
              const SizedBox(width: 10),
              Text('Program Details',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProgramNameField(p, progNameValid)),
              const SizedBox(width: 20),
              Expanded(child: _buildProduceField(p, produceValid)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramNameField(ProgramConfigProvider p, bool valid) {
    final count = _nameController.text.length;
    final hasText = _nameController.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Program Name',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: (v) {
            if (v.length <= 20) {
              p.setProgramName(v);
              setState(() {});
            } else {
              _nameController.text = v.substring(0, 20);
              _nameController.selection = TextSelection.fromPosition(
                TextPosition(offset: _nameController.text.length),
              );
            }
          },
          maxLength: 20,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardSecondary,
            counterText: '',
            hintText: hasText ? '' : 'e.g. Premium Potato Program',
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A4658)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A4658)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppTheme.hortisortGreen, width: 1.5),
            ),
            suffix: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: hasText
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('$count/20',
                          style: TextStyle(
                              fontSize: 12,
                              color: count > 18
                                  ? AppTheme.warning
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Icon(valid ? Icons.check_circle : Icons.cancel,
                          size: 18,
                          color: valid
                              ? AppTheme.hortisortGreen
                              : AppTheme.danger),
                    ])
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          !hasText
              ? 'Name is required'
              : valid
                  ? ''
                  : 'Max 20 alphanumeric characters',
          style: TextStyle(
              fontSize: 12,
              color: valid ? AppTheme.textMuted : AppTheme.danger),
        ),
      ],
    );
  }

  Widget _buildProduceField(ProgramConfigProvider p, bool valid) {
    final produces = p.availableProduceNames;
    final hasSelection = p.produceName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produce Name',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          onSelected: (name) {
            p.setProduceName(name);
            setState(() {});
          },
          offset: const Offset(0, 60),
          color: AppTheme.cardSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppTheme.border),
          ),
          itemBuilder: (context) => produces.map((name) {
            final sel = name == p.produceName;
            return PopupMenuItem<String>(
              value: name,
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel
                                ? AppTheme.hortisortGreen
                                : AppTheme.textPrimary)),
                  ),
                  if (sel)
                    const Icon(Icons.check,
                        color: AppTheme.hortisortGreen, size: 18),
                ],
              ),
            );
          }).toList(),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: valid ? AppTheme.selectedBorder : AppTheme.defaultBorder,
              color: AppTheme.cardSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection ? p.produceName : 'Select produce...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hasSelection
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
                if (hasSelection)
                  GestureDetector(
                    onTap: () {
                      p.setProduceName('');
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.close,
                          color: AppTheme.textMuted, size: 18),
                    ),
                  ),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary, size: 22),
              ],
            ),
          ),
        ),
        if (produces.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('No produce data loaded',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ),
        if (!hasSelection && produces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Select a produce',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ),
      ],
    );
  }

  Widget _buildGradingSection(ProgramConfigProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grading Based On',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _features.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
              child: _buildChip(f, p),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(_FeatureCardData f, ProgramConfigProvider p) {
    final selected =
        p.gradingBasedOn == 'Defect Feature' && f.name == 'Feature' ||
            p.gradingBasedOn == f.name;
    return GestureDetector(
      onTap: () {
        p.setGradingBasedOn(f.name == 'Feature' ? 'Defect Feature' : f.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 68,
        decoration: BoxDecoration(
          color: selected ? AppTheme.hortisortGreen : AppTheme.cardSecondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(f.icon,
                size: 20,
                color: selected ? const Color(0xFF0F1115) : AppTheme.textMuted),
            const SizedBox(height: 6),
            Text(f.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF0F1115)
                        : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.cardPrimary,
        borderRadius: BorderRadius.circular(10),
        border: AppTheme.defaultBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _toolbarBtn(Icons.add_circle_outline, 'New', () => _onNew()),
          const SizedBox(width: 4),
          _toolbarBtn(Icons.edit_outlined, 'Edit', () => _onEdit()),
          const SizedBox(width: 4),
          _toolbarBtn(Icons.save_outlined, 'Save', () => _onSave()),
          const SizedBox(width: 4),
          _toolbarBtn(Icons.delete_outlined, 'Delete', () => _onDelete()),
          const SizedBox(width: 4),
          _toolbarBtn(Icons.clear_all_outlined, 'Clear', () => _resetForm()),
        ],
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(icon, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.cardSecondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _resetForm() {
    final p = context.read<ProgramConfigProvider>();
    p.reset();
    _nameController.clear();
    setState(() {});
    _showSnackbar('Form cleared');
  }

  Future<bool> _confirm(String title, String msg) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSecondary,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        content:
            Text(msg, style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm',
                style: TextStyle(color: AppTheme.hortisortGreen)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onNew() async {
    _resetForm();
  }

  Future<void> _onEdit() async {
    final p = context.read<ProgramConfigProvider>();

    List<Map<String, dynamic>> programs;
    try {
      programs = await ApiClient.fetchProgramSummaries();
    } catch (_) {
      await p.loadExistingPrograms();
      programs = p.savedProgramNames
          .map((name) => <String, dynamic>{
                'name': name,
                'produceName': '',
                'gradingBasedOn': ''
              })
          .toList();
    }

    if (programs.isEmpty) {
      _showSnackbar('No saved programs');
      return;
    }
    if (!mounted) return;

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSecondary,
        title: const Text('Load Program',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTableHeader(),
              Divider(height: 1, color: AppTheme.border),
              programs.length > 8
                  ? Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: programs.length,
                        itemBuilder: (_, i) => _buildTableRow(programs[i], ctx),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: programs
                          .map((pr) => _buildTableRow(pr, ctx))
                          .toList(),
                    ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    final data = await p.loadProgram(selected);
    if (data == null || !mounted) {
      if (mounted) _showSnackbar('Failed to load program');
      return;
    }

    p.setProgramName(data['ProgramName'] as String? ?? '');
    p.setProduceName(data['ProduceName'] as String? ?? '');
    p.setGradingBasedOn(data['GradingBasedOn'] as String? ?? 'Defect Feature');
    _nameController.text = data['ProgramName'] as String? ?? '';
    setState(() {});
    _showSnackbar('Loaded: $selected');
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('Program Name',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.hortisortGreen))),
          Expanded(
              flex: 2,
              child: Text('Grading Based On',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.hortisortGreen))),
          Expanded(
              flex: 2,
              child: Text('Produce Name',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.hortisortGreen))),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> pr, BuildContext ctx) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, pr['name'] as String),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Text(pr['name'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500))),
            Expanded(
                flex: 2,
                child: Text(pr['gradingBasedOn'] as String? ?? '—',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary))),
            Expanded(
                flex: 2,
                child: Text(pr['produceName'] as String? ?? '—',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary))),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final p = context.read<ProgramConfigProvider>();
    final name = p.programName.trim();
    final produce = p.produceName.trim();

    if (name.isEmpty || produce.isEmpty) {
      _showSnackbar('Fill all required fields');
      return;
    }

    await p.loadExistingPrograms();
    if (p.isDuplicateName) {
      final proceed = await _confirm(
        'Overwrite?',
        'Program "$name" already exists. Overwrite?',
      );
      if (!proceed || !mounted) return;
    }

    await p.saveProgram();
    if (mounted) _showSnackbar('Program saved');
  }

  Future<void> _onDelete() async {
    final p = context.read<ProgramConfigProvider>();
    final name = p.programName.trim();

    if (name.isEmpty) {
      _showSnackbar('No program to delete');
      return;
    }

    final proceed = await _confirm(
      'Delete Program',
      'Delete "$name"? This cannot be undone.',
    );
    if (!proceed || !mounted) return;

    await p.deleteProgram(name);
    if (mounted) {
      _resetForm();
      _showSnackbar('Deleted: $name');
    }
  }
}

class _FeatureCardData {
  final String name;
  final IconData icon;
  const _FeatureCardData(this.name, this.icon);
}
