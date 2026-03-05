import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String   id;
  final String   chatId;
  final String   senderId;
  final String   type;
  final String?  content;
  final String?  mediaUrl;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id, required this.chatId, required this.senderId,
    required this.type, this.content, this.mediaUrl,
    required this.createdAt, this.readAt,
  });

  bool get isRead => readAt != null;

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id: j['id'], chatId: j['chatId'], senderId: j['senderId'],
    type: j['type'] ?? 'text', content: j['content'], mediaUrl: j['mediaUrl'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    readAt: j['readAt'] != null ? DateTime.tryParse(j['readAt']) : null,
  );

  @override List<Object?> get props => [id];
}
