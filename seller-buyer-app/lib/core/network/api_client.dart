import 'package:dio/dio.dart';

import '../../data/models/user/user_model.dart';
import '../../data/models/product/product_model.dart';
import '../../data/models/paginated_response.dart';

class ApiClient {
  final Dio _dio;
  ApiClient(this._dio);

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<void> sendOtp(String phone) async {
    await _dio.post('/auth/send-otp', data: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone, required String code,
    String? role, String? name,
  }) async {
    final res = await _dio.post('/auth/verify-otp', data: {
      'phone': phone, 'code': code,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    return Map<String, dynamic>.from(res.data);
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/auth/me');
    return UserModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Map<String, dynamic>> upgradeTier({
    required int tier,
    String? shopName,
  }) async {
    final res = await _dio.post('/auth/upgrade-tier', data: {
      'tier': tier,
      if (shopName != null) 'shopName': shopName,
    });
    return Map<String, dynamic>.from(res.data);
  }

  // ── Feed ──────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<ProductModel>> getFeed({
    String mode = 'discover', int page = 1, int limit = 20, String? categoryId,
    int cursor = 0,
  }) async {
    final res = await _dio.get('/feed', queryParameters: {
      'cursor': cursor, 'limit': limit,
      if (categoryId != null) 'cat': categoryId,
    });
    final data = Map<String, dynamic>.from(res.data);
    final rawItems = data['items'] as List? ?? [];
    // Filter only product-type items for now (skip reels in product list)
    final productItems = rawItems
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((e) => e['type'] == 'product' || e['type'] == null)
        .map((e) => ProductModel.fromJson(e))
        .toList();
    return PaginatedResponse<ProductModel>(
      items:   productItems,
      total:   data['total'] as int? ?? productItems.length,
      page:    page,
      limit:   limit,
      hasMore: data['nextCursor'] != null,
    );
  }

  // ── Products ──────────────────────────────────────────────────────────────
  Future<ProductModel> getProduct(String id) async {
    final res = await _dio.get('/products/$id');
    return ProductModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<PaginatedResponse<ProductModel>> getProducts({
    String? sellerId, String? categoryId, int page = 1, int limit = 20,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      'page': page, 'limit': limit,
      if (sellerId != null)    'sellerId': sellerId,
      if (categoryId != null)  'categoryId': categoryId,
    });
    final data = Map<String, dynamic>.from(res.data);
    return PaginatedResponse<ProductModel>(
      items: (data['items'] as List).map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      total: data['total'] as int,
      page:  data['page']  as int,
      limit: data['limit'] as int,
    );
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    final res = await _dio.post('/orders', data: body);
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> getOrders({String? status}) async {
    final res = await _dio.get('/orders', queryParameters: {
      if (status != null) 'status': status,
    });
    return res.data['items'] as List;
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    final res = await _dio.get('/orders/$id');
    return Map<String, dynamic>.from(res.data);
  }

  // ── Chats ─────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getChats() async {
    final res = await _dio.get('/chats');
    return res.data as List;
  }

  Future<Map<String, dynamic>> createChat(String sellerId) async {
    final res = await _dio.post('/chats', data: {'sellerId': sellerId});
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> getMessages(String chatId) async {
    final res = await _dio.get('/chats/$chatId/messages');
    return res.data as List;
  }

  Future<Map<String, dynamic>> sendMessage(String chatId, String content, {String type = 'text'}) async {
    final res = await _dio.post('/chats/$chatId/messages', data: {'content': content, 'type': type});
    return Map<String, dynamic>.from(res.data);
  }

  // ── Sellers ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getSeller(String id) async {
    final res = await _dio.get('/sellers/$id');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> registerSeller(Map<String, dynamic> data) async {
    final res = await _dio.post('/sellers', data: data);
    return Map<String, dynamic>.from(res.data);
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  Future<List<dynamic>> getNotifications() async {
    final res = await _dio.get('/notifications');
    return res.data as List;
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }

  // ── Upload ────────────────────────────────────────────────────────────────
  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/upload/image', data: formData);
    return res.data['url'] as String;
  }

  // ── Payments ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String provider,
  }) async {
    final res = await _dio.post('/payments/initiate', data: {
      'orderId': orderId,
      'provider': provider,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<String> getPaymentStatus(String orderId) async {
    final res = await _dio.get('/payments/status/$orderId');
    return res.data['status'] as String? ?? 'unknown';
  }


  // ── Chats ─────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getChatMessages(String chatId, {int limit = 50}) async {
    final res = await _dio.get('/chats/$chatId/messages', queryParameters: {'limit': limit});
    return res.data['items'] as List? ?? [];
  }


  Future<void> saveFcmToken(String token) async {
    await _dio.post('/push/token', data: {'token': token});
  }

  // ── Verification ──────────────────────────────────────────────────────────
  Future<void> submitVerification({
    required String inn,
    required String fullName,
    required dynamic passportFront,
    required dynamic passportBack,
    required dynamic selfie,
  }) async {
    final formData = FormData.fromMap({
      'inn':      inn,
      'fullName': fullName,
      'passportFront': await MultipartFile.fromFile(passportFront.path, filename: 'passport_front.jpg'),
      'passportBack':  await MultipartFile.fromFile(passportBack.path,  filename: 'passport_back.jpg'),
      'selfie':        await MultipartFile.fromFile(selfie.path,         filename: 'selfie.jpg'),
    });
    await _dio.post('/sellers/verification', data: formData);
  }


  Future<List<dynamic>> getMyOrders() async {
    final res = await _dio.get('/orders');
    return res.data['items'] as List? ?? [];
  }

  Future<Map<String,dynamic>> getOrderDetail(String orderId) async {
    final res = await _dio.get('/orders/$orderId');
    return Map<String,dynamic>.from(res.data);
  }


  Future<Map<String,dynamic>> getSellerAnalytics({int days = 7}) async {
    final res = await _dio.get('/sellers/analytics', queryParameters: {'days': days});
    return Map<String,dynamic>.from(res.data);
  }


  Future<String> uploadVideo(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'reel.mp4'),
    });
    final res = await _dio.post('/upload/video', data: formData,
      options: Options(sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2)));
    return res.data['url'] as String;
  }

  Future<void> createReel({
    required String videoUrl,
    String? thumbUrl,
    required String title,
    String? productId,
  }) async {
    await _dio.post('/reels', data: {
      'videoUrl':  videoUrl,
      if (thumbUrl != null) 'thumbUrl': thumbUrl,
      'title':     title,
      if (productId != null) 'productId': productId,
    });
  }

}
