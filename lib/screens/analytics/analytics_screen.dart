import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/app_usage_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../providers/settings_provider.dart';
import '../../providers/usage_provider.dart';
import '../../widgets/progress_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  int? _rolloverCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usage = context.read<UsageProvider>();
      await usage.checkPermission();
      if (usage.hasPermission) {
        await usage.refresh();
        final limit = context.read<SettingsProvider>().settings.dailyDistractionLimitMin;
        await usage.checkAndWarnIfOverLimit(limit);
      }
      final count = await _taskRepository.getTotalRolloverCount();
      if (mounted) setState(() => _rolloverCount = count);
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
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final scheme = Theme.of(context).colorScheme;
    final limit = settings.settings.dailyDistractionLimitMin;

    return Scaffold(
      appBar: AppBar(title: const Text('Diqqat tahlili')),
      body: Column(
        children: [
          if (_rolloverCount != null && _rolloverCount! > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _BentoCard(
                title: 'Kechiktirilgan vazifalar',
                child: Row(
                  children: [
                    Icon(Icons.history_toggle_off, color: scheme.secondary),
                    const SizedBox(width: 10),
                    Text('$_rolloverCount marta ko\'chirilgan',
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
            ),
          Expanded(
            child: !usage.isNativeSupported
                ? const _UnsupportedPlatformNotice()
                : !usage.hasPermission
                    ? _PermissionRequest(onGrant: () => usage.requestPermission())
                    : RefreshIndicator(
                        onRefresh: usage.refresh,
                        child: LayoutBuilder(builder: (context, constraints) {
                          final columns =
                              constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 420 ? 2 : 1);
                          return GridView(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.3,
                            ),
                            children: [
                              _BentoCard(
                                title: "Chalg'ituvchi ilovalar",
                                child: _DistractionSummary(usage: usage, limit: limit, extras: extras),
                              ),
                              ..._categoriesGrouped(usage).entries.map(
                                    (e) => _BentoCard(
                                      title: _categoryLabel(e.key),
                                      child: Center(
                                        child: Text('${e.value ~/ 60} daq',
                                            style: Theme.of(context).textTheme.headlineSmall),
                                      ),
                                    ),
                                  ),
                              _BentoCard(
                                title: 'Eng ko\'p ishlatilgan',
                                span: true,
                                child: Column(
                                  children: usage.todayUsage.take(6).map((u) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            u.isDistracting ? Icons.warning_amber : Icons.check_circle,
                                            size: 16,
                                            color: u.isDistracting ? extras.warningColor : Colors.green,
                                          ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(u.appName)),
                                    Text('${u.timeSpentSeconds ~/ 60} daq'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _categoriesGrouped(UsageProvider usage) => usage.secondsByCategory;
}

class _BentoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool span;
  const _BentoCard({required this.title, required this.child, this.span = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DistractionSummary extends StatelessWidget {
  final UsageProvider usage;
  final int limit;
  final AppThemeExtras extras;
  const _DistractionSummary({required this.usage, required this.limit, required this.extras});

  @override
  Widget build(BuildContext context) {
    final overLimit = usage.totalDistractingSeconds >= limit * 60;
    final color = overLimit ? extras.warningColor : Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${usage.totalDistractingSeconds ~/ 60} / $limit daq',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: overLimit ? color : null)),
        const SizedBox(height: 8),
        AppProgressBar(
          value: limit == 0 ? 0 : (usage.totalDistractingSeconds / 60) / limit,
          color: color,
          glow: extras.glowEnabled,
        ),
      ],
    );
  }
}

class _UnsupportedPlatformNotice extends StatelessWidget {
  const _UnsupportedPlatformNotice();

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
