import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'defect_image_gen.dart';

class DefectImage extends StatelessWidget {
  final String defectId;
  final double size;

  const DefectImage({super.key, required this.defectId, this.size = 160});

  static const Map<String, String> _imageUrls = {
    'D01': '/api/images/defects/D01_green.png',
    'D02': '/api/images/defects/D02_cracks.png',
    'D03': '/api/images/defects/D03_stones.png',
    'D04': '/api/images/defects/D04_rhizo.png',
    'D05': '/api/images/defects/D05_aging.png',
    'D06': '/api/images/defects/D06_rotten.png',
    'D07': '/api/images/defects/D07_freshcut.png',
    'D08': '/api/images/defects/D08_blackspot.png',
    'D09': '/api/images/defects/D09_scab.png',
    'D10': '/api/images/defects/D10_misshape.png',
    'D11': '/api/images/defects/D11_leafgrass.png',
  };

  @override
  Widget build(BuildContext context) {
    final url = _imageUrls[defectId];
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.network(url, width: size, height: size, fit: BoxFit.cover)
            : Image.asset('assets/defects/${url.split("/").last}',
                width: size, height: size, fit: BoxFit.cover),
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
