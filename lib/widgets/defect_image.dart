import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'defect_image_gen.dart';

class DefectImage extends StatelessWidget {
  final String defectId;
  final double size;

  const DefectImage({super.key, required this.defectId, this.size = 160});

  static final Map<String, String> _assetMap = {
    'D01': 'assets/defects/D01_green.png',
    'D02': 'assets/defects/D02_cracks.png',
    'D03': 'assets/defects/D03_stones.png',
    'D04': 'assets/defects/D04_rhizo.png',
    'D05': 'assets/defects/D05_aging.png',
    'D06': 'assets/defects/D06_rotten.png',
    'D07': 'assets/defects/D07_freshcut.png',
    'D08': 'assets/defects/D08_blackspot.png',
    'D09': 'assets/defects/D09_scab.png',
    'D10': 'assets/defects/D10_misshape.png',
    'D11': 'assets/defects/D11_leafgrass.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assetMap[defectId];
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return _GeneratedDefectImage(defectId: defectId, size: size);
  }
}

class _GeneratedDefectImage extends StatefulWidget {
  final String defectId;
  final double size;
  const _GeneratedDefectImage({required this.defectId, required this.size});

  @override
  State<_GeneratedDefectImage> createState() => _GeneratedDefectImageState();
}

class _GeneratedDefectImageState extends State<_GeneratedDefectImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final img = await DefectImageGen.get(widget.defectId);
    if (mounted) setState(() => _image = img);
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return Container(
          width: widget.size,
          height: widget.size,
          color: const Color(0xFFF5E6CA));
    }
    return RawImage(
        image: _image!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain);
  }
}
