import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models/task_model.dart';
import '../../services/plan_share_service.dart';

class QrImportScreen extends StatefulWidget {
  final DateTime targetDay;
  const QrImportScreen({super.key, required this.targetDay});

  @override
  State<QrImportScreen> createState() => _QrImportScreenState();
}

class _QrImportScreenState extends State<QrImportScreen> {
  final MobileScannerController _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  List<TaskModel>? _decoded;
  String? _planName;
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;
    final tasks = PlanShareService.decodeDayPlan(raw, targetDay: widget.targetDay);
    if (tasks == null) return;
    setState(() {
      _decoded = tasks;
      _planName = PlanShareService.planNameFrom(raw);
      _handled = true;
    });
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR orqali kun tartibini olish')),
      body: _decoded == null
          ? Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Boshqa telefondagi \"Kun tartibini ulashish\" QR kodini kamera oldiga tuting",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_planName ?? 'Topilgan reja', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${_decoded!.length} vazifa topildi:', style: TextStyle(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _decoded!.length,
                      itemBuilder: (context, i) {
                        final t = _decoded![i];
                        return Card(
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text(
                                '${TaskCategory.label(t.category)} · ${t.startTime.hour.toString().padLeft(2, '0')}:${t.startTime.minute.toString().padLeft(2, '0')}'),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            _decoded = null;
                            _handled = false;
                            _controller.start();
                          }),
                          child: const Text('Qayta skanerlash'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(_decoded),
                          child: const Text('Import qilish'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
