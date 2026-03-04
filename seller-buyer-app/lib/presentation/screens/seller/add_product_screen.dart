import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/gogo_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _stockCtrl  = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  final List<XFile> _photos = [];
  String _category = 'Одежда';
  bool _loading = false;

  static const _cats = ['Одежда', 'Обувь', 'Красота', 'Техника', 'Дом', 'Еда', 'Спорт', 'Другое'];

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _stockCtrl.dispose(); super.dispose(); }

  Future<void> _pickPhotos() async {
    final imgs = await ImagePicker().pickMultiImage(imageQuality: 80, limit: 8);
    if (imgs.isNotEmpty) setState(() { _photos.addAll(imgs); if (_photos.length > 8) _photos.removeRange(8, _photos.length); });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // API call placeholder
    if (mounted) { setState(() => _loading = false); context.pop(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Добавить товар', style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(onPressed: _loading ? null : _save,
            child: Text('Сохранить', style: TextStyle(color: _loading ? AppColors.textMuted : AppColors.accent, fontSize: 14.sp, fontWeight: FontWeight.w600))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: EdgeInsets.all(16.w), children: [

          // Photos picker
          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _photos.isEmpty ? AppColors.border : AppColors.accent.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: _photos.isEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted, size: 32.sp),
                    SizedBox(height: 6.h),
                    Text('Добавить фото (до 8)', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
                  ])
                : Row(children: [
                    ..._photos.take(4).map((f) => Expanded(
                      child: Container(margin: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('📷', style: TextStyle(fontSize: 24.sp)))),
                    )),
                    if (_photos.length < 8)
                      Expanded(child: GestureDetector(onTap: _pickPhotos,
                        child: Container(margin: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
                          child: Center(child: Icon(Icons.add, color: AppColors.textMuted, size: 22.sp))))),
                  ]),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          _Label('НАЗВАНИЕ *'),
          SizedBox(height: 6.h),
          _TF(ctrl: _titleCtrl, hint: 'Платье летнее Zara style',
            validator: (v) => (v == null || v.trim().length < 3) ? 'Минимум 3 символа' : null),
          SizedBox(height: 14.h),

          // Category
          _Label('КАТЕГОРИЯ'),
          SizedBox(height: 8.h),
          SizedBox(height: 36.h, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final sel = _category == _cats[i];
              return GestureDetector(
                onTap: () => setState(() => _category = _cats[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.accent : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.accent : AppColors.border),
                  ),
                  child: Center(child: Text(_cats[i], style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 12.sp,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal))),
                ),
              );
            },
          )),
          SizedBox(height: 14.h),

          // Price + stock
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Label('ЦЕНА (сум) *'),
              SizedBox(height: 6.h),
              _TF(ctrl: _priceCtrl, hint: '185 000', keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.isEmpty) ? 'Обязательно' : null),
            ])),
            SizedBox(width: 10.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Label('ОСТАТОК'),
              SizedBox(height: 6.h),
              _TF(ctrl: _stockCtrl, hint: '10', keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly]),
            ])),
          ]),
          SizedBox(height: 14.h),

          // Description
          _Label('ОПИСАНИЕ'),
          SizedBox(height: 6.h),
          _TF(ctrl: _descCtrl, hint: 'Опишите товар: материал, размеры, особенности...', maxLines: 4),
          SizedBox(height: 24.h),

          GogoButton(label: 'Опубликовать товар', loading: _loading, onPressed: _save),
          SizedBox(height: 8.h),
          GogoButton(label: 'Сохранить как черновик', variant: ButtonVariant.ghost, onPressed: () {}),
          SizedBox(height: 40.h),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String t;
  const _Label(this.t);
  @override
  Widget build(BuildContext c) => Text(t, style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1));
}

class _TF extends StatelessWidget {
  final TextEditingController ctrl; final String hint;
  final int maxLines; final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  const _TF({required this.ctrl, required this.hint, this.maxLines=1, this.keyboardType, this.formatters, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
    inputFormatters: formatters, validator: validator,
    style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
    decoration: InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
      filled: true, fillColor: AppColors.bgCard,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.red)),
    ),
  );
}
