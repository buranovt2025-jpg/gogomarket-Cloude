import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../blocs/admin/admin_bloc.dart';
import '../../../data/models/admin/seller_pending_model.dart';
import '../../../data/models/admin/flagged_content_model.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});
  @override State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(AdminLoadModeration()),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          title: const Text('Модерация'),
          backgroundColor: AppColors.bgDark,
          bottom: TabBar(
            controller: _tab,
            indicatorColor: AppColors.purple,
            labelColor: AppColors.purple,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [Tab(text: 'Продавцы'), Tab(text: 'Контент')],
          ),
        ),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (ctx, state) {
            if (state.toast != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.toast!), backgroundColor: AppColors.bgCard,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            }
          },
          builder: (ctx, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.purple));
            return TabBarView(
              controller: _tab,
              children: [
                // ── Sellers tab ──────────────────────────────────────────
                state.pendingSellers.isEmpty
                  ? _Empty('Нет заявок на верификацию')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.pendingSellers.length,
                      itemBuilder: (_, i) => _SellerCard(
                        seller: state.pendingSellers[i],
                        decision: state.sellerDecisions[state.pendingSellers[i].id],
                      ),
                    ),

                // ── Content tab ──────────────────────────────────────────
                state.flaggedContent.isEmpty
                  ? _Empty('Жалоб нет')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.flaggedContent.length,
                      itemBuilder: (_, i) => _ContentCard(
                        content: state.flaggedContent[i],
                        decision: state.contentDecisions[state.flaggedContent[i].id],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final SellerPendingModel seller;
  final bool? decision;
  const _SellerCard({required this.seller, this.decision});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decision == null ? AppColors.border : decision! ? AppColors.green : AppColors.red),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('🏪', style: TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(seller.shopName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            Text('ИНН: ${seller.inn ?? '-'}  ·  ${_timeAgo(seller.createdAt)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          if (decision != null) Icon(decision! ? Icons.check_circle : Icons.cancel,
            color: decision! ? AppColors.green : AppColors.red, size: 24),
        ]),
        if (seller.passportUrl != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: seller.passportUrl!, height: 90, width: double.infinity, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(height: 90, color: AppColors.bgSurface,
                child: const Center(child: Text('📄 Паспорт', style: TextStyle(color: AppColors.textMuted))))),
          ),
        ],
        if (decision == null) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.read<AdminBloc>().add(AdminVerifySeller(id: seller.id, approved: false)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.close, size: 16), label: const Text('Отклонить'),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => context.read<AdminBloc>().add(AdminVerifySeller(id: seller.id, approved: true)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.check, size: 16), label: const Text('Одобрить'),
            )),
          ]),
        ],
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours  < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} д назад';
  }
}

class _ContentCard extends StatelessWidget {
  final FlaggedContentModel content;
  final bool? decision;
  const _ContentCard({required this.content, this.decision});

  @override
  Widget build(BuildContext context) {
    final typeIcon = switch (content.type) {
      'reel'   => '🎬', 'review' => '⭐', _ => '📦',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: decision == null ? AppColors.border : decision! ? AppColors.green : AppColors.red)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(typeIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(content.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2),
            Text('Продавец: ${content.sellerName ?? '-'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
        ]),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
          child: Text('🚩 ${content.reason}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        if (decision == null) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => context.read<AdminBloc>().add(AdminModerateContent(id: content.id, approved: false)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Удалить'),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => context.read<AdminBloc>().add(AdminModerateContent(id: content.id, approved: true)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Одобрить'),
            )),
          ]),
        ] else
          Padding(padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Icon(decision! ? Icons.check_circle : Icons.cancel, size: 16, color: decision! ? AppColors.green : AppColors.red),
              const SizedBox(width: 6),
              Text(decision! ? 'Одобрено' : 'Удалено', style: TextStyle(color: decision! ? AppColors.green : AppColors.red, fontSize: 12)),
            ])),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty(this.message);
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('✅', style: TextStyle(fontSize: 48)),
    const SizedBox(height: 12),
    Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
  ]));
}
