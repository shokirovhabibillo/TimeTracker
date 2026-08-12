import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'noise_generator.dart';

class WhiteNoiseTrack {
  final String id;
  final String label;
  final String assetPath;
  const WhiteNoiseTrack(this.id, this.label, this.assetPath);
}

/// Ambient / white-noise generator used during Focus Mode.
///
/// **To use real recorded nature sounds instead of the built-in
/// synthesized ones:** drop your own royalty-free/licensed audio files
/// into `assets/sounds/` named exactly `white_noise.mp3`, `rain.mp3`,
/// `forest.mp3`, `brown_noise.mp3` (that folder is already declared in
/// pubspec.yaml, so anything placed there gets bundled automatically).
/// This service checks for a real file first and plays it if found;
/// only if it's missing does it fall back to the procedurally
/// generated sound. Claude can't legally bundle copyrighted recordings
/// or record real audio itself — this is the way to swap in genuine
/// nature recordings without needing any code changes.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentTrackId;
  double _volume = 0.6;

  static const tracks = [
    WhiteNoiseTrack('white_noise', 'Oq shovqin', 'sounds/white_noise.mp3'),
    WhiteNoiseTrack('rain', 'Suv shildirashi', 'sounds/rain.mp3'),
    WhiteNoiseTrack('forest', 'Qushlar sayrashi', 'sounds/forest.mp3'),
    WhiteNoiseTrack('brown_noise', 'Jigarrang shovqin', 'sounds/brown_noise.mp3'),
  ];

  String? get currentTrackId => _currentTrackId;
  double get volume => _volume;

  Future<bool> _hasRealAsset(String assetPath) async {
    try {
      final data = await rootBundle.load('assets/$assetPath');
      return data.lengthInBytes > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> play(String trackId) async {
    final track = tracks.firstWhere((t) => t.id == trackId,
        orElse: () => tracks.first);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_volume);

    if (await _hasRealAsset(track.assetPath)) {
      await _player.play(AssetSource(track.assetPath));
    } else {
      final path = await NoiseGenerator.fileFor(track.id);
      await _player.play(DeviceFileSource(path));
    }
    _currentTrackId = trackId;
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    await _player.setVolume(value);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentTrackId = null;
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();
}

/// "Keep Screen On" toggle for the Landscape Focus Mode dashboard.
class ScreenWakeService {
  static Future<void> enable() => WakelockPlus.enable();
  static Future<void> disable() => WakelockPlus.disable();
}
