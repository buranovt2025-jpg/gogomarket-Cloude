import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService instance = SocketService._();
  factory SocketService() => instance;
  SocketService._();

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  static const _wsUrl = 'http://206.189.12.56';

  void connect(String token) {
    if (isConnected) return;
    _socket = io.io(
      _wsUrl,
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .build(),
    );
    _socket!.onConnect((_) => debugPrint('🟢 Socket connected'));
    _socket!.onDisconnect((_) => debugPrint('🔴 Socket disconnected'));
    _socket!.onConnectError((e) => debugPrint('❌ Socket error: $e'));
  }

  void disconnect() { _socket?.disconnect(); _socket = null; }

  void joinChat(String chatId)   => _socket?.emit('chat:join', chatId);
  void leaveChat(String chatId)  => _socket?.emit('chat:leave', chatId);

  void sendMessage({required String chatId, required String content, String type = 'text'}) =>
    _socket?.emit('chat:message', {'chatId': chatId, 'type': type, 'content': content});

  void sendTyping(String chatId, bool isTyping) =>
    _socket?.emit('chat:typing', {'chatId': chatId, 'isTyping': isTyping});

  void on(String event, Function(dynamic) h) => _socket?.on(event, h);
  void off(String event)                      => _socket?.off(event);
  void subscribeOrder(String orderId)         => _socket?.emit('order:subscribe', orderId);
}
