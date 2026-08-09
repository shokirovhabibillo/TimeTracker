import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/family_link_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/family_link_service.dart';

class ChildPairingScreen extends StatefulWidget {
  const ChildPairingScreen({super.key});

  @override
  State<ChildPairingScreen> createState() => _ChildPairingScreenState();
}

class _ChildPairingScreenState extends State<ChildPairingScreen> {
  String? _code;
  bool _linked = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateCode());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateCode() async {
    final settings = context.read<SettingsProvider>().settings;
    final code = await FamilyLinkService.instance.createPairingCode(
      childDeviceId: settings.deviceId,
      childName: settings.childDisplayName,
    );
    if (!mounted) return;
    setState(() => _code = code);
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkLinked());
  }

  Future<void> _checkLinked() async {
    if (_code == null) return;
    final linked = await FamilyLinkService.instance.isCodeLinked(_code!);
    if (linked && mounted) {
      setState(() => _linked = true);
      _pollTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Farzand rejimi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Rejimdan chiqish',
            onPressed: () => settings.setFamilyRole(DeviceRole.none),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_linked) ...[
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text("Ota-ona bilan bog'landi!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Endi kunlik rejangiz va bajarilishi avtomatik ravishda ota-ona "
                  "telefonida ko'rinib turadi.",
                  textAlign: TextAlign.center,
                ),
              ] else if (_code == null) ...[
                const CircularProgressIndicator(),
              ] else ...[
                const Text("Ota-ona telefonida shu kodni kiritsin:"),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _code!,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text("Bog'lanishi kutilmoqda...", style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
