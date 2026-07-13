import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';
import '../theme/app_theme.dart';
import 'touch_feedback.dart';

class OutletsStep extends StatefulWidget {
  const OutletsStep({super.key});

  @override
  State<OutletsStep> createState() => _OutletsStepState();
}

class _OutletsStepState extends State<OutletsStep> {
  bool _warningDismissed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      return Container(
        color: AppTheme.mainBg,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(children: [
          if (!_warningDismissed && p.validationWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppTheme.darkGrey,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.orangeBar)),
              child: Row(children: [
                const Icon(Icons.warning_amber,
                    color: AppTheme.orangeBar, size: 22),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(p.validationWarnings.join(' · '),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFFF5A000)))),
                GestureDetector(
                    onTap: () => setState(() => _warningDismissed = true),
                    child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('✕',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFFD8D8D8))))),
              ]),
            ),
          const SizedBox(height: 12),
          Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _filters(p),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: _comboTable(p)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _outletQueues(p)),
          ])),
        ]),
      );
    });
  }

  Widget _filters(ConfiguratorProvider p) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.panelBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.darkGrey)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(Icons.filter_list, 'Filters'),
        const SizedBox(height: 12),
        SizedBox(
            height: 40,
            child: TextField(
                onChanged: (v) => p.setSearchQuery(v),
                style:
                    const TextStyle(fontSize: 15, color: AppTheme.primaryText),
                decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: AppTheme.secondaryText),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppTheme.secondaryText),
                    filled: true,
                    fillColor: AppTheme.darkGrey,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none)))),
        const SizedBox(height: 12),
        _dd(
            'Defect',
            p.filterDefect,
            p.selectedDefects.map((d) => d.id).toList(),
            (v) => p.setFilterDefect(v ?? 'all')),
        _dd('Grade', p.filterGrade, ['Good', 'Mixed', 'Bad'],
            (v) => p.setFilterGrade(v ?? 'all')),
        _dd(
            'Outlet',
            p.filterOutlet,
            ['O1', 'O2', 'O3'],
            (v) => p.setFilterOutlet(
                v == null || v == 'all' ? 'all' : v.replaceAll('O', ''))),
        _dd('Status', p.filterStatus, ['Configured', 'Pending'],
            (v) => p.setFilterStatus(v ?? 'all')),
        const Spacer(),
        TouchFeedback(
            onTap: () => p.clearAllFilters(),
            child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppTheme.darkGrey,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.darkGrey)),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.clear_all,
                          size: 18, color: AppTheme.primaryText),
                      SizedBox(width: 6),
                      Text('Clear Filters',
                          style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.primaryText,
                              fontWeight: FontWeight.w600))
                    ]))),
      ]),
    );
  }

  Widget _dd(String label, String value, List<String> items,
      Function(String?) onChange) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
          const SizedBox(height: 4),
          Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: AppTheme.darkGrey,
                  borderRadius: BorderRadius.circular(4)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 15, color: AppTheme.primaryText),
                      dropdownColor: AppTheme.darkGrey,
                      iconEnabledColor: AppTheme.primaryText,
                      items: [
                            const DropdownMenuItem(
                                value: 'all',
                                child: Text('All',
                                    style:
                                        TextStyle(color: AppTheme.primaryText)))
                          ] +
                          items
                              .map((i) =>
                                  DropdownMenuItem(value: i, child: Text(i)))
                              .toList(),
                      onChanged: onChange))),
        ]));
  }

  Widget _comboTable(ConfiguratorProvider p) {
    final defs = p.filteredCombinations;
    if (defs.isEmpty)
      return const Center(
          child: Text('No combinations',
              style: TextStyle(color: Color(0xFFD8D8D8), fontSize: 16)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _sectionTitle(Icons.table_rows, 'Combination Mapping'),
        const SizedBox(width: 12),
        Text('${defs.length} of ${p.definitions.length}',
            style: const TextStyle(
                fontSize: 15,
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w600)),
        const Spacer(),
        _btn('Auto Assign', Icons.auto_fix_high, () => p.autoAssignCombos()),
        const SizedBox(width: 6),
        _btn('Reset', Icons.restart_alt, () => p.resetCombos(), outlined: true),
        const SizedBox(width: 6),
      ]),
      const SizedBox(height: 8),
      if (p.selectedCount > 0)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF4A4A4A))),
          child: Row(children: [
            GestureDetector(
                onTap: () => p.clearBatchSelection(),
                child: const Text('✕',
                    style: TextStyle(fontSize: 14, color: Colors.white))),
            const SizedBox(width: 8),
            Text('${p.selectedCount} selected',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: () {
                  for (final dk in p.filteredCombinations) {
                    if (!p.selectedForAssign.contains(dk))
                      p.toggleSelectForAssign(dk);
                  }
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF8DAA00))),
                    child: const Text('Select All',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF8DAA00))))),
            const SizedBox(width: 8),
            const Text('Assign →',
                style: TextStyle(fontSize: 14, color: Color(0xFF8DAA00))),
            const SizedBox(width: 6),
            _assignDropdown(p),
          ]),
        ),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: AppTheme.darkGrey, borderRadius: BorderRadius.circular(4)),
          child: const Row(children: [
            SizedBox(width: 28),
            Expanded(
                flex: 4,
                child: Text('Combination',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText))),
            Expanded(
                flex: 2,
                child: Text('Outlet',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText))),
            Expanded(
                flex: 2,
                child: Text('Status',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText))),
          ])),
      const SizedBox(height: 4),
      Expanded(
        child: ListView(
          children: defs.asMap().entries.map((entry) {
            final index = entry.key;
            final dk = entry.value;
            final tokens = dk.split('|');
            final allGood = tokens.every((t) => t.endsWith('=Good'));
            final allBad = tokens.every((t) => t.endsWith('=Bad'));
            final gColor = allGood
                ? AppTheme.greenHighlight
                : allBad
                    ? AppTheme.stopRed
                    : AppTheme.orangeBar;
            final outlets = <int>[];
            if (p.isComboInOutlet(dk, 1)) outlets.add(1);
            if (p.isComboInOutlet(dk, 2)) outlets.add(2);
            if (p.isComboInOutlet(dk, 3)) outlets.add(3);
            final status = p.comboStatus(dk);
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Draggable<String>(
                data: dk,
                feedback: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: gColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(p.comboLabel(dk),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)))),
                childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _tableRow(
                        dk, tokens, gColor, outlets, status, p, index)),
                child: _tableRow(dk, tokens, gColor, outlets, status, p, index),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap,
      {bool outlined = false}) {
    return TouchFeedback(
        onTap: onTap,
        child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: outlined ? Colors.transparent : AppTheme.darkGrey,
                border: Border.all(color: AppTheme.darkGrey),
                borderRadius: BorderRadius.circular(4)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 17, color: AppTheme.primaryText),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700))
            ])));
  }

  Widget _assignDropdown(ConfiguratorProvider p) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppTheme.panelBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.greenHighlight)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
              value: null,
              hint: const Text('Outlet',
                  style:
                      TextStyle(fontSize: 15, color: AppTheme.greenHighlight)),
              dropdownColor: AppTheme.panelBg,
              iconEnabledColor: AppTheme.greenHighlight,
              style: const TextStyle(fontSize: 15, color: AppTheme.primaryText),
              items: [1, 2, 3].map((n) {
                final c = n == 1
                    ? AppTheme.greenHighlight
                    : n == 2
                        ? AppTheme.orangeBar
                        : AppTheme.stopRed;
                return DropdownMenuItem<int>(
                    value: n,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.withValues(alpha: 0.3),
                          border: Border.all(color: c, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('O$n'),
                    ]));
              }).toList(),
              onChanged: (v) {
                if (v != null) p.assignSelectedToOutlet(v);
              })),
    );
  }

  Widget _tableRow(String dk, List<String> tokens, Color gColor,
      List<int> outlets, String status, ConfiguratorProvider p, int index) {
    final sel = p.selectedForAssign.contains(dk);
    final rowBg =
        index % 2 == 0 ? const Color(0xFF26384F) : const Color(0xFF2D3E58);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: rowBg,
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: gColor, width: 3))),
      child: Row(children: [
        GestureDetector(
          onTap: () => p.toggleSelectForAssign(dk),
          child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? AppTheme.greenHighlight : Colors.transparent,
                  border: Border.all(
                      color:
                          sel ? AppTheme.greenHighlight : AppTheme.primaryText,
                      width: 2)),
              child: sel
                  ? const Icon(Icons.check,
                      size: 10, color: AppTheme.primaryText)
                  : null),
        ),
        const SizedBox(width: 8),
        Expanded(
            flex: 4,
            child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tokens.map((t) {
                  final pts = t.split('=');
                  final d = p.selectedDefects.firstWhere((x) => x.id == pts[0]);
                  final isG = pts[1] == 'Good';
                  final fill = isG ? AppTheme.goodFill : AppTheme.badFill;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: fill, borderRadius: BorderRadius.circular(4)),
                    child: Text('${d.name}: ${pts[1]}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  );
                }).toList())),
        Expanded(
            flex: 2,
            child: outlets.isEmpty
                ? const Text('—',
                    style: TextStyle(color: Color(0xFFD8D8D8), fontSize: 14))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: outlets
                        .map((o) => Container(
                            margin: const EdgeInsets.only(right: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                                color: o == 1
                                    ? AppTheme.greenHighlight
                                    : o == 2
                                        ? AppTheme.orangeBar
                                        : AppTheme.stopRed,
                                borderRadius: BorderRadius.circular(3)),
                            child: Text('O$o',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600))))
                        .toList())),
        Expanded(flex: 2, child: _statusBadge(status)),
        const SizedBox(width: 4),
        Icon(Icons.drag_indicator, size: 18, color: Colors.white38),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    final fill = status == 'Configured'
        ? AppTheme.goodFill
        : status == 'Pending'
            ? AppTheme.mixedFill
            : AppTheme.badFill;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: fill, borderRadius: BorderRadius.circular(4)),
        child: Text(status,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)));
  }

  Widget _outletQueues(ConfiguratorProvider p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(Icons.output, 'Outlets'),
      const SizedBox(height: 10),
      Expanded(
          child:
              ListView(children: [1, 2, 3].map((n) => _queue(n, p)).toList())),
    ]);
  }

  Widget _queue(int n, ConfiguratorProvider p) {
    final combos = p.combosForOutlet(n);
    final borderColor = n == 1
        ? AppTheme.greenHighlight
        : n == 2
            ? AppTheme.orangeBar
            : AppTheme.stopRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) => p.assignComboToOutlet(d.data, n),
        builder: (context, candidates, rejected) {
          final hover = candidates.isNotEmpty;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppTheme.panelBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: hover ? 2 : 1)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor)),
                    child: Center(
                        child: Text('0$n',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)))),
                const SizedBox(width: 8),
                Text('Outlet $n',
                    style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppTheme.darkGrey,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('${combos.length}',
                        style: const TextStyle(
                            color: AppTheme.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600))),
              ]),
              if (hover && combos.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                        child: Text('Drop here',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFFD8D8D8))))),
              if (combos.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...combos.map((dk) => _queueItem(dk, n, p))
              ],
            ]),
          );
        },
      ),
    );
  }

  Widget _queueItem(String dk, int n, ConfiguratorProvider p) {
    final tokens = dk.split('|');
    final borderColor = n == 1
        ? AppTheme.greenHighlight
        : n == 2
            ? AppTheme.orangeBar
            : AppTheme.badFill;
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFF243447),
                borderRadius: BorderRadius.circular(5),
                border: Border(left: BorderSide(color: borderColor, width: 2))),
            child: Row(children: [
              Expanded(
                  child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: tokens.map((t) {
                        final pts = t.split('=');
                        final d =
                            p.selectedDefects.firstWhere((x) => x.id == pts[0]);
                        final isG = pts[1] == 'Good';
                        final fill = isG ? AppTheme.goodFill : AppTheme.badFill;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              color: fill,
                              borderRadius: BorderRadius.circular(3)),
                          child: Text('${d.name}: ${pts[1]}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        );
                      }).toList())),
              GestureDetector(
                  onTap: () => p.removeComboFromOutlet(dk, n),
                  child:
                      const Icon(Icons.close, size: 16, color: Colors.white)),
            ])));
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppTheme.primaryText, size: 22),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryText)),
      ]),
      const SizedBox(height: 6),
      Container(height: 2, width: 96, color: AppTheme.greenHighlight),
    ]);
  }
}
