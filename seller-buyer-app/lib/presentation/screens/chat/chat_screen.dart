import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg('Здравствуйте! Есть размер M в наличии?', false, DateTime.now().subtract(const Duration(minutes: 8))),
    _Msg('Да, есть! Осталось 2 штуки', true, DateTime.now().subtract(const Duration(minutes: 7))),
    _Msg('Отлично! Сколько стоит доставка?', false, DateTime.now().subtract(const Duration(minutes: 6))),
    _Msg('Доставка бесплатная при заказе от 150K сум', true, DateTime.now().subtract(const Duration(minutes: 5))),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text, false, DateTime.now()));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        title: Row(children: [
          Container(width: 36.w, height: 36.w,
            decoration: BoxDecoration(color: AppColors.bgCard, shape: BoxShape.circle),
            child: const Center(child: Text('👗', style: TextStyle(fontSize: 18)))),
          SizedBox(width: 10.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aisha Fashion', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('Онлайн', style: TextStyle(fontSize: 10.sp, color: AppColors.green)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: EdgeInsets.all(16.w),
          itemCount: _msgs.length,
          itemBuilder: (_, i) => _MsgBubble(msg: _msgs[i]),
        )),
        _InputBar(ctrl: _ctrl, onSend: _send),
      ]),
    );
  }
}

class _Msg {
  final String text; final bool isMine; final DateTime time;
  const _Msg(this.text, this.isMine, this.time);
}

class _MsgBubble extends StatelessWidget {
  final _Msg msg;
  const _MsgBubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, left: msg.isMine ? 0 : 48.w, right: msg.isMine ? 48.w : 0),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: msg.isMine ? AppColors.bgCard : AppColors.accent,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMine ? 4 : 16),
            bottomRight: Radius.circular(msg.isMine ? 16 : 4),
          ),
        ),
        child: Column(crossAxisAlignment: msg.isMine ? CrossAxisAlignment.start : CrossAxisAlignment.end, children: [
          Text(msg.text, style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.4)),
          SizedBox(height: 3.h),
          Text(FormatUtils.timeAgo(msg.time), style: TextStyle(color: Colors.white54, fontSize: 9.sp)),
        ]),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl; final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 24.h),
    decoration: const BoxDecoration(color: AppColors.bgCard, border: Border(top: BorderSide(color: AppColors.border))),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.attach_file, color: AppColors.textMuted), onPressed: () {}),
      Expanded(child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
        child: TextField(
          controller: ctrl,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Написать сообщение...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            border: InputBorder.none, isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
          maxLines: null,
          onSubmitted: (_) => onSend(),
        ),
      )),
      SizedBox(width: 8.w),
      GestureDetector(
        onTap: onSend,
        child: Container(width: 40, height: 40,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
      ),
    ]),
  );
}
