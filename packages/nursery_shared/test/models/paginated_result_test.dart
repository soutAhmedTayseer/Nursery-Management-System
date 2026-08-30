import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  group('PaginatedResult', () {
    test('computes total pages, rounding up', () {
      const result = PaginatedResult<int>(
        items: [1, 2, 3],
        total: 25,
        page: 1,
        pageSize: 8,
      );
      expect(result.totalPages, 4);
    });

    test('reports at least one page when there are no items', () {
      const result = PaginatedResult<int>(
        items: [],
        total: 0,
        page: 1,
        pageSize: 8,
      );
      expect(result.totalPages, 1);
      expect(result.isEmpty, isTrue);
    });

    test('guards against a non-positive pageSize instead of throwing', () {
      const result = PaginatedResult<int>(
        items: [1, 2, 3],
        total: 25,
        page: 1,
        pageSize: 0,
      );
      expect(result.totalPages, 1);
    });

    test('parses the wire envelope with an item parser', () {
      final result = PaginatedResult.fromJson(
        const {
          'items': [
            {'id': 'a'},
            {'id': 'b'},
          ],
          'total': 2,
          'page': 1,
          'page_size': 20,
        },
        (json) => json['id'] as String,
      );
      expect(result.items, ['a', 'b']);
      expect(result.total, 2);
      expect(result.pageSize, 20);
    });

    test('empty() is a usable initial value', () {
      const result = PaginatedResult<String>.empty();
      expect(result.items, isEmpty);
      expect(result.total, 0);
      expect(result.page, 1);
    });
  });
}
