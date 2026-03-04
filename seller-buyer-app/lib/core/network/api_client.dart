import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/app_constants.dart';
import '../../data/models/user/user_model.dart';
import '../../data/models/product/product_model.dart';
import '../../data/models/order/order_model.dart';
import '../../data/models/chat/chat_model.dart';
import '../../data/models/chat/message_model.dart';
import '../../data/models/seller/seller_model.dart';
import '../../data/models/paginated_response.dart';

part 'api_client.g.dart';

@singleton
@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiClient {
  @factoryMethod
  factory ApiClient(Dio dio) = _ApiClient;

  // ── Auth ────────────────────────────────────────────────────
  @POST('/auth/send-otp')
  Future<void> sendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-otp')
  Future<Map<String, dynamic>> verifyOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/refresh')
  Future<Map<String, dynamic>> refreshToken(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getMe();

  // ── Products ─────────────────────────────────────────────────
  @GET('/products')
  Future<PaginatedResponse<ProductModel>> getProducts({
    @Query('page')      int page = 1,
    @Query('limit')     int limit = 20,
    @Query('q')         String? query,
    @Query('category')  String? categoryId,
    @Query('seller_id') String? sellerId,
    @Query('price_min') int? priceMin,
    @Query('price_max') int? priceMax,
    @Query('sort')      String sort = 'popular',
  });

  @GET('/products/{id}')
  Future<ProductModel> getProduct(@Path('id') String id);

  @POST('/products')
  Future<ProductModel> createProduct(@Body() Map<String, dynamic> body);

  @PATCH('/products/{id}')
  Future<ProductModel> updateProduct(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/products/{id}')
  Future<void> deleteProduct(@Path('id') String id);

  // ── Orders ───────────────────────────────────────────────────
  @POST('/orders')
  Future<OrderModel> createOrder(@Body() Map<String, dynamic> body);

  @GET('/orders')
  Future<PaginatedResponse<OrderModel>> getOrders({
    @Query('page')   int page = 1,
    @Query('limit')  int limit = 20,
    @Query('status') String? status,
  });

  @GET('/orders/{id}')
  Future<OrderModel> getOrder(@Path('id') String id);

  @PATCH('/orders/{id}/status')
  Future<OrderModel> updateOrderStatus(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  // ── Chats ────────────────────────────────────────────────────
  @GET('/chats')
  Future<List<ChatModel>> getChats();

  @POST('/chats')
  Future<ChatModel> createChat(@Body() Map<String, dynamic> body);

  @GET('/chats/{id}/messages')
  Future<List<MessageModel>> getMessages(
    @Path('id') String chatId, {
    @Query('limit') int limit = 30,
    @Query('before') String? before,
  });

  // ── Sellers ──────────────────────────────────────────────────
  @GET('/sellers/{id}')
  Future<SellerModel> getSeller(@Path('id') String id);

  @GET('/sellers/me/dashboard')
  Future<Map<String, dynamic>> getSellerDashboard();

  @PATCH('/sellers/me')
  Future<SellerModel> updateSeller(@Body() Map<String, dynamic> body);

  @POST('/sellers/register')
  Future<SellerModel> registerSeller(@Body() Map<String, dynamic> body);

  // ── Notifications ────────────────────────────────────────────
  @GET('/notifications')
  Future<List<Map<String, dynamic>>> getNotifications({
    @Query('page') int page = 1,
  });

  @PATCH('/notifications/{id}/read')
  Future<void> markRead(@Path('id') String id);

  @PATCH('/notifications/read-all')
  Future<void> markAllRead();
}
