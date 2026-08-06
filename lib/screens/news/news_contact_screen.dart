import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/admin_config_model.dart';
import '../../services/remote_config_service.dart';

class NewsContactScreen extends StatefulWidget {
  const NewsContactScreen({super.key});

  @override
  State<NewsContactScreen> createState() => _NewsContactScreenState();
}

class _NewsContactScreenState extends State<NewsContactScreen> {
  final _service = RemoteConfigService();
  AdminConfig? _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final config = await _service.fetch();
    if (mounted) setState(() {
      _config = config;
      _loading = false;
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangiliklar va aloqa'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (config?.promoBannerText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(config!.promoBannerText!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Yangiliklar', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (config == null || config.announcements.isEmpty)
                    const Text('Hozircha yangiliklar yo\'q.')
                  else
                    ...config.announcements.map((a) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (a.date != null)
                                  Text(a.date!,
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                                const SizedBox(height: 6),
                                Text(a.body),
                              ],
                            ),
                          ),
                        )),
                  const SizedBox(height: 20),
                  if (config != null && config.apps.isNotEmpty) ...[
                    Text('Boshqa ilovalarimiz', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...config.apps.map((app) => Card(
                          child: ListTile(
                            leading: app.iconUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(app.iconUrl!, width: 44, height: 44,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.apps)),
                                  )
                                : const Icon(Icons.apps),
                            title: Text(app.name),
                            subtitle: Text(app.description),
                            trailing: const Icon(Icons.open_in_new, size: 18),
                            onTap: () => _open(app.url),
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (config != null && config.contacts.isNotEmpty) ...[
                    Text('Biz bilan bog\'lanish', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: config.contacts
                          .map((c) => ActionChip(
                                avatar: const Icon(Icons.link, size: 16),
                                label: Text(c.label),
                                onPressed: () => _open(c.url),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
