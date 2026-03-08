import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/socket_service.dart';
import '../../../data/models/courier_order_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class CourierEvent extends Equatable {
  @override List<Object?> get props => [];
}
class CourierLoadOrders    extends CourierEvent {}
class CourierToggleOnline  extends CourierEvent {}
class CourierAcceptOrder   extends CourierEvent {
  final String orderId; CourierAcceptOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}
class CourierNextStep      extends CourierEvent {}
class CourierLocationUpdated extends CourierEvent {
  final double lat; final double lng; final double bearing;
  CourierLocationUpdated({required this.lat, required this.lng, this.bearing = 0});
  @override List<Object?> get props => [lat, lng];
}

// ── State ─────────────────────────────────────────────────────────────────────
class CourierState extends Equatable {
  final bool isOnline;
  final List<CourierOrderModel> availableOrders;
  final CourierOrderModel? activeOrder;
  final int deliveryStep;   // 0=pickup, 1=transit, 2=delivered
  final double? currentLat;
  final double? currentLng;
  final bool isLoading;
  final String? error;

  const CourierState({
    this.isOnline = false,
    this.availableOrders = const [],
    this.activeOrder,
    this.deliveryStep = 0,
    this.currentLat,
    this.currentLng,
    this.isLoading = false,
    this.error,
  });

  CourierState copyWith({
    bool? isOnline, List<CourierOrderModel>? availableOrders,
    CourierOrderModel? activeOrder, int? deliveryStep,
    double? currentLat, double? currentLng,
    bool? isLoading, String? error, bool clearOrder = false,
  }) => CourierState(
    isOnline:        isOnline        ?? this.isOnline,
    availableOrders: availableOrders ?? this.availableOrders,
    activeOrder:     clearOrder ? null : (activeOrder ?? this.activeOrder),
    deliveryStep:    deliveryStep    ?? this.deliveryStep,
    currentLat:      currentLat      ?? this.currentLat,
    currentLng:      currentLng      ?? this.currentLng,
    isLoading:       isLoading       ?? this.isLoading,
    error:           error,
  );

  @override List<Object?> get props =>
    [isOnline, availableOrders.length, activeOrder?.id, deliveryStep, currentLat, currentLng];
}

class CourierBloc extends Bloc<CourierEvent, CourierState> {
  final ApiClient      _api;
  final SocketService  _socket;
  StreamSubscription<Position>? _gpsSub;

  CourierBloc(this._api, this._socket) : super(const CourierState()) {
    on<CourierLoadOrders>(_onLoad);
    on<CourierToggleOnline>(_onToggle);
    on<CourierAcceptOrder>(_onAccept);
    on<CourierNextStep>(_onNextStep);
    on<CourierLocationUpdated>(_onLocation);
  }

  Future<void> _onLoad(CourierLoadOrders e, Emitter<CourierState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders = await _api.getAvailableOrders();
      emit(state.copyWith(availableOrders: orders, isLoading: false));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString()));
    }
  }

  Future<void> _onToggle(CourierToggleOnline e, Emitter<CourierState> emit) async {
    final newOnline = !state.isOnline;
    emit(state.copyWith(isOnline: newOnline));
    await _api.updateOnlineStatus({'isOnline': newOnline});
    if (newOnline) {
      _startGps();
    } else {
      await _gpsSub?.cancel();
      _gpsSub = null;
    }
  }

  Future<void> _onAccept(CourierAcceptOrder e, Emitter<CourierState> emit) async {
    try {
      await _api.acceptOrder(e.orderId);
      final order = state.availableOrders.firstWhere((o) => o.id == e.orderId);
      _socket.subscribeToOrder(e.orderId);
      emit(state.copyWith(activeOrder: order, deliveryStep: 0,
        availableOrders: state.availableOrders.where((o) => o.id != e.orderId).toList()));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onNextStep(CourierNextStep e, Emitter<CourierState> emit) async {
    final next = state.deliveryStep + 1;
    if (state.activeOrder == null) return;
    await _api.updateDeliveryStep(state.activeOrder!.id, {'step': next});
    if (next >= 2) {
      emit(state.copyWith(deliveryStep: next));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(clearOrder: true, deliveryStep: 0));
    } else {
      emit(state.copyWith(deliveryStep: next));
    }
  }

  void _onLocation(CourierLocationUpdated e, Emitter<CourierState> emit) {
    emit(state.copyWith(currentLat: e.lat, currentLng: e.lng));
    if (state.activeOrder != null) {
      _socket.sendLocation(state.activeOrder!.id, e.lat, e.lng, e.bearing);
    }
  }

  void _startGps() {
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      add(CourierLocationUpdated(lat: pos.latitude, lng: pos.longitude, bearing: pos.heading));
    });
  }

  @override
  Future<void> close() {
    _gpsSub?.cancel();
    return super.close();
  }
}
