import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel extends Equatable {
  final String   id;
  final String   buyerId;
  final String   sellerId;
  final String?  lastMessage;
  final DateTime? lastMessageAt;
  final int      unreadCount;
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => _\$ChatModelFromJson(json);
  Map<String, dynamic> toJson() => _\$ChatModelToJson(this);

  @override
  List<Object?> get props => [id];
}
