class FridaySermon {
  final String id;
  final String titleAr;
  final String? titleEn;
  final DateTime sermonDate;
  final String? speakerName;
  final String? mosqueName;
  final String? summaryAr;
  final String? summaryEn;
  final String? contentAr;
  final String? contentEn;
  final String? audioUrl;
  final String? pdfUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FridaySermon({
    required this.id,
    required this.titleAr,
    this.titleEn,
    required this.sermonDate,
    this.speakerName,
    this.mosqueName,
    this.summaryAr,
    this.summaryEn,
    this.contentAr,
    this.contentEn,
    this.audioUrl,
    this.pdfUrl,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FridaySermon.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return FridaySermon(
      id: (map['id'] ?? '').toString(),
      titleAr: (map['title_ar'] ?? '').toString(),
      titleEn: map['title_en']?.toString(),
      sermonDate: parseDate(map['sermon_date']),
      speakerName: map['speaker_name']?.toString(),
      mosqueName: map['mosque_name']?.toString(),
      summaryAr: map['summary_ar']?.toString(),
      summaryEn: map['summary_en']?.toString(),
      contentAr: map['content_ar']?.toString(),
      contentEn: map['content_en']?.toString(),
      audioUrl: map['audio_url']?.toString(),
      pdfUrl: map['pdf_url']?.toString(),
      isPublished: map['is_published'] == true,
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title_ar': titleAr,
      'title_en': titleEn,
      'sermon_date': sermonDate.toIso8601String().substring(0, 10),
      'speaker_name': speakerName,
      'mosque_name': mosqueName,
      'summary_ar': summaryAr,
      'summary_en': summaryEn,
      'content_ar': contentAr,
      'content_en': contentEn,
      'audio_url': audioUrl,
      'pdf_url': pdfUrl,
      'is_published': isPublished,
    }..removeWhere((k, v) => v == null);
  }
}
