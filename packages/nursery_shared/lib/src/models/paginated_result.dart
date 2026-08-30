/// One page of a server-paginated list.
///
/// Repositories return this even while backed by in-memory fakes, so cubit
/// search and pagination logic is already correct when the real API lands.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  const PaginatedResult.empty()
      : items = const [],
        total = 0,
        page = 1,
        pageSize = 20;

  final List<T> items;

  /// Total matching rows on the server, not the length of [items].
  final int total;
  final int page;
  final int pageSize;

  int get totalPages =>
      total <= 0 || pageSize <= 0 ? 1 : (total / pageSize).ceil();
  bool get isEmpty => items.isEmpty;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    final pageSize = json['page_size'] as int? ?? 20;
    return PaginatedResult<T>(
      items: rawItems
          .map((e) => parseItem(e as Map<String, dynamic>))
          .toList(growable: false),
      total: json['total'] as int? ?? rawItems.length,
      page: json['page'] as int? ?? 1,
      pageSize: pageSize,
    );
  }
}
