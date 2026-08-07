import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../data/repositories/book_repository.dart';

class PdfReaderScreen extends StatefulWidget {
  final int bookId;
  final String path;
  final int initialPage;
  const PdfReaderScreen({super.key, required this.bookId, required this.path, this.initialPage = 1});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _repository = BookRepository();
  late final PdfController _controller;
  double _warmth = 0.35; // 0 = neutral, 1 = strong sepia (e-ink-like warmth)
  double _brightness = 0.9; // dims the screen slightly, like an e-reader
  late int _currentPage;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PdfController(document: PdfDocument.openFile(widget.path), initialPage: widget.initialPage);
  }

  Future<void> _saveProgress() async {
    await _repository.updateProgress(widget.bookId, lastPage: _currentPage, totalPages: _pageCount);
  }

  @override
  void dispose() {
    _saveProgress();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A warm sepia overlay simulates the low-blue-light, paper-like
    // feel of e-ink readers — reduces eye strain during long reading.
    final sepia = Color.lerp(Colors.transparent, const Color(0xFFF4E8CF), _warmth)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EC),
      appBar: AppBar(
        title: Text(_pageCount > 0 ? 'Sahifa $_currentPage / $_pageCount' : 'PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => _showAdjustSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: _brightness,
            child: PdfView(
              controller: _controller,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _saveProgress();
              },
              onDocumentLoaded: (doc) {
                setState(() => _pageCount = doc.pagesCount);
                _saveProgress();
              },
            ),
          ),
          IgnorePointer(
            child: Container(color: sepia.withOpacity(0.35 * _warmth + 0.05)),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.ease),
            ),
            Text('$_currentPage / $_pageCount'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.ease),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("O'qish qulayligi", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 18),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      min: 0.4,
                      max: 1.0,
                      onChanged: (v) {
                        setState(() => _brightness = v);
                        setSheetState(() {});
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_outlined, size: 18),
                  Expanded(
                    child: Slider(
                      value: _warmth,
                      min: 0,
                      max: 1,
                      onChanged: (v) {
                        setState(() => _warmth = v);
                        setSheetState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
