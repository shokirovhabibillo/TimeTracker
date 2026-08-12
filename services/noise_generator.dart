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
  static const int _seconds = 12;

  // Bumping this invalidates any previously cached (older, harsher-
  // sounding) files from earlier app versions so the improved synthesis
  // actually gets used instead of a stale cached file.
  static const String _version = 'v2';

  static Future<String> fileFor(String trackId) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/noise_${_version}_$trackId.wav');
    if (await file.exists() && await file.length() > 44) {
      return file.path;
    }
    final samples = switch (trackId) {
      'white_noise' => _generateWhite(),
      'brown_noise' => _generateBrown(),
      'rain' => _generateWater(),
      'forest' => _generateBirds(),
      _ => _generateWhite(),
    };
    _crossfadeLoop(samples);
    await file.writeAsBytes(_wavBytes(samples));
    return file.path;
  }

  /// Blends the last ~300ms into the first ~300ms so the loop point is
  /// inaudible instead of producing a click/pop every time it repeats.
  static void _crossfadeLoop(Int16List samples) {
    final fadeLen = (_sampleRate * 0.3).round();
    if (samples.length <= fadeLen * 2) return;
    for (var i = 0; i < fadeLen; i++) {
      final t = i / fadeLen; // 0..1
      final headIdx = i;
      final tailIdx = samples.length - fadeLen + i;
      final blended = samples[tailIdx] * (1 - t) + samples[headIdx] * t;
      samples[headIdx] = blended.round().clamp(-32768, 32767);
    }
  }

  static Int16List _generateWhite() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    for (var i = 0; i < n; i++) {
      samples[i] = ((_rand.nextDouble() * 2 - 1) * 5000).round();
    }
    return samples;
  }

  static Int16List _generateBrown() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.06;
      last = (last + white).clamp(-1.0, 1.0);
      samples[i] = (last * 9000).round();
    }
    return samples;
  }

  /// Gentle flowing-water / stream babble: a soft filtered noise bed
  /// with slow amplitude swells, plus scattered short "bubble" blips
  /// (quick damped tone pops) — much softer and more pleasant than raw
  /// static.
  static Int16List _generateWater() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.04;
      last = (last + white).clamp(-1.0, 1.0);
      // Slow swelling envelope so it "breathes" like flowing water
      // rather than a flat hiss.
      final swell = 0.7 + 0.3 * sin(2 * pi * i / (_sampleRate * 4.0));
      samples[i] = (last * 3200 * swell).round().clamp(-32768, 32767);
    }
    // Soft bubble blips: short damped sine pops at a comfortable pitch.
    final bubbleCount = _seconds * 3;
    for (var c = 0; c < bubbleCount; c++) {
      final start = _rand.nextInt(n - 1200);
      final freq = 500 + _rand.nextDouble() * 700;
      const len = 900;
      for (var j = 0; j < len && start + j < n; j++) {
        final decay = exp(-j / (len * 0.25));
        final s = sin(2 * pi * freq * j / _sampleRate) * decay * 2600;
        samples[start + j] = (samples[start + j] + s).round().clamp(-32768, 32767);
      }
    }
    return samples;
  }

  /// Natural-sounding birdsong: a very quiet ambient bed with sparse,
  /// varied chirps built from short pitch sweeps (mimicking a sparrow's
  /// trill, a starling's warble, and a nightingale-style rising call)
  /// instead of a single flat tone.
  static Int16List _generateBirds() {
    final n = _seconds * _sampleRate;
    final samples = Int16List(n);
    double last = 0;
    for (var i = 0; i < n; i++) {
      final white = (_rand.nextDouble() * 2 - 1) * 0.015;
      last = (last + white).clamp(-1.0, 1.0);
      samples[i] = (last * 1200).round();
    }

    final callCount = _seconds ~/ 2;
    for (var c = 0; c < callCount; c++) {
      final callType = _rand.nextInt(3);
      final start = _rand.nextInt(n - 6000);
      switch (callType) {
        case 0: // quick upward chirp (sparrow-like)
          _writeSweep(samples, n, start, 2200, 3400, 1400, 2600);
          break;
        case 1: // trill: a few rapid short notes (starling-like)
          for (var t = 0; t < 4; t++) {
            final s = start + t * 900;
            _writeSweep(samples, n, s, 1800 + t * 120, 2400 + t * 120, 600, 2400);
          }
          break;
        case 2: // slow rising warble (nightingale-like)
          _writeSweep(samples, n, start, 1200, 2800, 3200, 2200);
          break;
      }
    }
    return samples;
  }

  /// Writes a short frequency sweep from [f0] to [f1] Hz, [durationSamples]
  /// long, starting at [start], with a smooth fade-in/out envelope.
  static void _writeSweep(
      Int16List samples, int n, int start, double f0, double f1, int durationSamples, double amplitude) {
    for (var j = 0; j < durationSamples && start + j < n; j++) {
      final t = j / durationSamples;
      final freq = f0 + (f1 - f0) * t;
      final env = sin(pi * t); // fade in then out
      final s = sin(2 * pi * freq * j / _sampleRate) * env * amplitude;
      final idx = start + j;
      samples[idx] = (samples[idx] + s).round().clamp(-32768, 32767);
    }
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
