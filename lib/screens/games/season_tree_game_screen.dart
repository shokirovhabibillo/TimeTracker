import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/repositories/daily_game_repository.dart';

enum _GameState { loading, notStarted, playing, completed, alreadyPlayed }

class _Particle {
  double x, y, vx, vy, size, opacity, rotation;
  _Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size, this.opacity = 1, this.rotation = 0});
}

class SeasonTreeGameScreen extends StatefulWidget {
  const SeasonTreeGameScreen({super.key});

  @override
  State<SeasonTreeGameScreen> createState() => _SeasonTreeGameScreenState();
}

class _SeasonTreeGameScreenState extends State<SeasonTreeGameScreen> with SingleTickerProviderStateMixin {
  static const _gameId = 'season_tree';
  static const _sessionSeconds = 30;

  final _repository = DailyGameRepository();
  _GameState _state = _GameState.loading;
  int _remaining = _sessionSeconds;
  int _score = 0;
  double _season = 0; // 0..1 across Spring->Summer->Autumn->Winter
  final Set<int> _discoveredSegments = {};
  double _snowAccumulation = 0;

  Timer? _countdownTimer;
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final _rand = Random();
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _load();
  }

  int _segmentFor(double t) => (t * 4).floor().clamp(0, 3); // 0 spring,1 summer,2 autumn,3 winter

  Future<void> _load() async {
    final entry = await _repository.getTodayEntry(_gameId);
    if (entry == null) {
      setState(() => _state = _GameState.notStarted);
      return;
    }
    if (entry.isCompleted) {
      setState(() {
        _state = _GameState.alreadyPlayed;
        _score = entry.score;
      });
      return;
    }
    final remaining = entry.remainingSeconds(_sessionSeconds);
    if (remaining <= 0) {
      await _repository.completeSession(_gameId, _score);
      setState(() => _state = _GameState.alreadyPlayed);
      return;
    }
    _remaining = remaining;
    _beginPlaying();
  }

  Future<void> _start() async {
    await _repository.startOrResumeSession(_gameId);
    _remaining = _sessionSeconds;
    _beginPlaying();
  }

  void _beginPlaying() {
    setState(() => _state = _GameState.playing);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickCountdown());
    _ticker.start();
  }

  Future<void> _tickCountdown() async {
    final entry = await _repository.getTodayEntry(_gameId);
    final remaining = entry?.remainingSeconds(_sessionSeconds) ?? 0;
    if (!mounted) return;
    if (remaining <= 0) {
      await _finish();
    } else {
      setState(() => _remaining = remaining);
    }
  }

  Future<void> _finish() async {
    _countdownTimer?.cancel();
    _ticker.stop();
    await _repository.completeSession(_gameId, _score);
    if (mounted) setState(() => _state = _GameState.completed);
  }

  void _onSeasonChanged(double v) {
    setState(() => _season = v);
    final seg = _segmentFor(v);
    if (!_discoveredSegments.contains(seg)) {
      _discoveredSegments.add(seg);
      _score += 200;
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero ? 0.016 : (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;
    final seg = _segmentFor(_season);

    // Spawn particles matching the current season, at a modest rate.
    if (_rand.nextDouble() < 0.3) {
      switch (seg) {
        case 0: // spring — blossoms drift gently
          _particles.add(_Particle(x: 60 + _rand.nextDouble() * 180, y: 60, vx: (_rand.nextDouble() - 0.5) * 10, vy: 18, size: 5, rotation: _rand.nextDouble() * pi));
          break;
        case 1: // summer — sparse floating dust
          if (_rand.nextDouble() < 0.3) {
            _particles.add(_Particle(x: _rand.nextDouble() * 300, y: 250, vx: (_rand.nextDouble() - 0.5) * 6, vy: -6, size: 2, opacity: 0.4));
          }
          break;
        case 2: // autumn — falling leaves with sideways drift
          _particles.add(_Particle(x: 40 + _rand.nextDouble() * 200, y: 80, vx: (_rand.nextDouble() - 0.3) * 24, vy: 26, size: 7, rotation: _rand.nextDouble() * pi));
          break;
        case 3: // winter — snow, gentle sway
          _particles.add(_Particle(x: _rand.nextDouble() * 300, y: 0, vx: sin(_rand.nextDouble() * pi) * 8, vy: 22, size: 4, opacity: 0.85));
          if (_snowAccumulation < 1) _snowAccumulation += 0.004;
          break;
      }
    }

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vx += sin(p.y * 0.05) * 0.4; // gentle wind sway
      p.rotation += dt;
    }
    _particles.removeWhere((p) => p.y > 420);
    if (_particles.length > 80) _particles.removeRange(0, _particles.length - 80);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  List<Color> _skyColors() {
    if (_season < 0.25) return const [Color(0xFFFFE4EC), Color(0xFFD8F3DC)]; // spring pastel
    if (_season < 0.5) return const [Color(0xFF9BD8FF), Color(0xFFE8F7FF)]; // summer bright
    if (_season < 0.75) return const [Color(0xFFFFC98B), Color(0xFFB56B45)]; // autumn warm
    return const [Color(0xFFB9CDE0), Color(0xFFE9F1F7)]; // winter cool
  }

  String _seasonLabel() {
    if (_season < 0.25) return '🌱 Spring';
    if (_season < 0.5) return '☀️ Summer';
    if (_season < 0.75) return '🍂 Autumn';
    return '❄️ Winter';
  }

  String _rating() {
    if (_score >= 900) return '⭐⭐⭐ Excellent';
    if (_score >= 500) return '⭐⭐ Great';
    return '⭐ Good';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To'rt fasl daraxti")),
      body: switch (_state) {
        _GameState.loading => const Center(child: CircularProgressIndicator()),
        _GameState.notStarted => _buildIntro(),
        _GameState.playing => _buildPlaying(),
        _GameState.completed => _buildCompleted(),
        _GameState.alreadyPlayed => _buildAlreadyPlayed(),
      },
    );
  }

  Widget _buildIntro() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌳', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text("Slayderni surib, daraxtni to'rt faslga o'tkazing", textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _start, child: const Text('Boshlash (30 soniya)')),
        ],
      ),
    );
  }

  Widget _buildPlaying() {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _skyColors())),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('$_remaining', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(_seasonLabel(), style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: CustomPaint(
              painter: _TreePainter(season: _season, particles: _particles, snowAccumulation: _snowAccumulation),
              child: const SizedBox.expand(),
            ),
          ),
          Wrap(
            spacing: 8,
            children: List.generate(4, (i) {
              const labels = ['🌱', '☀️', '🍂', '❄️'];
              final discovered = _discoveredSegments.contains(i);
              return Chip(
                label: Text(labels[i]),
                backgroundColor: discovered ? Colors.green.withOpacity(0.2) : null,
                avatar: discovered ? const Icon(Icons.check, size: 16) : null,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Slider(value: _season, onChanged: _onSeasonChanged),
          ),
          Text('SEASON SCORE: $_score'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌳', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text("TODAY'S SEASON CHALLENGE COMPLETE", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Score: $_score', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_rating()),
          const SizedBox(height: 16),
          const Text('Next challenge: Tomorrow', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAlreadyPlayed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌳', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            const Text("Today's challenge is complete", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_score > 0) Text('Score: $_score'),
            const SizedBox(height: 8),
            const Text('Come back tomorrow for a new season challenge.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double season; // 0..1
  final List<_Particle> particles;
  final double snowAccumulation;
  _TreePainter({required this.season, required this.particles, required this.snowAccumulation});

  Color _leafColor() {
    if (season < 0.25) return Color.lerp(const Color(0xFFB9E4A0), const Color(0xFF6FBF4F), season / 0.25)!;
    if (season < 0.5) return const Color(0xFF2F8F3E);
    if (season < 0.75) return Color.lerp(const Color(0xFF2F8F3E), const Color(0xFFD97B29), (season - 0.5) / 0.25)!;
    return const Color(0xFF6B4A2F); // bare branches tone
  }

  double _leafDensity() {
    if (season < 0.25) return season / 0.25; // buds appearing
    if (season < 0.5) return 1.0;
    if (season < 0.75) return 1 - (season - 0.5) / 0.25; // falling
    return 0.0; // bare
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.85;

    // Trunk.
    final trunkPaint = Paint()..color = const Color(0xFF6B4A32);
    canvas.drawRect(Rect.fromLTWH(cx - 8, groundY - 90, 16, 90), trunkPaint);

    // Branches (fixed simple set).
    final branchPaint = Paint()
      ..color = const Color(0xFF6B4A32)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final branchTips = <Offset>[];
    for (final angle in [-0.9, -0.4, 0.1, 0.5, 0.95]) {
      final start = Offset(cx, groundY - 80);
      final end = start + Offset(sin(angle) * 70, -60 - cos(angle).abs() * 20);
      canvas.drawLine(start, end, branchPaint);
      branchTips.add(end);
    }

    // Foliage clusters at branch tips + crown, density/color per season.
    final density = _leafDensity();
    if (density > 0.02) {
      final leafPaint = Paint()..color = _leafColor().withOpacity(0.9);
      canvas.drawCircle(Offset(cx, groundY - 150), 55 * density.clamp(0.3, 1.0), leafPaint);
      for (final tip in branchTips) {
        canvas.drawCircle(tip, 22 * density, leafPaint);
      }
    }

    // Snow caps in winter, growing with accumulation.
    if (season >= 0.75 && snowAccumulation > 0.02) {
      final snowPaint = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, groundY - 150), radius: 40 * snowAccumulation.clamp(0.2, 1)), pi, pi, false, snowPaint);
      for (final tip in branchTips) {
        canvas.drawArc(Rect.fromCircle(center: tip, radius: 14 * snowAccumulation.clamp(0.2, 1)), pi, pi, false, snowPaint);
      }
    }

    // Ground line.
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), Paint()..color = Colors.black12..strokeWidth = 2);

    // Particles.
    for (final p in particles) {
      final paint = Paint()..color = _particleColor().withOpacity(p.opacity);
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      if (season >= 0.75) {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      }
      canvas.restore();
    }
  }

  Color _particleColor() {
    if (season < 0.25) return const Color(0xFFFFC0D9);
    if (season < 0.5) return Colors.white;
    if (season < 0.75) return const Color(0xFFD97B29);
    return Colors.white;
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) => true;
}
