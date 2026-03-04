import 'package:json_annotation/json_annotation.dart';
part 'flagged_content_model.g.dart';

@JsonSerializable()
class FlaggedContentModel {
  final String id;
  final String type;   // product | reel | review
  final String title;
  final String reason;
  final String sellerId;
  final String? sellerName;
  final DateTime createdAt;

  const FlaggedContentModel({
    required this.id, required this.type, required this.title,
    required this.reason, required this.sellerId,
    this.sellerName, required this.createdAt,
  });

  factory FlaggedContentModel.fromJson(Map<String, dynamic> json) =>
    _\$FlaggedContentModelFromJson(json);
  Map<String, dynamic> toJson() => _\$FlaggedContentModelToJson(this);
}
