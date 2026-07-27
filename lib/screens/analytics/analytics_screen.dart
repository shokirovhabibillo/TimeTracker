import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_usage_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/usage_provider.dart';
import '../../widgets/progress_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usage = context.read<UsageProvider>();
      await usage.checkPermission();
      if (usage.hasPermission) {
        await usage.refresh();
        final limit =
            context.read<SettingsProvider>().settings.dailyDistractionLimitMin;
        await usage.checkAndWarnIfOverLimit(limit);
      }
    });
  }

  String _categoryLabel(String c) {
    switch (c) {
      case AppCategory.social:
        return 'Ijtimoiy tarmoqlar';
      case AppCategory.games:
        return "O'yinlar";
      case AppCategory.entertainment:
        return "Ko'ngilochar";
      case AppCategory.productivity:
        return 'Samaradorlik';
      default:
        return 'Boshqa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<UsageProvider>();
    final settings = context.watch<SettingsProvider>();
    final isHightech = settings.themeType == AppThemeType.hightech;
    final warnColor = isHightech ? AppColors.htCyberRed : Colors.red.shade700;
    final limit = settings.settings.dailyDistractionLimitMin;

    return Scaffold(
      appBar: AppBar(title: const Text('Diqqat tahlili')),
      body: !usage.isNativeSupported
          ? _UnsupportedPlatformNotice()
          : !usage.hasPermission
              ? _PermissionRequest(onGrant: () => usage.requestPermission())
              : RefreshIndicator(
                  onRefresh: usage.refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chalg'ituvchi ilovalar",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${usage.totalDistractingSeconds ~/ 60} / $limit daqiqa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: usage.totalDistractingSeconds >= limit * 60
                                      ? warnColor
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppProgressBar(
                                value: limit == 0
                                    ? 0
                                    : (usage.totalDistractingSeconds / 60) / limit,
                                color: usage.totalDistractingSeconds >= limit * 60
                                    ? warnColor
                                    : (isHightech
                                        ? AppColors.htElectricCyan
                                        : Theme.of(context).colorScheme.primary),
                                glow: isHightech,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Turkumlar boyicha', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...usage.secondsByCategory.entries.map((e) => Card(
                            child: ListTile(
                              title: Text(_categoryLabel(e.key)),
                              trailing: Text('${e.value ~/ 60} daq'),
                            ),
                          )),
                      const SizedBox(height: 16),
                      Text('Ilovalar', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...usage.todayUsage.map((u) => Card(
                            child: ListTile(
                              leading: Icon(
                                u.isDistracting ? Icons.warning_amber : Icons.check_circle,
                                color: u.isDistracting ? warnColor : Colors.green,
                              ),
                              title: Text(u.appName),
                              subtitle: Text(_categoryLabel(u.appCategory)),
                              trailing: Text('${u.timeSpentSeconds ~/ 60} daq'),
                            ),
                          )),
                    ],
                  ),
                ),
    );
  }
}

class _UnsupportedPlatformNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Ilova aktivligi tahlili hozircha faqat Android'da ishlaydi "
              "(UsageStatsManager orqali). iOS uchun Apple DeviceActivity "
              "kengaytmasi loyihaga alohida native modul sifatida qo'shilishi kerak "
              "(ios/DeviceActivityExtension papkasiga qarang).",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRequest extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionRequest({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Ilova aktivligini kuzatish uchun tizim sozlamalarida "
              '"Usage Access" ruxsatini bering.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onGrant, child: const Text('Ruxsat berish')),
          ],
        ),
      ),
    );
  }
}
