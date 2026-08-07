import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/step_model.dart';
import '../../data/repositories/step_repository.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _repository = StepRepository();
  StreamSubscription<Position>? _sub;
  final List<({double lat, double lng})> _points = [];
  double _distanceMeters = 0;
  bool _tracking = false;
  DateTime? _startedAt;
  String? _error;

  Future<void> _start() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _error = "Joylashuv ruxsati berilmadi.");
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _error = "Telefonda joylashuv (GPS) o'chiq.");
      return;
    }

    setState(() {
      _tracking = true;
      _points.clear();
      _distanceMeters = 0;
      _startedAt = DateTime.now();
      _error = null;
    });

    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      setState(() {
        if (_points.isNotEmpty) {
          _distanceMeters += Geolocator.distanceBetween(
              _points.last.lat, _points.last.lng, pos.latitude, pos.longitude);
        }
        _points.add((lat: pos.latitude, lng: pos.longitude));
      });
    });
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    if (_points.length >= 2) {
      await _repository.saveRouteSession(RouteSession(
        startedAt: _startedAt!,
        endedAt: DateTime.now(),
        distanceMeters: _distanceMeters,
        points: _points,
      ));
    }
    setState(() => _tracking = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Yurish shakli')),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: TextStyle(color: scheme.error)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${(_distanceMeters / 1000).toStringAsFixed(2)} km · ${_points.length} nuqta',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: _ShapePainter(points: _points, color: scheme.primary),
                child: _points.isEmpty
                    ? Center(
                        child: Text("Boshlanganda yurgan yo'lingiz shu yerda chiziladi",
                            style: TextStyle(color: Theme.of(context).hintColor)),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _tracking ? _stop : _start,
              icon: Icon(_tracking ? Icons.stop : Icons.play_arrow),
              label: Text(_tracking ? "To'xtatish va saqlash" : 'Boshlash'),
              style: ElevatedButton.styleFrom(backgroundColor: _tracking ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plots the raw lat/lng path scaled to fit the canvas — a literal
/// "shape of your walk" rather than a full street map (which would
/// require map tiles and an API key).
class _ShapePainter extends CustomPainter {
  final List<({double lat, double lng})> points;
  final Color color;
  _ShapePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final lats = points.map((p) => p.lat).toList();
    final lngs = points.map((p) => p.lng).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final latRange = (maxLat - minLat).abs() < 1e-9 ? 1e-9 : (maxLat - minLat);
    final lngRange = (maxLng - minLng).abs() < 1e-9 ? 1e-9 : (maxLng - minLng);

    const padding = 20.0;
    Offset toOffset(({double lat, double lng}) p) {
      final x = padding + (p.lng - minLng) / lngRange * (size.width - padding * 2);
      final y = padding + (1 - (p.lat - minLat) / latRange) * (size.height - padding * 2);
      return Offset(x, y);
    }

    final path = Path()..moveTo(toOffset(points.first).dx, toOffset(points.first).dy);
    for (final p in points.skip(1)) {
      final o = toOffset(p);
      path.lineTo(o.dx, o.dy);
    }

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawCircle(toOffset(points.first), 5, Paint()..color = Colors.green);
    canvas.drawCircle(toOffset(points.last), 5, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) => true;
}
