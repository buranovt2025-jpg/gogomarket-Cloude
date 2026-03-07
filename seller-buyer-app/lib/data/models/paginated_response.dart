class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.hasMore = false,
  });
}
