import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/courier_order_model.dart';
import '../../data/models/admin/seller_pending_model.dart';
import '../../data/models/admin/flagged_content_model.dart';
import '../../data/models/admin/admin_order_model.dart';

part 'api_client.g.dart';

@singleton
@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(Dio dio) = _ApiClient;

  // Auth
  @POST('/auth/send-otp')
  Future<void> sendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-otp')
  Future<Map<String, dynamic>> verifyOtp(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getMe();

  // Courier
  @GET('/courier/orders/available')
  Future<List<CourierOrderModel>> getAvailableOrders();

  @POST('/courier/orders/:id/accept')
  Future<void> acceptOrder(@Path('id') String orderId);

  @POST('/courier/orders/:id/step')
  Future<void> updateDeliveryStep(@Path('id') String orderId, @Body() Map<String, dynamic> body);

  @GET('/courier/earnings')
  Future<Map<String, dynamic>> getEarnings();

  @PATCH('/courier/status')
  Future<void> updateOnlineStatus(@Body() Map<String, dynamic> body);

  // Admin
  @GET('/admin/dashboard')
  Future<Map<String, dynamic>> getDashboard();

  @GET('/admin/sellers/pending')
  Future<List<SellerPendingModel>> getPendingSellers();

  @POST('/admin/sellers/:id/verify')
  Future<void> verifySeller(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET('/admin/content/flagged')
  Future<List<FlaggedContentModel>> getFlaggedContent();

  @PATCH('/admin/products/:id/moderate')
  Future<void> moderateContent(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET('/admin/orders')
  Future<List<AdminOrderModel>> getAdminOrders({@Query('status') String? status});

  @GET('/admin/users')
  Future<Map<String, dynamic>> getUsers();

  @GET('/admin/finance')
  Future<Map<String, dynamic>> getFinance();

  @POST('/admin/finance/approve/:id')
  Future<void> approveWithdrawal(@Path('id') String id);
}
