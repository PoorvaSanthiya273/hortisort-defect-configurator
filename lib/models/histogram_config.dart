class QualityBand {
  String label;
  double start;
  double end;

  QualityBand({required this.label, required this.start, required this.end});

  String get description {
    switch (label) {
      case 'Good':
        return 'Accepted quality';
      case 'Slightly Bad':
        return 'Minor defect';
      case 'Bad':
        return 'Serious defect';
      default:
        return '';
    }
  }
}

class HistogramConfig {
  double histogramMin;
  double histogramMax;
  double bandMin;
  double bandMax;
  List<QualityBand> bands;

  HistogramConfig({
    this.histogramMin = 0,
    this.histogramMax = 100,
    this.bandMin = 0,
    this.bandMax = 100,
    List<QualityBand>? bands,
  }) : bands = bands ??
            [
              QualityBand(label: 'Good', start: 0, end: 40),
              QualityBand(label: 'Slightly Bad', start: 40, end: 70),
              QualityBand(label: 'Bad', start: 70, end: 100),
            ];

  void applyPreset(String preset) {
    switch (preset) {
      case 'Sensitive':
        bands[0].end = 50;
        bands[1].start = 50;
        bands[1].end = 80;
        bands[2].start = 80;
      case 'Balanced':
        bands[0].end = 40;
        bands[1].start = 40;
        bands[1].end = 70;
        bands[2].start = 70;
      case 'Strict':
        bands[0].end = 30;
        bands[1].start = 30;
        bands[1].end = 60;
        bands[2].start = 60;
    }
  }
}
