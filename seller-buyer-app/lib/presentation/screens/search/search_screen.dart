import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product/product_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  bool _searching = false;

  static const _recent  = ['Платье летнее', 'Nike Air Max', 'Помада Rose', 'iPhone чехол'];
  static const _trending = ['👗 Одежда', '👟 Кроссовки', '💄 Косметика', '📱 Техника', '🏠 Декор', '🎁 Подарки'];

  static final _results = List.generate(6, (i) => ProductModel(
    id: 'sr$i', sellerId: 's$i',
    title: ['Платье миди', 'Платье вечернее', 'Платье повседневное', 'Платье свадебное', 'Платье летнее', 'Платье мини'][i],
    priceTiyin: [18500000, 45000000, 12000000, 120000000, 9800000, 22000000][i],
    status: 'active', photoUrls: [],
    createdAt: DateTime.now(),
    avgRating: 4.6 + i * 0.05,
    soldCount: 50 + i * 30,
    reviewCount: 10 + i * 8,
  ));

  @override
  void initState() { super.initState(); _focus.requestFocus(); }
  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        titleSpacing: 0,
        title: Container(
          height: 42.h,
          margin: EdgeInsets.only(right: 16.w),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Поиск товаров...',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              suffixIcon: _query.isNotEmpty ? GestureDetector(
                onTap: () { _ctrl.clear(); setState(() { _query = ''; _searching = false; }); },
                child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
              ) : null,
            ),
            onChanged: (v) => setState(() { _query = v; _searching = v.isNotEmpty; }),
            onSubmitted: (v) => setState(() { _query = v; _searching = true; }),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _searching ? _Results(query: _query) : _Discovery(),
      ),
    );
  }
}

class _Discovery extends StatelessWidget {
  static const _recent   = ['Платье летнее', 'Nike Air Max', 'Помада Rose', 'iPhone чехол'];
  static const _trending = ['👗 Одежда', '👟 Кроссовки', '💄 Косметика', '📱 Техника', '🏠 Декор', '🎁 Подарки'];

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(16.w),
    children: [
      Text('Недавние', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
      SizedBox(height: 10.h),
      ..._recent.map((r) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.history, color: AppColors.textMuted),
        title: Text(r, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
        trailing: const Icon(Icons.arrow_outward, color: AppColors.textMuted, size: 14),
        onTap: () {},
      )),
      SizedBox(height: 16.h),
      Text('Популярное', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
      SizedBox(height: 10.h),
      Wrap(spacing: 8.w, runSpacing: 8.h, children: _trending.map((t) => GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Text(t, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp)),
        ),
      )).toList()),
    ],
  );
}

class _Results extends StatelessWidget {
  final String query;
  const _Results({required this.query});

  static final _results = List.generate(6, (i) => ProductModel(
    id: 'sr$i', sellerId: 's$i',
    title: ['Платье миди', 'Платье вечернее', 'Платье повседневное', 'Платье свадебное', 'Платье летнее', 'Платье мини'][i],
    priceTiyin: [18500000, 45000000, 12000000, 120000000, 9800000, 22000000][i],
    status: 'active', photoUrls: [], createdAt: DateTime.now(),
    avgRating: 4.6, soldCount: 50, reviewCount: 10,
  ));

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(children: [
        Text('Результаты по "$query"', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
        const Spacer(),
        Text('${_results.length} товаров', style: TextStyle(color: AppColors.accent, fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ]),
    ),
    Expanded(child: GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 0.68,
      ),
      itemCount: _results.length,
      itemBuilder: (_, i) => ProductCard(
        product: _results[i],
        onTap: () => context.push(Routes.productDetail(_results[i].id)),
      ),
    )),
  ]);
}
