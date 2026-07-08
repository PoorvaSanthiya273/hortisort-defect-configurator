import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';

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
      if (p.assignedGradeCount < p.definitions.length &&
          p.definitions.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => p.autoAssignGrades());
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(children: [
          if (!_warningDismissed && p.validationWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF5A000))),
              child: Row(children: [
                const Icon(Icons.warning_amber,
                    color: Color(0xFFF5A000), size: 18),
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
          _summaryStats(p),
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

  Widget _summaryStats(ConfiguratorProvider p) {
    return Row(children: [
      _statCard(
          'Total', p.totalCombinations.toString(), const Color(0xFFFFFFFF)),
      _statCard('Good', p.goodCount.toString(), const Color(0xFF8DAA00)),
      _statCard('Slightly Bad', p.sbCount.toString(), const Color(0xFFF5A000)),
      _statCard('Bad', p.badCount.toString(), const Color(0xFF6B1605)),
      _statCard(
          'Configured', p.configuredCount.toString(), const Color(0xFF8DAA00)),
      _statCard('Pending', p.pendingCount.toString(), const Color(0xFFF5A000)),
    ]);
  }

  Widget _statCard(String label, String value, Color c) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4A4A4A))),
            child: Column(children: [
              Text(value,
                  style: TextStyle(
                      color: c, fontSize: 22, fontWeight: FontWeight.w700)),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14))
            ])));
  }

  Widget _filters(ConfiguratorProvider p) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF26384F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF26384F))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Filters',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
            height: 36,
            child: TextField(
                onChanged: (v) => p.setSearchQuery(v),
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Color(0xFFD8D8D8)),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Color(0xFFD8D8D8)),
                    filled: true,
                    fillColor: const Color(0xFF4A4A4A),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none)))),
        const SizedBox(height: 10),
        _dd('Defect', p.filterDefect, p.defects.map((d) => d.id).toList(),
            (v) => p.setFilterDefect(v ?? 'all')),
        _dd('Zone', p.filterZone, p.zones.map((z) => z.id).toList(),
            (v) => p.setFilterZone(v ?? 'all')),
        _dd('Grade', p.filterGrade, ['Good', 'Slightly Bad', 'Bad'],
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
        GestureDetector(
            onTap: () => p.clearAllFilters(),
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF4A4A4A))),
                child: const Text('Clear Filters',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)))),
      ]),
    );
  }

  Widget _dd(String label, String value, List<String> items,
      Function(String?) onChange) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFFD8D8D8))),
          const SizedBox(height: 2),
          Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(6)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      dropdownColor: const Color(0xFF4A4A4A),
                      items: [
                            const DropdownMenuItem(
                                value: 'all',
                                child: Text('All',
                                    style: TextStyle(color: Colors.white)))
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
        Text('${defs.length} of ${p.definitions.length} combinations',
            style: const TextStyle(fontSize: 16, color: Colors.white)),
        const Spacer(),
        _btn('Auto Assign', () {
          p.autoAssignGrades();
          p.autoAssignCombos();
        }),
        const SizedBox(width: 6),
        _btn('Reset', () {
          p.resetGrades();
          p.resetCombos();
        }, outlined: true),
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
              color: const Color(0xFF26384F),
              borderRadius: BorderRadius.circular(6)),
          child: const Row(children: [
            SizedBox(width: 28),
            Expanded(
                flex: 3,
                child: Text('Defect',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8D8D8)))),
            Expanded(
                flex: 1,
                child: Text('Zone',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8D8D8)))),
            Expanded(
                flex: 2,
                child: Text('Grade',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8D8D8)))),
            Expanded(
                flex: 2,
                child: Text('Outlet',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8D8D8)))),
            Expanded(
                flex: 2,
                child: Text('Status',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8D8D8)))),
          ])),
      const SizedBox(height: 4),
      Expanded(
        child: ListView(
          children: defs.asMap().entries.map((entry) {
            final index = entry.key;
            final dk = entry.value;
            final parts = dk.split('-');
            final d = p.defects.firstWhere((x) => x.id == parts[0]);
            final z = p.zones.firstWhere((x) => x.id == parts[1]);
            final grade = p.gradeFor(dk);
            final gColor = grade == 'Good'
                ? const Color(0xFF8DAA00)
                : grade == 'Slightly Bad'
                    ? const Color(0xFFF5A000)
                    : const Color(0xFF6B1605);
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
                        child: Text('${d.name} @ ${z.name}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)))),
                childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _tableRow(
                        dk, d, z, grade, gColor, outlets, status, p, index)),
                child: _tableRow(
                    dk, d, z, grade, gColor, outlets, status, p, index),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _btn(String label, VoidCallback onTap, {bool outlined = false}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: outlined ? Colors.transparent : const Color(0xFF4A4A4A),
                border: outlined
                    ? Border.all(color: const Color(0xFF4A4A4A))
                    : null,
                borderRadius: BorderRadius.zero),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600))));
  }

  Widget _assignDropdown(ConfiguratorProvider p) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF26384F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF8DAA00))),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
              value: null,
              hint: const Text('Outlet',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8DAA00))),
              dropdownColor: const Color(0xFF26384F),
              style: const TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
              items: [1, 2, 3].map((n) {
                final c = n == 1
                    ? const Color(0xFF8DAA00)
                    : n == 2
                        ? const Color(0xFFF5A000)
                        : const Color(0xFF6B1605);
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

  Widget _tableRow(String dk, d, z, String? grade, Color gColor,
      List<int> outlets, String status, ConfiguratorProvider p, int index) {
    final sel = p.selectedForAssign.contains(dk);
    final rowBg =
        index % 2 == 0 ? const Color(0xFF26384F) : const Color(0xFF2D3E58);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: rowBg,
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: gColor, width: 3))),
      child: Row(children: [
        GestureDetector(
          onTap: () => p.toggleSelectForAssign(dk),
          child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? const Color(0xFF8DAA00) : Colors.transparent,
                  border: Border.all(
                      color: sel ? const Color(0xFF8DAA00) : Colors.white,
                      width: 2)),
              child: sel
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null),
        ),
        const SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Text(d.name,
                style: const TextStyle(fontSize: 16, color: Colors.white))),
        Expanded(
            flex: 1,
            child: Text(z.name,
                style:
                    const TextStyle(fontSize: 16, color: Color(0xFFD8D8D8)))),
        Expanded(
            flex: 2,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(grade ?? '--',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: gColor)))),
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
                                color: const Color(0xFF4A4A4A),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text('O$o',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: o == 1
                                        ? const Color(0xFF8DAA00)
                                        : o == 2
                                            ? const Color(0xFFF5A000)
                                            : const Color(0xFF6B1605),
                                    fontWeight: FontWeight.w600))))
                        .toList())),
        Expanded(flex: 2, child: _statusBadge(status)),
        const SizedBox(width: 4),
        Icon(Icons.drag_indicator, size: 18, color: Colors.white38),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color c = status == 'Configured'
        ? const Color(0xFF8DAA00)
        : status == 'Pending'
            ? const Color(0xFFF5A000)
            : const Color(0xFF6B1605);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(4)),
        child: Text(status,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: c)));
  }

  Widget _outletQueues(ConfiguratorProvider p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Outlet Queues',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 8),
      Expanded(
          child:
              ListView(children: [1, 2, 3].map((n) => _queue(n, p)).toList())),
    ]);
  }

  Widget _queue(int n, ConfiguratorProvider p) {
    final combos = p.combosForOutlet(n);
    final borderColor = n == 1
        ? const Color(0xFF8DAA00)
        : n == 2
            ? const Color(0xFFF5A000)
            : const Color(0xFF6B1605);
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
                color: const Color(0xFF26384F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: hover ? 2 : 1)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                        child: Text('0$n',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)))),
                const SizedBox(width: 8),
                Text('Outlet $n',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('${combos.length}',
                        style: const TextStyle(
                            color: Colors.white,
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
    final parts = dk.split('-');
    final d = p.defects.firstWhere((x) => x.id == parts[0]);
    final z = p.zones.firstWhere((x) => x.id == parts[1]);
    final borderColor = n == 1
        ? const Color(0xFF8DAA00)
        : n == 2
            ? const Color(0xFFF5A000)
            : const Color(0xFF6B1605);
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(5),
                border: Border(left: BorderSide(color: borderColor, width: 2))),
            child: Row(children: [
              Expanded(
                  child: Text('${d.name} @ ${z.name}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white))),
              GestureDetector(
                  onTap: () => p.removeComboFromOutlet(dk, n),
                  child:
                      const Icon(Icons.close, size: 16, color: Colors.white)),
            ])));
  }
}
