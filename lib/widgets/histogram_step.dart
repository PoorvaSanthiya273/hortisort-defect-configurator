import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';

class HistogramStep extends StatefulWidget {
  const HistogramStep({super.key});

  @override
  State<HistogramStep> createState() => _HistogramStepState();
}

class _HistogramStepState extends State<HistogramStep> {
  String? _selectedDefectKey;
  bool _saved = false;

  String _fmt(double v) =>
      v == v.toInt() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      final defectIds = p.selectedDefectIds.toList()..sort();

      if (_selectedDefectKey == null && defectIds.isNotEmpty) {
        _selectedDefectKey = defectIds.first;
        p.setCurrentDefinition(_selectedDefectKey!);
      }

      if (_selectedDefectKey != null) {
        p.initDefectFrequencies(_selectedDefectKey!);
      }

      final currentKey = _selectedDefectKey;
      final bandLabels = p.bandLabels;
      final noOfBands = p.histogramNoOfBands;
      final maxFreq =
          currentKey != null ? p.getDefectMaxFrequency(currentKey) : 100.0;

      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (defectIds.isNotEmpty)
            Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Defects',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF))),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: defectIds.length,
                      itemBuilder: (context, index) {
                        final id = defectIds[index];
                        final defectName =
                            p.defects.firstWhere((d) => d.id == id).name;
                        final isSelected = id == currentKey;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDefectKey = id);
                            p.setCurrentDefinition(id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A4A4A)
                                  : const Color(0xFF26384F),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8DAA00)
                                    : const Color(0xFF4A4A4A),
                              ),
                            ),
                            child: Row(children: [
                              Container(
                                width: 6,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF8DAA00)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(defectName,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF8DAA00)
                                            : const Color(0xFFFFFFFF))),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Main histogram area
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header with title and save
              Row(children: [
                Text(
                  currentKey != null
                      ? 'Histogram: ${p.defects.firstWhere((d) => d.id == currentKey).name}'
                      : 'Histogram',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF)),
                ),
                const Spacer(),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await p.saveHistogramConfig();
                    setState(() => _saved = true);
                    Future.delayed(const Duration(seconds: 2),
                        () => setState(() => _saved = false));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _saved
                          ? const Color(0xFF8DAA00).withValues(alpha: 0.2)
                          : const Color(0xFF4A4A4A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_saved ? Icons.check_circle : Icons.save,
                            size: 14,
                            color: _saved
                                ? const Color(0xFF8DAA00)
                                : const Color(0xFFFFFFFF)),
                        const SizedBox(width: 4),
                        Text(_saved ? 'Saved!' : 'Save',
                            style: TextStyle(
                                fontSize: 14,
                                color: _saved
                                    ? const Color(0xFF8DAA00)
                                    : const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),

              // Config info chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _infoChip('Min', _fmt(p.histogramMin)),
                  _infoChip('Max', _fmt(p.histogramMax)),
                  _infoChip('Bands', p.histogramNoOfBands.toString()),
                  _infoChip('Band Size', _fmt(p.bandSize)),
                ],
              ),
              const SizedBox(height: 12),

              // Histogram card
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF26384F),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4A4A4A)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const RotatedBox(
                          quarterTurns: 3,
                          child: Text('Frequency',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF))),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(5, (i) {
                              if (i == 0) return const SizedBox();
                              final v = ((maxFreq > 0 ? maxFreq : 100) ~/ 5) *
                                  (5 - i);
                              return Center(
                                  child: Text('$v',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFD8D8D8))));
                            }),
                          ),
                        ),
                        Expanded(
                          child: currentKey != null
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    return CustomPaint(
                                      size: Size(constraints.maxWidth,
                                          constraints.maxHeight),
                                      painter: _GridPainter(maxFreq: maxFreq),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children:
                                            List.generate(noOfBands, (index) {
                                          return Expanded(
                                            child: _DraggableBar(
                                              index: index,
                                              frequency: p.getBandFrequency(
                                                  currentKey, index),
                                              maxFrequency: maxFreq,
                                              maxBarHeight:
                                                  constraints.maxHeight,
                                              label: bandLabels[index],
                                              onFrequencyChanged: (value) {
                                                p.setBandFrequency(
                                                    currentKey, index, value);
                                              },
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text('Select a defect to configure',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFD8D8D8))),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text('Bands',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF))),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: currentKey != null
                        ? () => p.resetDefectFrequencies(currentKey)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF4A4A4A)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh,
                              size: 14, color: Color(0xFFFFFFFF)),
                          SizedBox(width: 4),
                          Text('Reset',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF4A4A4A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFD8D8D8),
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DraggableBar extends StatefulWidget {
  final int index;
  final double frequency;
  final double maxFrequency;
  final double maxBarHeight;
  final String label;
  final Function(double) onFrequencyChanged;

  const _DraggableBar({
    required this.index,
    required this.frequency,
    required this.maxFrequency,
    required this.maxBarHeight,
    required this.label,
    required this.onFrequencyChanged,
  });

  @override
  State<_DraggableBar> createState() => _DraggableBarState();
}

class _DraggableBarState extends State<_DraggableBar> {
  double _currentFrequency = 0;
  bool _isDragging = false;
  bool _isEditing = false;
  final _editController = TextEditingController();
  final _focusNode = FocusNode();

  String _formatNum(double value) {
    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _currentFrequency = widget.frequency;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commitEdit();
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DraggableBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frequency != widget.frequency) {
      _currentFrequency = widget.frequency;
    }
  }

  void _startEditing() {
    _editController.text = _formatNum(_currentFrequency);
    setState(() => _isEditing = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _commitEdit() {
    final v = double.tryParse(_editController.text);
    if (v != null && v >= 0) {
      final rounded = v.roundToDouble();
      setState(() {
        _currentFrequency = rounded;
        _isEditing = false;
      });
      widget.onFrequencyChanged(rounded);
    } else {
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = (widget.maxBarHeight - 60).clamp(0, widget.maxBarHeight);
    final barHeight = widget.maxFrequency > 0
        ? (_currentFrequency / widget.maxFrequency) * available
        : 0.0;
    final borderColor = const Color(0xFF8DAA00);
    final barBg = _isDragging
        ? const Color(0xFF8DAA00).withValues(alpha: 0.3)
        : const Color(0xFFFFFFFF);

    return GestureDetector(
      onVerticalDragStart: (_) => setState(() => _isDragging = true),
      onVerticalDragUpdate: (details) {
        final delta = -details.primaryDelta! * 0.5;
        final newValue = _currentFrequency + delta;
        setState(() {
          _currentFrequency = newValue < 0 ? 0 : newValue.roundToDouble();
        });
        widget.onFrequencyChanged(_currentFrequency);
      },
      onVerticalDragEnd: (_) {
        _currentFrequency = _currentFrequency.roundToDouble();
        setState(() => _isDragging = false);
        widget.onFrequencyChanged(_currentFrequency);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _isEditing
              ? SizedBox(
                  width: 54,
                  height: 24,
                  child: TextField(
                    controller: _editController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF)),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8DAA00))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8DAA00))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8DAA00))),
                    ),
                    onSubmitted: (_) => _commitEdit(),
                  ),
                )
              : GestureDetector(
                  onTap: _startEditing,
                  child: Text(
                    _formatNum(_currentFrequency),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
          const Icon(Icons.arrow_upward, size: 14, color: Color(0xFF8DAA00)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: barHeight.clamp(2, double.infinity).toDouble(),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: barBg,
              border: Border.all(color: borderColor, width: 2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD8D8D8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double maxFreq;

  _GridPainter({required this.maxFreq});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      final y = size.height - (i * size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final axisPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.maxFreq != maxFreq;
  }
}
