import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class SocketService {
  late io.Socket _socket;
  bool _initialized = false;

  void connect() {
    if (_initialized) return;
    final token = Hive.box(AppConstants.tokenBox).get(AppConstants.accessTokenKey) as String? ?? '';
    _socket = io.io(AppConstants.wsUrl, io.OptionBuilder()
      .setTransports(['websocket']).setAuth({'token': token}).enableAutoConnect().build());
    _socket.onConnect((_) => print('Socket connected'));
    _socket.onDisconnect((_) => print('Socket disconnected'));
    _initialized = true;
  }

  void emit(String event, dynamic data) { if (_initialized) _socket.emit(event, data); }
  void on(String event, Function(dynamic) handler) { if (_initialized) _socket.on(event, handler); }
  void off(String event) { if (_initialized) _socket.off(event); }

  void sendLocation(String orderId, double lat, double lng, double bearing) =>
    emit('courier:location', {'orderId': orderId, 'lat': lat, 'lng': lng, 'bearing': bearing});

  void subscribeToOrder(String orderId) => emit('order:subscribe', orderId);
}
