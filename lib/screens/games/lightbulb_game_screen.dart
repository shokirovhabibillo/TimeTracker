import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../data/repositories/daily_game_repository.dart';

enum _GameState { loading, notStarted, playing, completed, alreadyPlayed }

class LightbulbGameScreen extends StatefulWidget {
  const LightbulbGameScreen({super.key});

  @override
  State<LightbulbGameScreen> createState() => _LightbulbGameScreenState();
}

class _LightbulbGameScreenState extends State<LightbulbGameScreen> with TickerProviderStateMixin {
  static const _gameId = 'lightbulb';
  static const _sessionSeconds = 30;

  final _repository = DailyGameRepository();
  _GameState _state = _GameState.loading;
  int _remaining = _sessionSeconds;
  int _score = 0;
  double _brightness = 0; // 0..1
  int _pullCount = 0;
  Timer? _countdownTimer;
  Timer? _decayTimer;

  late final AnimationController _cordController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  double _cordDrag = 0; // px, live drag offset while dragging
  late final AnimationController _flickerController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));

  @override
  void initState() {
    super.initState();
    _load();
  }

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
      // Session ran out while the app was closed — finalize it now.
      await _repository.completeSession(_gameId, _score);
      setState(() {
        _state = _GameState.alreadyPlayed;
      });
      return;
    }
    // Resume an in-progress session (app was closed mid-game).
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
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _brightness = (_brightness - 0.02).clamp(0.0, 1.0));
    });
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
    _decayTimer?.cancel();
    await _repository.completeSession(_gameId, _score);
    if (mounted) setState(() => _state = _GameState.completed);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _cordDrag = (_cordDrag + details.delta.dy).clamp(0.0, 70.0));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_cordDrag > 30) _pull();
    _springCordBack();
  }

  void _springCordBack() {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 180, damping: 9),
      _cordDrag,
      0,
      0,
    );
    _cordController.animateWith(simulation);
    _cordController.addListener(_onCordSpringTick);
  }

  void _onCordSpringTick() {
    setState(() => _cordDrag = _cordController.value);
    if (_cordController.isCompleted) _cordController.removeListener(_onCordSpringTick);
  }

  void _pull() {
    if (_state != _GameState.playing) return;
    setState(() {
      _pullCount++;
      _brightness = (_brightness + 0.16).clamp(0.0, 1.0);
      _score += 80 + Random().nextInt(40);
    });
    _flickerController.forward(from: 0);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _decayTimer?.cancel();
    _cordController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  String _rating() {
    if (_score >= 1400) return '⭐⭐⭐ Excellent';
    if (_score >= 800) return '⭐⭐ Great';
    return '⭐ Good';
  }

  @override
  Widget build(BuildContext context) {
    final roomColor = Color.lerp(const Color(0xFF0A0A0F), const Color(0xFF3A2E1A), _brightness)!;

    return Scaffold(
      backgroundColor: roomColor,
      appBar: AppBar(
        title: const Text('Lampochka'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: switch (_state) {
          _GameState.loading => const Center(child: CircularProgressIndicator()),
          _GameState.notStarted => _buildIntro(),
          _GameState.playing => _buildPlaying(),
          _GameState.completed => _buildCompleted(),
          _GameState.alreadyPlayed => _buildAlreadyPlayed(),
        },
      ),
    );
  }

  Widget _buildIntro() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Bulb(brightness: 0.05, flicker: 0),
          const SizedBox(height: 24),
          const Text('PULL THE CORD', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
          const SizedBox(height: 4),
          const Icon(Icons.arrow_downward, color: Colors.white38),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _start, child: const Text('Boshlash (30 soniya)')),
        ],
      ),
    );
  }

  Widget _buildPlaying() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('$_remaining', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        Text('LIGHT POWER: ${(_brightness * 100).round()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _flickerController,
              builder: (context, _) {
                final flicker = sin(_flickerController.value * pi * 6) * (1 - _flickerController.value);
                return _Bulb(brightness: _brightness, flicker: flicker.abs());
              },
            ),
          ),
        ),
        GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          onTap: _pull,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                Container(width: 2, height: 30 + _cordDrag, color: Colors.white38),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
        Text('SCORE: $_score', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Bulb(brightness: _brightness, flicker: 0),
          const SizedBox(height: 24),
          const Text('DAILY CHALLENGE COMPLETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('Score: $_score', style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_rating(), style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          const Text('NEXT CHALLENGE', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
          const Text('Tomorrow', style: TextStyle(color: Colors.white54)),
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
            const Text('💡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            const Text('Bugungi challenge bajarildi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_score > 0) Text('Natija: $_score', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Keyingi o\'yin: ertaga', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Bulb extends StatelessWidget {
  final double brightness;
  final double flicker;
  const _Bulb({required this.brightness, required this.flicker});

  @override
  Widget build(BuildContext context) {
    final glow = (brightness + flicker * 0.3).clamp(0.0, 1.0);
    return Container(
      width: 120,
      height: 140,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow > 0.03)
            Container(
              width: 200 * glow,
              height: 200 * glow,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.amber.withOpacity(0.35 * glow), Colors.transparent]),
              ),
            ),
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.lerp(Colors.white24, Colors.amber.shade100, glow)!,
                  Color.lerp(Colors.white10, Colors.amber, glow)!,
                ],
              ),
              boxShadow: glow > 0.05 ? [BoxShadow(color: Colors.amber.withOpacity(0.6 * glow), blurRadius: 30 * glow)] : null,
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.white24, Colors.orangeAccent, glow),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: glow > 0.1 ? [BoxShadow(color: Colors.orange.withOpacity(glow), blurRadius: 10)] : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
