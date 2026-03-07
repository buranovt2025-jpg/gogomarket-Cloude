import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/utils/format.dart';
import '../../blocs/auth/auth_bloc.dart';

class _Message {
  final String id, content, senderId;
  final DateTime createdAt;
  final bool isMe;
  _Message({required this.id, required this.content, required this.senderId,
    required this.createdAt, required this.isMe});

  factory _Message.fromJson(Map<String, dynamic> j, String myId) => _Message(
    id: j['id'] as String? ?? UniqueKey().toString(),
    content: j['content'] as String? ?? '',
    senderId: j['senderId'] ?? j['sender_id'] ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] ?? j['created_at'] ?? '') ?? DateTime.now(),
    isMe: (j['senderId'] ?? j['sender_id']) == myId,
  );
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final _socket = SocketService.instance;
  final _api    = getIt<ApiClient>();

  List<_Message> _msgs = [];
  bool _loading = true;
  bool _partnerTyping = false;
  String _myId = '';
  String _partnerName = 'Продавец';
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _myId = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user.id ?? '';
    _loadHistory();
    _listenSocket();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await _api.getChatMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        _msgs = (res as List).map((m) => _Message.fromJson(Map<String,dynamic>.from(m), _myId)).toList();
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenSocket() {
    _socket.joinChat(widget.chatId);

    _socket.on('chat:message', (data) {
      final m = data is Map ? Map<String,dynamic>.from(data) : <String,dynamic>{};
      if (m['chatId'] == widget.chatId || m['chat_id'] == widget.chatId) {
        if (mounted) {
          setState(() => _msgs.add(_Message.fromJson(m, _myId)));
          _scrollToBottom();
        }
      }
    });

    _socket.on('chat:typing', (data) {
      final d = data is Map ? Map<String,dynamic>.from(data) : <String,dynamic>{};
      if (d['userId'] != _myId && mounted) {
        setState(() => _partnerTyping = d['isTyping'] == true);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _onTyping() {
    _socket.sendTyping(widget.chatId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _socket.sendTyping(widget.chatId, false);
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // Optimistic UI — добавляем сразу
    setState(() {
      _msgs.add(_Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text, senderId: _myId,
        createdAt: DateTime.now(), isMe: true,
      ));
    });
    _ctrl.clear();
    _socket.sendTyping(widget.chatId, false);
    _socket.sendMessage(chatId: widget.chatId, content: text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _socket.leaveChat(widget.chatId);
    _socket.off('chat:message');
    _socket.off('chat:typing');
    _ctrl.dispose();
    _scroll.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Row(children: [
          CircleAvatar(radius: 18.r, backgroundColor: AppColors.accentBg,
            child: Text(_partnerName[0], style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700))),
          SizedBox(width: 10.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_partnerName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            Text(_partnerTyping ? 'печатает...' : 'в сети',
              style: TextStyle(fontSize: 11.sp,
                color: _partnerTyping ? AppColors.accent : AppColors.green)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),

      body: Column(children: [
        // Messages
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _msgs.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('👋', style: TextStyle(fontSize: 48.sp)),
                  SizedBox(height: 12.h),
                  Text('Начните диалог', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
                ]))
              : ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  itemCount: _msgs.length + (_partnerTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_partnerTyping && i == _msgs.length) return _TypingBubble();
                    return _Bubble(msg: _msgs[i]);
                  },
                ),
        ),

        // Input bar
        Container(
          color: theme.cardTheme.color,
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, MediaQuery.of(context).padding.bottom + 8.h),
          child: Row(children: [
            IconButton(icon: Icon(Icons.attach_file, color: AppColors.textMuted, size: 22.sp), onPressed: () {}),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (_) => _onTyping(),
                  style: TextStyle(fontSize: 14.sp),
                  maxLines: 4, minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Сообщение...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44.w, height: 44.w,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final _Message msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 6.h,
          left:  msg.isMe ? 60.w : 0,
          right: msg.isMe ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: msg.isMe
            ? AppColors.accent
            : (isDark ? AppColors.darkBgCard : AppColors.lightBgCard),
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(msg.isMe ? 18 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0,2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(msg.content, style: TextStyle(
            color: msg.isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14.sp,
          )),
          SizedBox(height: 3.h),
          Text(FormatUtils.timeShort(msg.createdAt), style: TextStyle(
            color: msg.isMe ? Colors.white60 : AppColors.textMuted, fontSize: 10.sp,
          )),
        ]),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : AppColors.lightBgCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0), _Dot(delay: 150), _Dot(delay: 300),
        ]),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(width: 7.w, height: 7.w, margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
  );
}

