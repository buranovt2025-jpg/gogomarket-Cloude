class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
}
