/// Informasi penyakit untuk hasil klasifikasi offline.
///
/// Label berasal dari `assets/models/chili_classifier.txt` (urutan harus
/// sama dengan indeks output model TFLite).
class ChiliDiseaseInfo {
  final String label;
  final String diseaseName;
  final String scientificName;
  final String severity;
  final List<String> recommendations;

  const ChiliDiseaseInfo({
    required this.label,
    required this.diseaseName,
    required this.scientificName,
    required this.severity,
    required this.recommendations,
  });
}

const List<ChiliDiseaseInfo> kChiliDiseaseInfo = [
  ChiliDiseaseInfo(
    label: 'healthy',
    diseaseName: 'Daun Sehat',
    scientificName: 'Capsicum annuum — kondisi optimal',
    severity: 'Rendah',
    recommendations: [
      'Tanaman dalam kondisi sehat. Pertahankan penyiraman dan nutrisi secara teratur.',
      'Lakukan monitoring rutin untuk mendeteksi serangan hama/penyakit lebih awal.',
      'Pastikan sirkulasi udara dan paparan sinar matahari cukup (6-8 jam/hari).',
    ],
  ),
  ChiliDiseaseInfo(
    label: 'leaf curl',
    diseaseName: 'Daun Keriting',
    scientificName: 'Curly top / virus daun keriting',
    severity: 'Sedang',
    recommendations: [
      'Segera isolasi tanaman terinfeksi untuk mencegah penyebaran virus.',
      'Kendalikan vektor (kutu kebul/whitefly) yang membawa virus dengan insektisida.',
      'Buang dan musnahkan daun yang terinfeksi parah; jaga kebersihan lahan.',
    ],
  ),
  ChiliDiseaseInfo(
    label: 'leaf spot',
    diseaseName: 'Bercak Daun',
    scientificName: 'Cercospora / antraknosa',
    severity: 'Sedang',
    recommendations: [
      'Aplikasikan fungisida berbahan aktif mankozeb atau klorotalonil sesuai dosis.',
      'Kurangi kelembapan berlebih dan hindari penyiraman dari atas daun.',
      'Pangkas daun yang terserang dan beri jarak tanam agar sirkulasi udara baik.',
    ],
  ),
  ChiliDiseaseInfo(
    label: 'whitefly',
    diseaseName: 'Kutu Kebul',
    scientificName: 'Bemisia tabaci (whitefly)',
    severity: 'Tinggi',
    recommendations: [
      'Gunakan perangkap kuning dan insektisida nabati untuk menekan populasi kutu kebul.',
      'Semprot insektisida sistemik (imidacloprid) pada fase awal serangan.',
      'Hilangkan gulma inang di sekitar lahan dan pantau bagian bawah daun.',
    ],
  ),
  ChiliDiseaseInfo(
    label: 'yellowish',
    diseaseName: 'Daun Menguning',
    scientificName: 'Kekuningan / defisiensi nutrisi',
    severity: 'Sedang',
    recommendations: [
      'Periksa pH tanah; batas optimal untuk cabai adalah 6.0-6.5.',
      'Tambahkan pupuk yang mengandung nitrogen, magnesium, atau besi sesuai gejala.',
      'Pastikan drainase baik dan hindari genangan air yang memicu busuk akar.',
    ],
  ),
];

/// Mencari info penyakit berdasarkan label dari model.
ChiliDiseaseInfo? chiliDiseaseInfoByLabel(String? label) {
  if (label == null) return null;
  for (final info in kChiliDiseaseInfo) {
    if (info.label == label) return info;
  }
  return null;
}
