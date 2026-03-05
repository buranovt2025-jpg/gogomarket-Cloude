import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends Equatable {
  final String   id;
  final String   chatId;
  final String   senderId;
  final String   type;      // text | image | audio | offer
  final String?  content;
  final String?  mediaUrl;
  final String?  offerProductId;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.offerProductId,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _\$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _\$MessageModelToJson(this);

  @override
  List<Object?> get props => [id];
}
