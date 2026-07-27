import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WhiteNoiseTrack {
  final String id;
  final String label;
  final String assetPath;
  const WhiteNoiseTrack(this.id, this.label, this.assetPath);
}

/// Built-in ambient / white-noise generator used during Focus Mode.
/// Ships with a few looped ambient tracks; drop matching audio files
/// into `assets/sounds/` (see README) — the player loops them
/// seamlessly for the duration of a focus session.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentTrackId;
  double _volume = 0.6;

  static const tracks = [
    WhiteNoiseTrack('white_noise', 'Oq shovqin', 'sounds/white_noise.mp3'),
    WhiteNoiseTrack('rain', 'Yomg\'ir', 'sounds/rain.mp3'),
    WhiteNoiseTrack('forest', "O'rmon", 'sounds/forest.mp3'),
    WhiteNoiseTrack('brown_noise', 'Jigarrang shovqin', 'sounds/brown_noise.mp3'),
  ];

  String? get currentTrackId => _currentTrackId;
  double get volume => _volume;

  Future<void> play(String trackId) async {
    final track = tracks.firstWhere((t) => t.id == trackId,
        orElse: () => tracks.first);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_volume);
    await _player.play(AssetSource(track.assetPath));
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
