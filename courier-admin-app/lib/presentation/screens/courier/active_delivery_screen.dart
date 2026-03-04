import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/courier/courier_bloc.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  final String orderId;
  const ActiveDeliveryScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CourierBloc>()..add(CourierLoadOrders()),
      child: _ActiveDeliveryBody(orderId: orderId),
    );
  }
}

class _ActiveDeliveryBody extends StatelessWidget {
  final String orderId;
  const _ActiveDeliveryBody({required this.orderId});

  static const _steps = ['Забрать 🏪', 'В пути 🛵', 'Доставить 📬'];
  static const _stepBtns = ['✅ Подтвердить у продавца', '📬 Подтвердить доставку'];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourierBloc, CourierState>(
      listener: (ctx, state) {
        // After completion navigate home
        if (state.activeOrder == null && state.deliveryStep == 0) {
          ctx.go(Routes.courierMap);
        }
      },
      builder: (ctx, state) {
        final order = state.activeOrder;
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.bgDark,
            body: const Center(child: CircularProgressIndicator(color: AppColors.green)),
          );
        }

        final step = state.deliveryStep;
        final courierPos = LatLng(
          state.currentLat ?? AppConstants.defaultLat,
          state.currentLng ?? AppConstants.defaultLng,
        );
        final sellerPos  = LatLng(order.sellerLat,   order.sellerLng);
        final deliveryPos = LatLng(order.deliveryLat, order.deliveryLng);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text('Заказ #${order.id.substring(order.id.length - 6).toUpperCase()}'),
            backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Map ───────────────────────────────────────────────────
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(initialCenter: courierPos, initialZoom: 14),
                    children: [
                      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'uz.gogomarket.courier'),
                      PolylineLayer(polylines: [
                        Polyline(points: [sellerPos, courierPos, deliveryPos], color: AppColors.green, strokeWidth: 3),
                      ]),
                      MarkerLayer(markers: [
                        Marker(point: sellerPos, child: const Text('🏪', style: TextStyle(fontSize: 22))),
                        Marker(point: deliveryPos, child: const Text('📍', style: TextStyle(fontSize: 22))),
                        Marker(point: courierPos, child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)),
                          child: const Center(child: Text('🛵', style: TextStyle(fontSize: 14))),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Progress ──────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: step / (_steps.length - 1).toDouble(),
                  backgroundColor: AppColors.bgCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),

              // ── Steps ────────────────────────────────────────────────
              Row(children: List.generate(_steps.length, (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == _steps.length - 1 ? 0 : 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == step ? AppColors.green.withOpacity(0.15)
                      : i < step ? AppColors.green.withOpacity(0.08) : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: i == step ? AppColors.green : AppColors.border),
                  ),
                  child: Text(_steps[i], textAlign: TextAlign.center,
                    style: TextStyle(color: i <= step ? AppColors.green : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ))),
              const SizedBox(height: 16),

              // ── Order info ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.productTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _RouteRow('🏪 Забрать у', order.sellerName, order.sellerAddress),
                  const Divider(color: AppColors.border, height: 16),
                  _RouteRow('📍 Доставить', order.buyerName, order.deliveryAddress),
                ]),
              ),
              const SizedBox(height: 12),

              // ── Buyer contact ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.blue.withOpacity(0.6), AppColors.purple.withOpacity(0.6)]),
                    shape: BoxShape.circle,
                  ), child: const Center(child: Text('👤', style: TextStyle(fontSize: 20)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(order.buyerName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (order.buyerPhone != null) Text(order.buyerPhone!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ])),
                  IconButton(icon: const Icon(Icons.phone_outlined, color: AppColors.green), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.chat_bubble_outline, color: AppColors.blue), onPressed: () {}),
                ]),
              ),
              const SizedBox(height: 20),

              // ── CTA ───────────────────────────────────────────────────
              if (step < _stepBtns.length)
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => ctx.read<CourierBloc>().add(CourierNextStep()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(_stepBtns[step], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.green.withOpacity(0.3)),
                  ),
                  child: Column(children: [
                    const Text('🎉', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    const Text('Доставка завершена!', style: TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('+${FormatUtils.price(order.feeSum)} сум начислено',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ]),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String label, name, address;
  const _RouteRow(this.label, this.name, this.address);
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
    const Spacer(),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
      Text(address, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  ]);
}
