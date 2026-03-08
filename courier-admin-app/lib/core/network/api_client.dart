import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/courier_order_model.dart';
import '../../data/models/admin/seller_pending_model.dart';
import '../../data/models/admin/flagged_content_model.dart';
import '../../data/models/admin/admin_order_model.dart';

@singleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<void> sendOtp(Map<String, dynamic> body) =>
    _dio.post('/auth/send-otp', data: body);

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> body) async {
    final res = await _dio.post('/auth/verify-otp', data: body);
    return Map<String, dynamic>.from(res.data);
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/auth/me');
    return UserModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  // ── Courier ───────────────────────────────────────────────────────────────
  Future<List<CourierOrderModel>> getAvailableOrders() async {
    final res = await _dio.get('/courier/orders/available');
    final list = res.data['items'] as List? ?? [];
    return list.map((e) => CourierOrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<CourierOrderModel>> getMyDeliveries() async {
    final res = await _dio.get('/courier/orders/mine');
    final list = res.data['items'] as List? ?? [];
    return list.map((e) => CourierOrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> acceptOrder(String orderId) =>
    _dio.post('/courier/orders/$orderId/accept');

  Future<void> updateOrderStatus(String orderId, String status) =>
    _dio.patch('/courier/orders/$orderId/status', data: {'status': status});

  Future<void> updateLocation(double lat, double lng) =>
    _dio.post('/courier/location', data: {'lat': lat, 'lng': lng});

  // ── Admin ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get('/admin/dashboard');
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<SellerPendingModel>> getPendingSellers() async {
    final res = await _dio.get('/admin/sellers/pending');
    final list = res.data as List? ?? [];
    return list.map((e) => SellerPendingModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> verifySeller(String id, Map<String, dynamic> body) =>
    _dio.post('/admin/sellers/$id/verify', data: body);

  Future<List<FlaggedContentModel>> getFlaggedContent() async {
    final res = await _dio.get('/admin/content/flagged');
    final list = res.data as List? ?? [];
    return list.map((e) => FlaggedContentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> moderateContent(String id, Map<String, dynamic> body) =>
    _dio.patch('/admin/products/$id/moderate', data: body);

  Future<List<AdminOrderModel>> getAdminOrders({String? status}) async {
    final res = await _dio.get('/admin/orders',
      queryParameters: status != null ? {'status': status} : null);
    final list = res.data as List? ?? [];
    return list.map((e) => AdminOrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Map<String, dynamic>> getUsers() async {
    final res = await _dio.get('/admin/users');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getFinance() async {
    final res = await _dio.get('/admin/finance');
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> approveWithdrawal(String id) =>
    _dio.post('/admin/withdrawals/$id/approve');
}
