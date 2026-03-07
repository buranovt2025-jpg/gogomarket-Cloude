import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});
  @override State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _mapCtrl = MapController();

  // Tashkent coords
  static const _seller  = LatLng(41.2995, 69.2401);
  static const _buyer   = LatLng(41.3111, 69.2797);
  LatLng _courier = const LatLng(41.3040, 69.2580);

  Timer? _sim;
  int _step = 0;
  int _eta  = 24;

  // Simulated courier path
  static const _path = [
    LatLng(41.3040, 69.2580),
    LatLng(41.3055, 69.2640),
    LatLng(41.3071, 69.2700),
    LatLng(41.3088, 69.2748),
    LatLng(41.3111, 69.2797),
  ];

  @override
  void initState() {
    super.initState();
    _sim = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_step < _path.length - 1) {
        setState(() {
          _step++;
          _courier = _path[_step];
          _eta = (24 - _step * 5).clamp(0, 24);
        });
        _mapCtrl.move(_courier, 15);
      } else {
        _sim?.cancel();
      }
    });
  }

  @override
  void dispose() { _sim?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.54), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16)),
        ),
      ),
      body: Stack(children: [
        // ── Map ──────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _courier,
            initialZoom: 14.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'uz.gogomarket.app',
            ),

            // Route polyline
            PolylineLayer(polylines: [
              Polyline(points: _path, strokeWidth: 4, color: AppColors.accent.withOpacity(0.7)),
            ]),

            // Markers
            MarkerLayer(markers: [
              // Seller
              Marker(point: _seller, width: 44, height: 44, child: Container(
                decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.4), blurRadius: 8)]),
                child: const Center(child: Text('🏪', style: TextStyle(fontSize: 18))))),

              // Courier
              Marker(point: _courier, width: 50, height: 50, child: Container(
                decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 12)]),
                child: const Center(child: Text('🛵', style: TextStyle(fontSize: 22))))),

              // Buyer
              Marker(point: _buyer, width: 44, height: 44, child: Container(
                decoration: BoxDecoration(color: AppColors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.4), blurRadius: 8)]),
                child: const Center(child: Text('🏠', style: TextStyle(fontSize: 18))))),
            ]),
          ],
        ),

        // ── Bottom card ───────────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ETA bar
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.accent.withOpacity(0.15), AppColors.accent.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Text('🛵', style: TextStyle(fontSize: 28.sp)),
                  SizedBox(width: 12.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_step >= _path.length - 1 ? 'Доставлено!' : 'Курьер в пути',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    Text(_step >= _path.length - 1 ? 'Ваш заказ доставлен ✓' : 'Ожидаемое время: ~$_eta мин',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
                  ]),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Center(child: Text('$_eta\nмин', textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.accent, fontSize: 11.sp, fontWeight: FontWeight.w700, height: 1.2))),
                  ),
                ]),
              ),
              SizedBox(height: 14.h),

              // Courier contact
              Row(children: [
                Container(width: 44.w, height: 44.w,
                  decoration: BoxDecoration(color: AppColors.bgSurface, shape: BoxShape.circle),
                  child: Center(child: Text('С', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18.sp)))),
                SizedBox(width: 10.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Санжар К.', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                    SizedBox(width: 3.w),
                    Text('4.9 · 1 240 доставок', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                  ]),
                ]),
                const Spacer(),
                _CallBtn(Icons.call_outlined, AppColors.green, () {}),
                SizedBox(width: 8.w),
                _CallBtn(Icons.chat_bubble_outline, AppColors.blue, () {}),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _CallBtn(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))),
      child: Icon(icon, color: color, size: 18)),
  );
}
