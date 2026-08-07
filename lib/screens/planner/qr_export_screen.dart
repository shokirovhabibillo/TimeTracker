import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/task_model.dart';
import '../../services/plan_share_service.dart';

class QrExportScreen extends StatelessWidget {
  final List<TaskModel> tasks;
  const QrExportScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final payload = PlanShareService.encodeDayPlan(tasks);
    final tooBig = payload.length > 1800; // practical QR scan-reliability limit

    return Scaffold(
      appBar: AppBar(title: const Text('Kun tartibini ulashish')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tooBig)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Diqqat: bu reja juda ko'p vazifadan iborat — QR kod skanerlashda "
                    "qiyinchilik tug'dirishi mumkin. Kamroq vazifali kunni tanlashga harakat qiling.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 260,
                  gapless: false,
                ),
              ),
              const SizedBox(height: 16),
              Text('${tasks.length} vazifa — boshqa telefonda "QR orqali olish" bilan skanerlansin',
                  textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}
