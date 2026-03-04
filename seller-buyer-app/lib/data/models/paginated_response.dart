import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int     total;
  final int     page;
  final int     limit;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => items.length + (page - 1) * limit < total;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>).map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int,
      page:  json['page']  as int,
      limit: json['limit'] as int,
    );
  }
}
