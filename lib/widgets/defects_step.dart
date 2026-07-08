import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';
import 'defect_image.dart';
import 'touch_feedback.dart';

class DefectsStep extends StatelessWidget {
  const DefectsStep({super.key});

  static const _categories = [
    'All',
    'Color Defect',
    'Surface Defect',
    'Decay / Damage',
    'Shape Defect',
    'Foreign Material'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 220,
              margin: const EdgeInsets.only(right: 8),
              child: p.filterExpanded ? _filterPanel(p) : _filterToggle(p)),
          Expanded(child: _mainContent(p)),
        ]),
      );
    });
  }

  Widget _filterToggle(ConfiguratorProvider p) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: TouchFeedback(
        onTap: () => p.toggleFilterPanel(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF26384F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF4A4A4A))),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.filter_list, size: 20, color: Color(0xFFD8D8D8)),
            SizedBox(height: 4),
            Text('Filters',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD8D8D8),
                    fontWeight: FontWeight.w600))
          ]),
        ),
      ),
    );
  }

  Widget _filterPanel(ConfiguratorProvider p) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF26384F),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF4A4A4A))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Icon(Icons.filter_list, size: 16, color: Color(0xFFD8D8D8)),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('Filters',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF)))),
              TouchFeedback(
                  borderRadius: 6,
                  onTap: () => p.toggleFilterPanel(),
                  child: Container(
                      width: 28,
                      height: 28,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          color: const Color(0xFF4A4A4A),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.close,
                          size: 14, color: Color(0xFFD8D8D8)))),
            ]),
            const SizedBox(height: 16),
            SizedBox(
                height: 36,
                child: TextField(
                    onChanged: (v) => p.setSearchQuery(v),
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFFFFFFFF)),
                    decoration: InputDecoration(
                        hintText: 'Search Defects',
                        hintStyle: const TextStyle(color: Color(0xFFD8D8D8)),
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: Color(0xFFD8D8D8)),
                        filled: true,
                        fillColor: const Color(0xFF4A4A4A),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none)))),
            const SizedBox(height: 12),
            _dd('Defect Type', p.activeCategory ?? 'All', _categories,
                (v) => p.setCategoryFilter(v == 'All' ? null : v)),
            _dd('Status', p.statusFilter, ['All', 'Selected', 'Not Selected'],
                (v) => p.setStatusFilter(v ?? 'All')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  p.setSearchQuery('');
                  p.setCategoryFilter(null);
                  p.setStatusFilter('All');
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4A4A),
                  foregroundColor: const Color(0xFFD8D8D8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_all, size: 16, color: Color(0xFFD8D8D8)),
                    SizedBox(width: 6),
                    Text('Clear All Filters',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Divider(color: Color(0xFF4A4A4A)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(6)),
              child: Column(children: [
                Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4A4A4A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xFF8DAA00))),
                      child: Center(
                          child: Text('${p.selectedDefectCount}',
                              style: const TextStyle(
                                  color: Color(0xFF8DAA00),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 10),
                  const Text('Defect Selected',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD8D8D8),
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4A4A4A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xFF8DAA00))),
                      child: Center(
                          child: Text('${p.definitions.length}',
                              style: const TextStyle(
                                  color: Color(0xFF8DAA00),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text('Combos will be created',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD8D8D8),
                              fontWeight: FontWeight.w500))),
                ]),
              ]),
            ),
          ]),
    );
  }

  Widget _dd(String label, String value, List<String> items,
      Function(String?) onChange) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.isNotEmpty)
            Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFFD8D8D8))),
          if (label.isNotEmpty) const SizedBox(height: 4),
          Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(6)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF26384F),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFFFFFFF)),
                      items: items
                          .map(
                              (i) => DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      onChanged: onChange))),
        ]));
  }

  Widget _mainContent(ConfiguratorProvider p) {
    final filtered = p.filteredDefects;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Select Defects',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF))),
          SizedBox(height: 4),
          Text(
              'Choose one or more defects to configure histograms and thresholds',
              style: TextStyle(fontSize: 13, color: Color(0xFFD8D8D8))),
        ]),
        const Spacer(),
        _viewToggle(p),
        const SizedBox(width: 12),
        _chip('Select All', () => p.selectAllDefects()),
        const SizedBox(width: 8),
        _chip('Clear', () => p.clearSelection()),
      ]),
      const SizedBox(height: 12),
      // Zone selector
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF26384F),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF4A4A4A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Zones / Inspection Areas',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF))),
            const Spacer(),
            TouchFeedback(
                onTap: () => p.selectedZoneIds.length == p.zones.length
                    ? p.zones.forEach((z) => p.toggleZone(z.id))
                    : p.zones
                        .where((z) => !p.selectedZoneIds.contains(z.id))
                        .forEach((z) => p.toggleZone(z.id)),
                child: const Text('Select All',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8DAA00),
                        fontWeight: FontWeight.w600))),
            const SizedBox(width: 10),
            TouchFeedback(
                onTap: () =>
                    p.selectedZoneIds.toList().forEach((z) => p.toggleZone(z)),
                child: const Text('Clear All',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD8D8D8),
                        fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.zones.map((z) {
                final sel = p.selectedZoneIds.contains(z.id);
                return TouchFeedback(
                  onTap: () => p.toggleZone(z.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF4A4A4A)
                            : const Color(0xFF26384F),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: sel
                                ? const Color(0xFF8DAA00)
                                : const Color(0xFF4A4A4A))),
                    child: Text(z.name,
                        style: TextStyle(
                            fontSize: 13,
                            color: sel
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFFD8D8D8),
                            fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList()),
        ]),
      ),
      const SizedBox(height: 14),
      Expanded(
        child: filtered.isEmpty
            ? const Center(
                child: Text('No defects match',
                    style: TextStyle(color: Color(0xFFD8D8D8), fontSize: 14)))
            : p.viewMode == 'list'
                ? ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _DefectListTile(defectId: filtered[index].id))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: filtered
                            .map((d) => SizedBox(
                                width: 155,
                                height: 185,
                                child: _DefectCard(
                                    key: ValueKey(d.id), defectId: d.id)))
                            .toList()),
                  ),
      ),
    ]);
  }

  Widget _chip(String label, VoidCallback onTap) {
    return TouchFeedback(
        onTap: onTap,
        borderRadius: 4,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF4A4A4A))),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8DAA00),
                    fontWeight: FontWeight.w500))));
  }

  Widget _viewToggle(ConfiguratorProvider p) {
    final isGrid = p.viewMode == 'grid';
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF26384F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4A4A4A)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _toggleBtn(Icons.grid_view, isGrid, () => p.setViewMode('grid')),
        _toggleBtn(Icons.view_list, !isGrid, () => p.setViewMode('list')),
      ]),
    );
  }

  Widget _toggleBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 36,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4A4A4A) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? const Color(0xFF8DAA00) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(icon,
            size: 18,
            color: active ? const Color(0xFFFFFFFF) : const Color(0xFFD8D8D8)),
      ),
    );
  }
}

class _DefectCard extends StatefulWidget {
  final String defectId;
  const _DefectCard({super.key, required this.defectId});

  @override
  State<_DefectCard> createState() => _DefectCardState();
}

class _DefectCardState extends State<_DefectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      final d = p.defects.firstWhere((x) => x.id == widget.defectId);
      final sel = p.selectedDefectIds.contains(d.id);
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: TouchFeedback(
          onTap: () => p.toggleDefect(d.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: const Color(0xFF26384F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: sel
                      ? const Color(0xFF8DAA00)
                      : _hovered
                          ? const Color(0xFF8DAA00).withValues(alpha: 0.3)
                          : const Color(0xFF4A4A4A),
                  width: sel ? 2 : 1),
              boxShadow: sel
                  ? [
                      const BoxShadow(
                          color: Color(0x338DAA00),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ]
                  : null,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(5)),
                      child: Stack(fit: StackFit.expand, children: [
                        Container(color: const Color(0xFF4A4A4A)),
                        DefectImage(defectId: d.id, size: 300),
                        if (sel)
                          Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF8DAA00)),
                                  child: const Icon(Icons.check,
                                      size: 14, color: Colors.white))),
                      ]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d.name,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? const Color(0xFF8DAA00)
                                        : const Color(0xFFFFFFFF)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(d.category,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFFD8D8D8))),
                          ]),
                    ),
                  ),
                ]),
          ),
        ),
      );
    });
  }
}

class _DefectListTile extends StatelessWidget {
  final String defectId;
  const _DefectListTile({super.key, required this.defectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      final d = p.defects.firstWhere((x) => x.id == defectId);
      final sel = p.selectedDefectIds.contains(d.id);
      return GestureDetector(
        onTap: () => p.toggleDefect(d.id),
        child: Container(
          height: 68,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF26384F),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: sel ? const Color(0xFF8DAA00) : const Color(0xFF4A4A4A),
              width: sel ? 2 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: DefectImage(defectId: d.id, size: 80),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: sel
                              ? const Color(0xFF8DAA00)
                              : const Color(0xFFFFFFFF))),
                  const SizedBox(height: 2),
                  Text(d.category,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFD8D8D8))),
                ],
              ),
            ),
            if (sel)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8DAA00),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ]),
        ),
      );
    });
  }
}
