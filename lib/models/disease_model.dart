class DiseaseModel {
  final int? id;
  final String name;
  final String scientificName;
  final String category; // Jamur, Bakteri, Virus, Sehat
  final String imageUrl;
  final String description;
  final String symptoms;
  final List<String> treatmentSteps;

  const DiseaseModel({
    this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.symptoms,
    required this.treatmentSteps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'image_url': imageUrl,
      'description': description,
      'symptoms': symptoms,
      'treatment_steps': treatmentSteps.join('||'),
    };
  }

  factory DiseaseModel.fromMap(Map<String, dynamic> map) {
    final stepsString = map['treatment_steps'] as String? ?? '';
    return DiseaseModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      scientificName: map['scientific_name'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      symptoms: map['symptoms'] as String? ?? '',
      treatmentSteps: stepsString.isNotEmpty ? stepsString.split('||') : [],
    );
  }
}
