import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_utils.dart';
import '../../blocs/courier/courier_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/stat_card.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CourierBloc>()..add(CourierLoadOrders()),
      child: const _MapScreenBody(),
    );
  }
}

class _MapScreenBody extends StatelessWidget {
  const _MapScreenBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourierBloc, CourierState>(
      builder: (ctx, state) {
        final user = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
        final center = LatLng(
          state.currentLat ?? AppConstants.defaultLat,
          state.currentLng ?? AppConstants.defaultLng,
        );

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Привет, ${user?.name ?? 'Курьер'} 👋',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        const Text('Ташкент · Юнусабад р-н',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ]),
                      // Online/Offline toggle
                      GestureDetector(
                        onTap: () => ctx.read<CourierBloc>().add(CourierToggleOnline()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: state.isOnline
                              ? AppColors.green.withOpacity(0.15)
                              : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: state.isOnline ? AppColors.green : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: state.isOnline ? AppColors.green : AppColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(state.isOnline ? 'Онлайн' : 'Офлайн',
                                style: TextStyle(
                                  color: state.isOnline ? AppColors.green : AppColors.textMuted,
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: StatCard(label: 'Заказов', value: '8', icon: '📦', color: AppColors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Заработок', value: '144K', icon: '💰', color: AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Км', value: '32.4', icon: '🛵', color: AppColors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Map ──────────────────────────────────────────────────
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: FlutterMap(
                      options: MapOptions(initialCenter: center, initialZoom: AppConstants.defaultZoom),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'uz.gogomarket.courier',
                        ),
                        // Courier marker
                        if (state.currentLat != null)
                          MarkerLayer(markers: [
                            Marker(
                              point: center,
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)],
                                ),
                                child: const Center(child: Text('🛵', style: TextStyle(fontSize: 18))),
                              ),
                            ),
                          ]),
                        // Available order markers
                        MarkerLayer(markers: state.availableOrders.map((o) => Marker(
                          point: LatLng(o.sellerLat, o.sellerLng),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)),
                            child: const Center(child: Text('📦', style: TextStyle(fontSize: 16))),
                          ),
                        )).toList()),
                      ],
                    ),
                  ),
                ),

                // ── New order banner ─────────────────────────────────────
                if (state.isOnline && state.availableOrders.isNotEmpty)
                  _NewOrderBanner(order: state.availableOrders.first),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NewOrderBanner extends StatelessWidget {
  final dynamic order;
  const _NewOrderBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.green.withOpacity(0.9), AppColors.green.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🔔', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Expanded(child: Text('Новый заказ рядом',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('+${FormatUtils.price(order.feeSum)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.54)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Пропустить'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<CourierBloc>().add(CourierAcceptOrder(order.id)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Принять', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
