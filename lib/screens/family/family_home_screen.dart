import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/supabase_config.dart';
import '../../data/models/family_link_model.dart';
import '../../providers/settings_provider.dart';
import 'child_pairing_screen.dart';
import 'parent_dashboard_screen.dart';
import 'parent_pairing_screen.dart';

class FamilyHomeScreen extends StatelessWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ota-ona / Farzand')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 16),
                const Text(
                  "Bu funksiya hali sozlanmagan — dasturchi tomonidan Supabase "
                  "ulanishi kiritilishi kerak.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final settings = context.watch<SettingsProvider>();
    final role = settings.settings.familyRole;

    if (role == DeviceRole.parent) return const ParentDashboardScreen();
    if (role == DeviceRole.child) return const ChildPairingScreen();

    return Scaffold(
      appBar: AppBar(title: const Text('Ota-ona / Farzand')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Farzandning kunlik rejasi va bajarilishini ota-ona telefonida "
              "ko'rish uchun, avval qaysi tomon ekanligingizni tanlang.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => settings.setFamilyRole(DeviceRole.child),
              icon: const Icon(Icons.child_care),
              label: const Text("Men — Farzandman"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(240, 48)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ParentPairingScreen()),
              ),
              icon: const Icon(Icons.supervisor_account),
              label: const Text("Men — Ota-onaman"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(240, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
