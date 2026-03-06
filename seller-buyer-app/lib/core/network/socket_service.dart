
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

typedef MessageHandler = void Function(Map<String, dynamic> data);


class SocketService {
  io.Socket? _socket;
  final Map<String, List<MessageHandler>> _handlers = {};

  void connect() {
    final token = Hive.box(AppConstants.tokenBox).get(AppConstants.accessTokenKey);
    if (token == null) return;

    _socket = io.io(AppConstants.wsUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .enableReconnection()
      .build(),
    );

    _socket!.onConnect((_)    => print('[Socket] Connected'));
    _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
    _socket!.onError((e)      => print('[Socket] Error: \$e'));

    _socket!.onAny((event, data) {
      final handlers = _handlers[event];
      if (handlers != null && data is Map) {
        for (final h in handlers) h(Map<String, dynamic>.from(data));
      }
    });
  }

  void disconnect() => _socket?.disconnect();

  void on(String event, MessageHandler handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
  }

  void off(String event, MessageHandler handler) {
    _handlers[event]?.remove(handler);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void joinChat(String chatId)  => emit('join_chat',  {'chatId': chatId});
  void leaveChat(String chatId) => emit('leave_chat', {'chatId': chatId});

  void sendMessage(String chatId, String content, {String type = 'text'}) {
    emit('send_message', {'chatId': chatId, 'content': content, 'type': type});
  }

  bool get isConnected => _socket?.connected ?? false;
}
