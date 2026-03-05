import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String   id;
  final String   buyerId;
  final String   sellerId;
  final String?  lastMessage;
  final DateTime? lastMessageAt;
  final int      unreadCount;
  final DateTime createdAt;

  const ChatModel({
    required this.id, required this.buyerId, required this.sellerId,
    this.lastMessage, this.lastMessageAt,
    required this.unreadCount, required this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> j) => ChatModel(
    id: j['id'], buyerId: j['buyerId'], sellerId: j['sellerId'],
    lastMessage: j['lastMessage'],
    lastMessageAt: j['lastMessageAt'] != null ? DateTime.tryParse(j['lastMessageAt']) : null,
    unreadCount: j['buyerUnread'] ?? 0,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  @override List<Object?> get props => [id];
}
