import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final settings = context.read<SettingsProvider>();
    final current = isStart
        ? settings.settings.sleepStartTime
        : settings.settings.sleepEndTime;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    if (isStart) {
      await settings.setSleepWindow(formatted, settings.settings.sleepEndTime);
    } else {
      await settings.setSleepWindow(settings.settings.sleepStartTime, formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Mavzu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioListTile<AppThemeType>(
            title: const Text('High-Tech / Neon HUD'),
            subtitle: const Text('Qorong\'u fon, neon urg\'ular, gamifikatsiya'),
            value: AppThemeType.hightech,
            groupValue: settings.themeType,
            onChanged: (v) => settings.setThemeType(v!),
          ),
          RadioListTile<AppThemeType>(
            title: const Text("An'anaviy / Minimalist"),
            subtitle: const Text('Yorug\' fon, sokin ranglar'),
            value: AppThemeType.classic,
            groupValue: settings.themeType,
            onChanged: (v) => settings.setThemeType(v!),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Uyqu vaqti', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Uyqu boshlanishi'),
            trailing: Text(settings.settings.sleepStartTime),
            onTap: () => _pickTime(context, true),
          ),
          ListTile(
            title: const Text('Uyg\'onish vaqti'),
            trailing: Text(settings.settings.sleepEndTime),
            onTap: () => _pickTime(context, false),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Diqqat tahlili", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text("Kunlik chalg'ituvchi ilova limiti"),
            subtitle: Slider(
              value: settings.settings.dailyDistractionLimitMin.toDouble(),
              min: 15,
              max: 240,
              divisions: 15,
              label: '${settings.settings.dailyDistractionLimitMin} daq',
              onChanged: (v) => settings.setDistractionLimit(v.round()),
            ),
            trailing: Text('${settings.settings.dailyDistractionLimitMin} daq'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Bildirishnoma ruxsatlarini so\'rash'),
            onTap: () => NotificationService.instance.requestPermissions(),
          ),
        ],
      ),
    );
  }
}
