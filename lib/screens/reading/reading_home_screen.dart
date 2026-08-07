import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'pdf_reader_screen.dart';

class ReadingHomeScreen extends StatelessWidget {
  const ReadingHomeScreen({super.key});

  Future<void> _pickAndOpen(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfReaderScreen(path: path)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("O'qish rejimi")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 56, color: scheme.primary),
              const SizedBox(height: 16),
              const Text(
                "Ko'zga qulay, e-ink uslubidagi (issiq rang, past yorug'lik) "
                "o'qish rejimida PDF kitob o'qing.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _pickAndOpen(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('PDF fayl tanlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
