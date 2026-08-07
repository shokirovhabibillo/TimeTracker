import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import 'pdf_reader_screen.dart';

class ReadingHomeScreen extends StatefulWidget {
  const ReadingHomeScreen({super.key});

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen> {
  final _repository = BookRepository();
  List<BookEntry> _books = [];
  int _finishedCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _books = await _repository.getAllBooks();
    _finishedCount = await _repository.countFinishedBooks();
    setState(() => _loading = false);
  }

  Future<void> _pickAndOpen() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final path = result?.files.single.path;
    final name = result?.files.single.name;
    if (path == null || !mounted) return;
    final title = name?.replaceAll('.pdf', '') ?? "Nomsiz kitob";
    final id = await _repository.addOrUpdate(BookEntry(
      filePath: path,
      title: title,
      addedAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
    ));
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfReaderScreen(bookId: id, path: path)));
    _load();
  }

  Future<void> _openExisting(BookEntry book) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfReaderScreen(bookId: book.id!, path: book.filePath, initialPage: book.lastPage),
    ));
    _load();
  }

  Future<void> _delete(BookEntry book) async {
    await _repository.deleteBook(book.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("O'qish rejimi")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndOpen,
        icon: const Icon(Icons.upload_file),
        label: const Text('Yangi PDF'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: scheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Ko'zga qulay, e-ink uslubidagi o'qish rejimi. "
                          "O'qigan kitoblaringiz: $_finishedCount ta",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_books.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text("Hali kitob qo'shilmagan — pastdagi tugma orqali PDF tanlang.",
                        textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
                  )
                else ...[
                  Text('Kitoblarim', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._books.map((b) {
                    final progress = b.totalPages > 0 ? b.lastPage / b.totalPages : 0.0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(b.isFinished ? Icons.check_circle : Icons.picture_as_pdf,
                            color: b.isFinished ? Colors.green : scheme.primary),
                        title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: b.totalPages > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${b.lastPage} / ${b.totalPages} sahifa'),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(value: progress.clamp(0, 1)),
                                ],
                              )
                            : const Text("Hali ochilmagan"),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(b)),
                        onTap: () => _openExisting(b),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
