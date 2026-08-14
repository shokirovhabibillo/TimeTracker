import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/patterned_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final settings = context.read<SettingsProvider>();
    final current = isStart ? settings.settings.sleepStartTime : settings.settings.sleepEndTime;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
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
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final neumorphic = extras.neumorphic;

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _SectionTitle("Ko'rinish turi"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('📱 Smartfon'),
                  selected: settings.settings.visualizationMode == 'smartphone',
                  onSelected: (_) => settings.setVisualizationMode('smartphone'),
                ),
                ChoiceChip(
                  label: const Text('⌚ Smartwatch'),
                  selected: settings.settings.visualizationMode == 'smartwatch',
                  onSelected: (_) => settings.setVisualizationMode('smartwatch'),
                ),
              ],
            ),
          ),
          if (settings.settings.visualizationMode == 'smartphone') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Tugma uslubi', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Oddiy'),
                    selected: settings.settings.buttonStyle == 'normal',
                    onSelected: (_) => settings.setButtonStyle('normal'),
                  ),
                  ChoiceChip(
                    label: const Text('Shaffof (Glass)'),
                    selected: settings.settings.buttonStyle == 'glass',
                    onSelected: (_) => settings.setButtonStyle('glass'),
                  ),
                  ChoiceChip(
                    label: const Text('Liquid Glass'),
                    selected: settings.settings.buttonStyle == 'liquid_glass',
                    onSelected: (_) => settings.setButtonStyle('liquid_glass'),
                  ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Smartwatch rejimida barcha funksiyalar bitta ekranda, erkin suriladigan "
                "doiralar sifatida ko'rinadi.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          const Divider(),
          _SectionTitle('Mavzu'),
          for (final group in AgeGroup.values) _ThemeGroupSection(group: group, neumorphic: neumorphic),
          const SizedBox(height: 8),
          const Divider(),
          _SectionTitle("Matn o'lchami"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.text_decrease, size: 18),
                Expanded(
                  child: Slider(
                    value: settings.settings.fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(settings.settings.fontScale * 100).round()}%',
                    onChanged: (v) => settings.setFontScale(v),
                  ),
                ),
                const Icon(Icons.text_increase, size: 22),
              ],
            ),
          ),
          const Divider(),
          _SectionTitle('Ko\'rinish variantlari'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Soat va taymer ko'rinishini tanlash endi Fokus ekranidagi 🎨 tugmasi orqali qilinadi.",
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ),
          _StyleRow(
            label: 'Kalendar',
            options: const {'timeline': 'Vaqt chizig\'i', 'list': 'Ro\'yxat'},
            value: settings.settings.calendarStyle,
            onChanged: settings.setCalendarStyle,
            neumorphic: neumorphic,
          ),
          const Divider(),
          _SectionTitle('Orqa fon naqshi'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BackgroundPatternType.values.map((p) {
              final selected = settings.settings.backgroundPattern == p.name;
              return ChoiceChip(
                label: Text(p.label),
                selected: selected,
                onSelected: (_) => settings.setBackgroundPattern(p.name),
              );
            }).toList(),
          ),
          const Divider(),
          _SectionTitle('Uyqu vaqti'),
          ListTile(
            title: const Text('Uyqu boshlanishi'),
            trailing: Text(settings.settings.sleepStartTime),
            onTap: () => _pickTime(context, true),
          ),
          ListTile(
            title: const Text("Uyg'onish vaqti"),
            trailing: Text(settings.settings.sleepEndTime),
            onTap: () => _pickTime(context, false),
          ),
          const Divider(),
          _SectionTitle('Diqqat tahlili'),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Collapsible group of theme options for one age band — e.g. all
/// "Yoshlar (13-25)" variants (Neon HUD / Cyberpunk / Gaming RGB).
class _ThemeGroupSection extends StatelessWidget {
  final AgeGroup group;
  final bool neumorphic;
  const _ThemeGroupSection({required this.group, required this.neumorphic});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final specs = AppTheme.all.where((t) => t.group == group).toList();
    if (specs.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(group.label),
        initiallyExpanded: specs.any((s) => s.id == settings.settings.themeType),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: specs.map((spec) {
          final selected = settings.settings.themeType == spec.id;
          final tile = ListTile(
            onTap: () => settings.setThemeId(spec.id),
            leading: CircleAvatar(backgroundColor: spec.data.colorScheme.primary, radius: 14),
            title: Text(spec.label),
            subtitle: Text(spec.description, style: const TextStyle(fontSize: 12)),
            trailing: selected ? const Icon(Icons.check_circle) : null,
          );
          if (!neumorphic) return tile;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: NeumorphicContainer(
              padding: EdgeInsets.zero,
              pressed: selected,
              child: tile,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A labeled row of choice-chips for a two-option style setting
/// (clock/timer/calendar variant).
class _StyleRow extends StatelessWidget {
  final String label;
  final Map<String, String> options; // id -> display label
  final String value;
  final ValueChanged<String> onChanged;
  final bool neumorphic;

  const _StyleRow({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.neumorphic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: options.entries.map((e) {
                final selected = value == e.key;
                if (neumorphic) {
                  return NeumorphicButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    onTap: () => onChanged(e.key),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  );
                }
                return ChoiceChip(
                  label: Text(e.value),
                  selected: selected,
                  onSelected: (_) => onChanged(e.key),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
