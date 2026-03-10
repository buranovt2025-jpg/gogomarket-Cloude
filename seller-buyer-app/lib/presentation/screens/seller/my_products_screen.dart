import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final data = await api.getSellerProducts();
      final items = (data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (mounted) setState(() { _products = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _renew(String id) async {
    HapticFeedback.mediumImpact();
    try {
      final api = getIt<ApiClient>();
      await api.renewListing(listingType: 'product', listingId: id);
      HapticFeedback.heavyImpact();
      // Update local state
      setState(() {
        final idx = _products.indexWhere((p) => p['id'] == id);
        if (idx != -1) {
          final newExpiry = DateTime.now().add(const Duration(days: 7));
          _products[idx] = {
            ..._products[idx],
            'expiresAt': newExpiry.toIso8601String(),
            'daysLeft': 7,
            'canRenew': false,
          };
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('✅ Продлено на 7 дней'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  List<Map<String, dynamic>> get _activeProducts =>
      _products.where((p) => p['status'] == 'active').toList();

  List<Map<String, dynamic>> get _expiringProducts =>
      _products.where((p) => (p['canRenew'] as bool? ?? false)).toList();

  List<Map<String, dynamic>> get _draftProducts =>
      _products.where((p) => p['status'] == 'draft').toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
            elevation: 0,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ),
            title: Text('Мои товары',
              style: TextStyle(
                fontSize: 17.sp, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: _load,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Icon(Icons.refresh_rounded,
                    size: 22.sp,
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.5)),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              indicatorWeight: 2.5,
              labelColor: AppColors.accent,
              unselectedLabelColor: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.4),
              labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'Активные (${_activeProducts.length})'),
                Tab(text: '⏰ Истекают (${_expiringProducts.length})'),
                Tab(text: 'Черновики (${_draftProducts.length})'),
              ],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _error != null
                ? _ErrorView(onRetry: _load)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _ProductList(
                        products: _activeProducts,
                        isDark: isDark,
                        onRenew: _renew,
                        emptyMessage: 'Нет активных товаров',
                        emptyEmoji: '📦',
                      ),
                      _ProductList(
                        products: _expiringProducts,
                        isDark: isDark,
                        onRenew: _renew,
                        emptyMessage: 'Нет истекающих товаров 🎉',
                        emptyEmoji: '✅',
                        highlightExpiry: true,
                      ),
                      _ProductList(
                        products: _draftProducts,
                        isDark: isDark,
                        onRenew: _renew,
                        emptyMessage: 'Нет черновиков',
                        emptyEmoji: '📝',
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addProduct),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Добавить товар',
          style: TextStyle(
            color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Product List ──────────────────────────────────────────────────────────────
class _ProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final bool isDark;
  final Future<void> Function(String) onRenew;
  final String emptyMessage, emptyEmoji;
  final bool highlightExpiry;

  const _ProductList({
    required this.products,
    required this.isDark,
    required this.onRenew,
    required this.emptyMessage,
    required this.emptyEmoji,
    this.highlightExpiry = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emptyEmoji, style: TextStyle(fontSize: 48.sp)),
        SizedBox(height: 12.h),
        Text(emptyMessage, style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
        )),
      ]));
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        isDark: isDark,
        onRenew: onRenew,
        highlightExpiry: highlightExpiry,
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isDark, highlightExpiry;
  final Future<void> Function(String) onRenew;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.onRenew,
    required this.highlightExpiry,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _renewing = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = widget.isDark;
    final daysLeft = p['daysLeft'] as int?;
    final canRenew = p['canRenew'] as bool? ?? false;
    final hasExpiry = daysLeft != null;

    Color expiryColor = AppColors.textMuted;
    if (daysLeft != null) {
      if (daysLeft == 0) expiryColor = AppColors.red;
      else if (daysLeft <= 1) expiryColor = AppColors.red;
      else if (daysLeft <= 3) expiryColor = AppColors.orange;
      else expiryColor = AppColors.green;
    }

    final priceTiyin = (p['priceTiyin'] as num?)?.toInt() ?? 0;
    final priceStr = '${(priceTiyin / 100).toStringAsFixed(0)} сум';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: canRenew
              ? AppColors.orange.withOpacity(0.4)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
          width: canRenew ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Thumbnail
          Container(
            width: 64.w, height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(child: Text('📦', style: TextStyle(fontSize: 28.sp))),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              p['title'] as String? ?? 'Без названия',
              style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(priceStr, style: TextStyle(
              fontSize: 13.sp, fontWeight: FontWeight.w600,
              color: AppColors.accent,
            )),
            SizedBox(height: 6.h),

            // Status row
            Row(children: [
              _StatusBadge(p['status'] as String? ?? 'draft'),
              const Spacer(),
              if (hasExpiry)
                Row(children: [
                  Icon(Icons.schedule_rounded, size: 11.sp, color: expiryColor),
                  SizedBox(width: 3.w),
                  Text(
                    daysLeft == 0 ? 'Истекает сегодня' : 'Ещё $daysLeft д.',
                    style: TextStyle(
                      fontSize: 11.sp, fontWeight: FontWeight.w600,
                      color: expiryColor,
                    ),
                  ),
                ]),
            ]),

            // Renew button
            if (canRenew) ...[
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _renewing ? null : () async {
                  setState(() => _renewing = true);
                  await widget.onRenew(p['id'] as String);
                  if (mounted) setState(() => _renewing = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 34.h,
                  decoration: BoxDecoration(
                    gradient: _renewing ? null : const LinearGradient(
                      colors: [AppColors.orange, Color(0xFFF97316)],
                    ),
                    color: _renewing
                        ? AppColors.orange.withOpacity(0.2)
                        : null,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: _renewing
                        ? SizedBox(
                            width: 16.w, height: 16.w,
                            child: const CircularProgressIndicator(
                              color: AppColors.orange, strokeWidth: 2,
                            ),
                          )
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.autorenew_rounded,
                              color: Colors.white, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text('Продлить на 7 дней',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              )),
                          ]),
                  ),
                ),
              ),
            ],
          ])),
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final map = {
      'active':       ('Активен',   AppColors.green),
      'draft':        ('Черновик',  AppColors.textMuted),
      'pending':      ('На проверке', AppColors.orange),
      'out_of_stock': ('Нет в наличии', AppColors.red),
      'rejected':     ('Отклонён',  AppColors.red),
    };
    final (label, color) = map[status] ?? ('Неизвестен', AppColors.textMuted);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 10.sp, fontWeight: FontWeight.w600, color: color,
        )),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
      Text('😕', style: TextStyle(fontSize: 40.sp)),
      SizedBox(height: 12.h),
      const Text('Не удалось загрузить товары'),
      SizedBox(height: 12.h),
      TextButton(onPressed: onRetry, child: const Text('Повторить')),
    ],
  ));
}
