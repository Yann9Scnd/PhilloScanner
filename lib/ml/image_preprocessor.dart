import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImagePreprocessor {
  static const int inputSize = 224;
  static const int channels = 3;

  /// Resize [bytes] (encoded image) to 224x224 and return normalized float32
  /// pixel data (values 0.0-1.0) as expected by the TFLite model, which has
  /// float32 input/output tensors (weights are quantized int8).
  static Float32List preprocess(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const FormatException('Gambar tidak dapat dibaca.');
    }
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );
    final rgb = resized.getBytes(order: img.ChannelOrder.rgb);
    final result = Float32List(rgb.length);
    for (var i = 0; i < rgb.length; i++) {
      result[i] = rgb[i] / 255.0;
    }
    return result;
  }
}
