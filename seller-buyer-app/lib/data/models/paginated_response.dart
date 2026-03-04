import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int? total;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.limit,
    this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T val) toJsonT) =>
    _$PaginatedResponseToJson(this, toJsonT);
}
