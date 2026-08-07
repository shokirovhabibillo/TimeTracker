class BookEntry {
  final int? id;
  final String filePath;
  final String title;
  final int lastPage;
  final int totalPages;
  final DateTime addedAt;
  final DateTime lastOpenedAt;

  BookEntry({
    this.id,
    required this.filePath,
    required this.title,
    this.lastPage = 1,
    this.totalPages = 0,
    required this.addedAt,
    required this.lastOpenedAt,
  });

  bool get isFinished => totalPages > 0 && lastPage >= totalPages;

  BookEntry copyWith({int? lastPage, int? totalPages, DateTime? lastOpenedAt}) {
    return BookEntry(
      id: id,
      filePath: filePath,
      title: title,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
      addedAt: addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'file_path': filePath,
        'title': title,
        'last_page': lastPage,
        'total_pages': totalPages,
        'added_at': addedAt.toIso8601String(),
        'last_opened_at': lastOpenedAt.toIso8601String(),
      };

  factory BookEntry.fromMap(Map<String, dynamic> map) => BookEntry(
        id: map['id'] as int?,
        filePath: map['file_path'] as String,
        title: map['title'] as String,
        lastPage: map['last_page'] as int? ?? 1,
        totalPages: map['total_pages'] as int? ?? 0,
        addedAt: DateTime.parse(map['added_at'] as String),
        lastOpenedAt: DateTime.parse(map['last_opened_at'] as String),
      );
}
