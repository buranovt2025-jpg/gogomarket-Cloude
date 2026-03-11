import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/format.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiClient>();
      final data = await api.getNotifications();
      if (mounted) setState(() {
        _notifs = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markAllRead() async {
    HapticFeedback.selectionClick();
    try {
      await getIt<ApiClient>().markAllNotificationsRead();
      setState(() {
        _notifs = _notifs.map((n) => {...n, 'isRead': true}).toList();
      });
    } catch (_) {}
  }

  Future<void> _markRead(String id) async {
    try {
      await getIt<ApiClient>().markNotificationRead(id);
      setState(() {
        final idx = _notifs.indexWhere((n) => n['id'] == id);
        if (idx != -1) _notifs[idx] = {..._notifs[idx], 'isRead': true};
      });
    } catch (_) {}
  }

  int get _unreadCount => _notifs.where((n) => n['isRead'] != true).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5),
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Уведомления',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)),
          if (_unreadCount > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text('$_unreadCount',
                style: TextStyle(
                  color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Всё прочитано',
                style: TextStyle(color: AppColors.accent, fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? _errorView()
              : _notifs.isEmpty
                  ? _emptyView(isDark)
                  : RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: _notifs.length,
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          return _NotifCard(
                            notif: n,
                            isDark: isDark,
                            onTap: () {
                              if (n['isRead'] != true) _markRead(n['id'] as String);
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _errorView() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('😕', style: TextStyle(fontSize: 40.sp)),
    SizedBox(height: 12.h),
    Text('Не удалось загрузить уведомления'),
    SizedBox(height: 12.h),
    TextButton(onPressed: _load, child: const Text('Повторить')),
  ]));

  Widget _emptyView(bool isDark) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text('🔔', style: TextStyle(fontSize: 52.sp)),
    SizedBox(height: 16.h),
    Text('Пока нет уведомлений',
      style: TextStyle(
        fontSize: 16.sp, fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      )),
    SizedBox(height: 8.h),
    Text('Здесь появятся уведомления о заказах,\nтоварах и сообщениях',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
      )),
  ]));
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final bool isDark;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif, required this.isDark, required this.onTap,
  });

  static const _typeConfig = {
    'order':    ('📦', AppColors.accent),
    'delivery': ('🚚', AppColors.blue),
    'chat':     ('💬', AppColors.purple),
    'promo':    ('🎉', AppColors.red),
    'review':   ('⭐', AppColors.gold),
    'follow':   ('👥', AppColors.green),
    'system':   ('⚙️', AppColors.textMuted),
    'dispute':  ('⚠️', AppColors.orange),
  };

  @override
  Widget build(BuildContext context) {
    final type = notif['type'] as String? ?? 'system';
    final (icon, color) = _typeConfig[type] ?? ('🔔', AppColors.accent);
    final isRead = notif['isRead'] as bool? ?? false;
    final title = notif['title'] as String? ?? '';
    final body  = notif['body'] as String? ?? '';
    final createdAt = DateTime.tryParse(notif['createdAt'] as String? ?? '') ?? DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? const Color(0xFF1A1A1A) : Colors.white)
              : (isDark ? color.withOpacity(0.08) : color.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRead
                ? (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06))
                : color.withOpacity(0.25),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icon
          Container(
            width: 42.w, height: 42.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 18.sp))),
          ),
          SizedBox(width: 12.w),

          // Content
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ))),
              SizedBox(width: 8.w),
              Text(
                _timeAgo(createdAt),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                ),
              ),
            ]),
            if (body.isNotEmpty) ...[
              SizedBox(height: 3.h),
              Text(body,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white.withOpacity(0.55) : Colors.black.withOpacity(0.55),
                ),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ],
          ])),

          // Unread dot
          if (!isRead) ...[
            SizedBox(width: 8.w),
            Container(
              width: 8.w, height: 8.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ]),
      ),
    );
  }
}

String _timeAgo(DateTime dt) => Format.timeAgo(dt);
