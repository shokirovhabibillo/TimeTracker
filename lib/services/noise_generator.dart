import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Generates short looping ambient-noise WAV files on-device the first
/// time each track is requested, then caches them to disk. This avoids
/// needing any licensed audio assets — everything here is synthesized.
class NoiseGenerator {
  static final Random _rand = Random();
  static const int _sampleRate = 44100;
  static const int _seconds = 6;

  static Future<String> fileFor(String trackId) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/noise_$trackId.wav');
    if (await file.exists() && await file.length() > 44) {
      return file.path;
    }
    final samples = switch (trackId) {
      'white_noise' => _generateWhite(),
      'brown_noise' => _generateBrown(),
      'rain' => _generateRain(),
      'forest' => _generateForest(),
      _ => _generateWhite(),
    };
    await file.writeAsBytes(_wavBytes(samples));
    return file.path;
  }

  static Int16List _generateWhite() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    for (var i = 0; i < n; i++) {
      samples[i] = ((_rand.nextDouble() * 2 - 1) * 7000).round();
    }
    return samples;
  }

  static Int16List _generateBrown() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.08;
      last = (last + white).clamp(-1.0, 1.0);
      samples[i] = (last * 12000).round();
    }
    return samples;
  }

  static Int16List _generateRain() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.05;
      last = (last + white).clamp(-1.0, 1.0);
      double v = last * 6000;
      if (_rand.nextDouble() < 0.0006) {
        v += (_rand.nextDouble() * 2 - 1) * 9000; // occasional droplet
      }
      samples[i] = v.clamp(-32768, 32767).round();
    }
    return samples;
  }

  static Int16List _generateForest() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.03;
      last = (last + white).clamp(-1.0, 1.0);
      samples[i] = (last * 4000).round();
    }
    // A handful of soft bird-like chirps scattered through the loop.
    for (var c = 0; c < _seconds * 2; c++) {
      final start = _rand.nextInt(n - 3000);
      final freq = 1500 + _rand.nextDouble() * 1500;
      for (var j = 0; j < 3000 && start + j < n; j++) {
        final env = sin(pi * j / 3000);
        final s = sin(2 * pi * freq * j / _sampleRate) * env * 3000;
        samples[start + j] = (samples[start + j] + s).clamp(-32768, 32767).round();
      }
    }
    return samples;
  }

  static Uint8List _wavBytes(Int16List samples) {
    final dataLength = samples.length * 2;
    final bb = BytesBuilder();

    void writeString(String s) => bb.add(s.codeUnits);
    void writeUint32(int v) =>
        bb.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
    void writeUint16(int v) => bb.add([v & 0xff, (v >> 8) & 0xff]);

    writeString('RIFF');
    writeUint32(36 + dataLength);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1); // PCM
    writeUint16(1); // mono
    writeUint32(_sampleRate);
    writeUint32(_sampleRate * 2); // byte rate
    writeUint16(2); // block align
    writeUint16(16); // bits per sample
    writeString('data');
    writeUint32(dataLength);

    final byteData = ByteData(dataLength);
    for (var i = 0; i < samples.length; i++) {
      byteData.setInt16(i * 2, samples[i], Endian.little);
    }
    bb.add(byteData.buffer.asUint8List());
    return bb.toBytes();
  }
}
