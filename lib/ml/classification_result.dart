class LeafClassification {
  final String label;
  final double confidence;
  final int classIndex;

  const LeafClassification({
    required this.label,
    required this.confidence,
    required this.classIndex,
  });

  factory LeafClassification.empty() {
    return const LeafClassification(
      label: 'Tidak Diketahui',
      confidence: 0,
      classIndex: -1,
    );
  }
}
