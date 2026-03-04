import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String type; // text|image|audio|offer|system
  final String? content;
  final String? mediaUrl;
  final String? offerProductId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.offerProductId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
    _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  bool get isText  => type == 'text';
  bool get isImage => type == 'image';
  bool get isOffer => type == 'offer';

  @override
  List<Object?> get props => [id, createdAt];
}
