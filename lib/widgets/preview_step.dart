import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configurator_provider.dart';
import '../providers/program_config_provider.dart';
import '../services/file_service.dart';

class PreviewStep extends StatefulWidget {
  const PreviewStep({super.key});
  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  final Set<int> _expanded = {1, 2, 3};
  bool _warningDismissed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguratorProvider>(builder: (context, p, _) {
      final defs = p.definitions;
      final unassigned = defs.where((dk) => !p.isComboAssigned(dk)).toList();
      final warnings = p.validationWarnings;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review & Save',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text(
                      'Review all definitions before finalizing your configuration',
                      style: TextStyle(fontSize: 16, color: Color(0xFFD8D8D8))),
                ]),
            const Spacer(),
            _btn('Export JSON', Icons.file_download, () async {
              final pp =
                  Provider.of<ProgramConfigProvider>(context, listen: false);
              p.setProgramName(pp.programName);
              p.setProduceName(pp.produceName);
              final json = p.exportJSON();
              final name =
                  pp.programName.isNotEmpty ? pp.programName : 'Untitled';
              await saveProgramFile(name, json);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF8DAA00), size: 18),
                      SizedBox(width: 8),
                      Text('JSON exported!',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ]),
                    backgroundColor: Color(0xFF26384F),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                  ),
                );
              }
            }, const Color(0xFF4A4A4A)),
            const SizedBox(width: 8),
            _btn('Save Config', Icons.save, () {
              p.saveConfiguration();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF8DAA00), size: 18),
                    SizedBox(width: 8),
                    Text('Configuration saved!',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ]),
                  backgroundColor: Color(0xFF26384F),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(10),
                ),
              );
            }, const Color(0xFF4A4A4A)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _stat('Total', Icons.assignment, defs.length.toString(),
                const Color(0xFF42A5F5)),
            _stat('Good', Icons.check_circle, p.goodCount.toString(),
                const Color(0xFF8DAA00)),
            _stat('Slightly Bad', Icons.warning_amber, p.sbCount.toString(),
                const Color(0xFFF5A000)),
            _stat('Bad', Icons.cancel, p.badCount.toString(),
                const Color(0xFF6B1605)),
            _stat('Unassigned', Icons.help, unassigned.length.toString(),
                const Color(0xFF9C27B0)),
          ]),
          if (!_warningDismissed && warnings.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
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
                    child: Text(warnings.join(' · '),
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
          ],
          const SizedBox(height: 14),
          Expanded(
            child: ListView(children: [
              _outletTile(1, p),
              _outletTile(2, p),
              _outletTile(3, p),
              if (unassigned.isNotEmpty) _unassignedTile(unassigned, p),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _outletTile(int n, ConfiguratorProvider p) {
    final combos = p.combosForOutlet(n);
    final borderColor = n == 1
        ? const Color(0xFF8DAA00)
        : n == 2
            ? const Color(0xFFF5A000)
            : const Color(0xFF6B1605);
    final expanded = _expanded.contains(n);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFF26384F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() {
            if (expanded)
              _expanded.remove(n);
            else
              _expanded.add(n);
          }),
          child: Row(children: [
            Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: Text('0$n',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)))),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Outlet $n',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white, size: 22),
          ]),
        ),
        if (expanded && combos.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...combos.map((dk) => _defRow(dk, p))
        ],
        if (expanded && combos.isEmpty)
          const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('No items assigned',
                  style: TextStyle(fontSize: 14, color: Color(0xFFD8D8D8)))),
      ]),
    );
  }

  Widget _unassignedTile(List<String> combos, ConfiguratorProvider p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFF26384F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF5A000))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(5)),
              child: const Center(
                  child: Text('⚠',
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFFF5A000))))),
          const SizedBox(width: 8),
          Expanded(
              child: Text('Unassigned — ${combos.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 8),
        ...combos.map((dk) => _defRow(dk, p)),
      ]),
    );
  }

  Widget _defRow(String dk, ConfiguratorProvider p) {
    final tokens = dk.split('|');
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(5),
            border: Border(
                left: BorderSide(color: const Color(0xFF8DAA00), width: 2))),
        child: Row(children: [
          Expanded(
              child: Text(p.comboLabel(dk),
                  style: const TextStyle(fontSize: 16, color: Colors.white))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(tokens.length.toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8DAA00)))),
        ]),
      ),
    );
  }

  Widget _stat(String label, IconData icon, String value, Color c) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4A4A4A))),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withValues(alpha: 0.15),
                ),
                child: Icon(icon, size: 18, color: c),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(value,
                          style: TextStyle(
                              color: c,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ]),
              ),
            ])));
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap, Color c) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.zero),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ])));
  }
}
