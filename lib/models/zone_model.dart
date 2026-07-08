class ZoneModel {
  final String id;
  final String name;

  const ZoneModel({required this.id, required this.name});

  static const List<ZoneModel> defaults = [
    ZoneModel(id: 'Z01', name: 'D1'),
    ZoneModel(id: 'Z02', name: 'D2'),
    ZoneModel(id: 'Z03', name: 'D3'),
    ZoneModel(id: 'Z04', name: 'Stem End'),
    ZoneModel(id: 'Z05', name: 'Calyx End'),
    ZoneModel(id: 'Z06', name: 'Stem'),
    ZoneModel(id: 'Z07', name: 'Calyx'),
  ];
}
