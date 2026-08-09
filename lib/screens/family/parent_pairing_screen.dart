import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/family_link_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/family_link_service.dart';

class ParentPairingScreen extends StatefulWidget {
  const ParentPairingScreen({super.key});

  @override
  State<ParentPairingScreen> createState() => _ParentPairingScreenState();
}

class _ParentPairingScreenState extends State<ParentPairingScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _link() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final settings = context.read<SettingsProvider>();
    final childDeviceId = await FamilyLinkService.instance.linkWithCode(
      code,
      parentDeviceId: settings.settings.deviceId,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (childDeviceId == null) {
      setState(() => _error = "Kod topilmadi yoki allaqachon ishlatilgan. Qayta tekshiring.");
      return;
    }
    await settings.setFamilyRole(DeviceRole.parent);
    await settings.setLinkedChild(childDeviceId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kodni kiriting')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Farzandingiz telefonida ko'rsatilgan 8 xonali kodni kiriting:"),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'ABCD1234'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _link,
              child: _loading ? const CircularProgressIndicator() : const Text("Bog'lash"),
            ),
          ],
        ),
      ),
    );
  }
}
