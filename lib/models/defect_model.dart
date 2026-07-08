class DefectModel {
  final String id;
  final String name;
  final String category;
  final String description;
  bool configured;

  DefectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.configured = false,
  });

  static final List<DefectModel> defaults = [
    DefectModel(
        id: 'D01',
        name: 'Green / Solanine',
        category: 'Color Defect',
        description: 'Green discoloration from solanine buildup'),
    DefectModel(
        id: 'D02',
        name: 'Cracks',
        category: 'Surface Defect',
        description: 'Surface cracks and fissures'),
    DefectModel(
        id: 'D03',
        name: 'Stones and Clods',
        category: 'Foreign Material',
        description: 'Stones, soil, and debris'),
    DefectModel(
        id: 'D04',
        name: 'Rhizoctonia',
        category: 'Surface Defect',
        description: 'Black scurf fungal infection'),
    DefectModel(
        id: 'D05',
        name: 'Aging',
        category: 'Decay / Damage',
        description: 'Aging, shriveling, and softening'),
    DefectModel(
        id: 'D06',
        name: 'Rotten',
        category: 'Decay / Damage',
        description: 'Rot and decay damage'),
    DefectModel(
        id: 'D07',
        name: 'Fresh Cut',
        category: 'Decay / Damage',
        description: 'Fresh cut or sliced surface'),
    DefectModel(
        id: 'D08',
        name: 'Blackspot',
        category: 'Surface Defect',
        description: 'Dark spots on the surface'),
    DefectModel(
        id: 'D09',
        name: 'Scab',
        category: 'Surface Defect',
        description: 'Scab lesions and rough patches'),
    DefectModel(
        id: 'D10',
        name: 'Misshape',
        category: 'Shape Defect',
        description: 'Irregular or deformed shape'),
    DefectModel(
        id: 'D11',
        name: 'Leaf / Grass',
        category: 'Foreign Material',
        description: 'Leaf and grass debris'),
  ];
}
