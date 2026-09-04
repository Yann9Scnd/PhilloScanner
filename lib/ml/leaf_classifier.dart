import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';

import 'classification_result.dart';

/// On-device leaf disease classifier running a quantized TFLite model.
///
/// Works fully offline (no AI cloud). Uses the flutter_litert classic
/// Interpreter API which supports both native (Android/iOS/desktop) and web
/// runtimes.
class LeafClassifier {
  LeafClassifier._();

  static final LeafClassifier instance = LeafClassifier._();

  static const String _modelAsset = 'assets/models/model_daun_cabai.tflite';
  static const String _labelAsset = 'assets/models/chili_classifier.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _initializedWeb = false;
  int _inputElements = 0;

  /// Whether the model and labels are loaded and ready for inference.
  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  /// Number of elements the model expects as flat input (224*224*3).
  int get expectedInputElements => _inputElements;

  Future<void> _ensureWeb() async {
    if (!_initializedWeb && !isReady) {
      await initializeWeb();
      _initializedWeb = true;
    }
  }

  /// Loads the model and labels into memory. Safe to call multiple times.
  Future<void> load() async {
    if (isReady) return;

    await _ensureWeb();

    final modelData = await rootBundle.load(_modelAsset);
    final labelsData = await rootBundle.load(_labelAsset);

    _labels = const Utf8Decoder()
        .convert(labelsData.buffer.asUint8List())
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final interpreter = await Interpreter.fromBytes(
      modelData.buffer.asUint8List(),
      options: InterpreterOptions()..threads = 2,
    );
    interpreter.allocateTensors();

    var elems = 1;
    for (final d in interpreter.getInputTensor(0).shape) {
      elems *= d;
    }
    _inputElements = elems;

    _interpreter = interpreter;
  }

  /// Runs classification on normalized float32 [input] (Float32List of
  /// `224*224*3` values in 0.0-1.0 range) and returns the most confident label.
  LeafClassification classify(Float32List input) {
    final interp = _interpreter;
    if (interp == null || _labels.isEmpty) {
      throw StateError('Model belum dimuat. Panggil load() terlebih dahulu.');
    }
    if (input.length != _inputElements) {
      throw StateError(
        'Ukuran input tidak cocok: ${input.length} != $_inputElements.',
      );
    }

    final output = Float32List(_labels.length);
    interp.run(input, output);

    var bestIdx = 0;
    var bestScore = -1.0;
    for (var i = 0; i < output.length; i++) {
      final score = output[i];
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }

    final label =
        bestIdx >= 0 && bestIdx < _labels.length ? _labels[bestIdx] : 'Tidak Diketahui';
    return LeafClassification(
      label: label,
      confidence: bestScore.clamp(0.0, 1.0),
      classIndex: bestIdx,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = const [];
    _inputElements = 0;
  }
}
