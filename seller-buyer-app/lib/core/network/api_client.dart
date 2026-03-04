import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/app_constants.dart';
import '../../data/models/user/user_model.dart';
import '../../data/models/product/product_model.dart';
import '../../data/models/order/order_model.dart';
import '../../data/models/seller/seller_model.dart';
import '../../data/models/chat/chat_model.dart';
import '../../data/models/chat/message_model.dart';
import '../../data/models/paginated_response.dart';

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

  @POST('/auth/refresh')
  Future<Map<String, dynamic>> refreshToken(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getMe();

  // Onboarding
  @PATCH('/users/me')
  Future<UserModel> updateProfile(@Body() Map<String, dynamic> body);

  // Seller registration
  @POST('/sellers/register')
  Future<Map<String, dynamic>> registerSeller(@Body() Map<String, dynamic> body);

  @GET('/sellers/:id')
  Future<SellerModel> getSeller(@Path('id') String id);

  // Feed & Products
  @GET('/feed')
  Future<PaginatedResponse<ProductModel>> getFeed({
    @Query('mode')   String mode  = 'discover',
    @Query('page')   int page     = 1,
    @Query('limit')  int limit    = 20,
    @Query('cat')    String? category,
  });

  @GET('/products')
  Future<PaginatedResponse<ProductModel>> getProducts({
    @Query('q')      String? query,
    @Query('cat')    String? category,
    @Query('page')   int page  = 1,
    @Query('limit')  int limit = 20,
    @Query('sort')   String sort = 'popular',
  });

  @GET('/products/:id')
  Future<ProductModel> getProduct(@Path('id') String id);

  @POST('/products')
  Future<ProductModel> createProduct(@Body() Map<String, dynamic> body);

  @PATCH('/products/:id')
  Future<ProductModel> updateProduct(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/products/:id')
  Future<void> deleteProduct(@Path('id') String id);

  // Orders
  @GET('/orders')
  Future<List<OrderModel>> getOrders({@Query('role') String role = 'buyer'});

  @GET('/orders/:id')
  Future<OrderModel> getOrder(@Path('id') String id);

  @POST('/orders')
  Future<OrderModel> createOrder(@Body() Map<String, dynamic> body);

  @PATCH('/orders/:id/status')
  Future<OrderModel> updateOrderStatus(@Path('id') String id, @Body() Map<String, dynamic> body);

  // Cart → Order
  @POST('/orders/from-cart')
  Future<OrderModel> checkoutCart(@Body() Map<String, dynamic> body);

  // Chats
  @GET('/chats')
  Future<List<ChatModel>> getChats();

  @GET('/chats/:id/messages')
  Future<List<MessageModel>> getMessages(@Path('id') String chatId, {
    @Query('before') String? before,
    @Query('limit')  int limit = 30,
  });

  @POST('/chats')
  Future<ChatModel> createChat(@Body() Map<String, dynamic> body);

  @POST('/chats/:id/messages')
  Future<MessageModel> sendMessage(@Path('id') String chatId, @Body() Map<String, dynamic> body);

  // Notifications
  @GET('/notifications')
  Future<List<Map<String, dynamic>>> getNotifications();

  @PATCH('/notifications/read-all')
  Future<void> markAllRead();

  // Seller dashboard
  @GET('/sellers/me/analytics')
  Future<Map<String, dynamic>> getAnalytics({@Query('period') String period = '7d'});

  @GET('/sellers/me/orders')
  Future<List<OrderModel>> getSellerOrders({@Query('status') String? status});

  // Admin
  @GET('/admin/dashboard')
  Future<Map<String, dynamic>> getDashboard();

  @GET('/admin/sellers/pending')
  Future<List<Map<String, dynamic>>> getPendingSellers();

  @POST('/admin/sellers/:id/verify')
  Future<void> verifySeller(@Path('id') String id, @Body() Map<String, dynamic> body);
}
