
import 'package:flutter_test/flutter_test.dart';
import 'package:waqf/core/contracts/cms_payload_contracts.dart';

void main() {
  group('CmsPayloadContracts.newsArticles', () {
    test('strips unsupported attachment_url and defaults author', () {
      final result = CmsPayloadContracts.sanitizeTablePayload(
        'news_articles',
        {
          'title': '  Test title  ',
          'content': ' Body ',
          'attachment_url': 'https://example.com/file.pdf',
          'sort_order': 10,
          'author': '',
        },
      );

      expect(result.payload['title'], 'Test title');
      expect(result.payload['content'], 'Body');
      expect(result.payload['author'], CmsPayloadContracts.defaultAuthor);
      expect(result.payload.containsKey('attachment_url'), isFalse);
      expect(result.payload.containsKey('sort_order'), isFalse);
      expect(result.strippedFields, contains('attachment_url'));
      expect(result.strippedFields, contains('sort_order'));
      expect(result.defaultedFields, contains('author'));
    });

    test('requires title and content', () {
      expect(
        () => CmsPayloadContracts.sanitizeTablePayload(
          'news_articles',
          {'title': 'Only title'},
        ),
        throwsException,
      );
    });
  });

  group('CmsPayloadContracts.announcements', () {
    test('strips optional legacy-incompatible fields', () {
      final result = CmsPayloadContracts.sanitizeTablePayload(
        'announcements',
        {
          'title': 'Announcement',
          'content': 'Announcement body',
          'attachment_url': 'https://example.com/a.pdf',
          'image_url': 'https://example.com/img.jpg',
          'is_active': true,
        },
      );

      expect(result.payload['title'], 'Announcement');
      expect(result.payload['is_active'], true);
      expect(result.payload.containsKey('attachment_url'), isFalse);
      expect(result.payload.containsKey('image_url'), isFalse);
    });
  });
}
