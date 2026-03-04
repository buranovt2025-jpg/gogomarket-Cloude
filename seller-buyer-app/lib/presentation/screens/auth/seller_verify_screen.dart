import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';

enum _VerifyStep { info, docs, submitted }

class SellerVerifyScreen extends StatefulWidget {
  const SellerVerifyScreen({super.key});
  @override State<SellerVerifyScreen> createState() => _SellerVerifyScreenState();
}

class _SellerVerifyScreenState extends State<SellerVerifyScreen> {
  _VerifyStep _step = _VerifyStep.info;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Shop info
  final _shopNameCtrl  = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _innCtrl       = TextEditingController();

  // Step 2: Docs
  XFile? _passportPhoto;
  XFile? _innPhoto;
  bool _loading = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _descCtrl.dispose();
    _innCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isPassport) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null && mounted) {
      setState(() {
        if (isPassport) _passportPhoto = img;
        else _innPhoto = img;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await getIt<ApiClient>().registerSeller({
        'shopName':    _shopNameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'inn':         _innCtrl.text.trim(),
      });
      if (mounted) setState(() { _step = _VerifyStep.submitted; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: _step == _VerifyStep.info
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
            )
          : _step == _VerifyStep.docs
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _step = _VerifyStep.info),
              )
            : null,
        title: _step != _VerifyStep.submitted
          ? _ProgressBar(current: _step == _VerifyStep.info ? 1 : 2, total: 2)
          : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        child: switch (_step) {
          _VerifyStep.info      => _StepInfo(key: const ValueKey('info'), shopNameCtrl: _shopNameCtrl, descCtrl: _descCtrl, formKey: _formKey,
              onNext: () { if (_formKey.currentState!.validate()) setState(() => _step = _VerifyStep.docs); }),
          _VerifyStep.docs      => _StepDocs(key: const ValueKey('docs'), innCtrl: _innCtrl,
              passportPhoto: _passportPhoto, innPhoto: _innPhoto,
              onPickPassport: () => _pickImage(true), onPickInn: () => _pickImage(false),
              loading: _loading, onSubmit: _submit),
          _VerifyStep.submitted => _StepSubmitted(key: const ValueKey('done'),
              shopName: _shopNameCtrl.text,
              onGoHome: () => context.go(Routes.feed)),
        },
      ),
    );
  }
}

// ── Step 1: Shop info ─────────────────────────────────────────────────────────
class _StepInfo extends StatelessWidget {
  final TextEditingController shopNameCtrl, descCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onNext;
  const _StepInfo({super.key, required this.shopNameCtrl, required this.descCtrl, required this.formKey, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 20.h),
          Text('Информация\nо магазине', style: TextStyle(
            fontFamily: 'Playfair', fontSize: 26.sp,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2,
          )),
          SizedBox(height: 6.h),
          Text('Это увидят покупатели', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
          SizedBox(height: 28.h),

          _Label('НАЗВАНИЕ МАГАЗИНА'),
          SizedBox(height: 8.h),
          _Field(ctrl: shopNameCtrl, hint: 'Aisha Fashion Store', validator: (v) {
            if (v == null || v.trim().length < 3) return 'Минимум 3 символа';
            return null;
          }),
          SizedBox(height: 16.h),

          _Label('ОПИСАНИЕ (необязательно)'),
          SizedBox(height: 8.h),
          _Field(ctrl: descCtrl, hint: 'Женская одежда, доставка по Ташкенту...', maxLines: 3),
          const Spacer(),

          SizedBox(
            width: double.infinity, height: 52.h,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4, shadowColor: AppColors.accent.withOpacity(0.4),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Далее', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 6.w),
                Icon(Icons.arrow_forward_ios, size: 13.sp),
              ]),
            ),
          ),
          SizedBox(height: 32.h),
        ]),
      ),
    );
  }
}

// ── Step 2: Documents ─────────────────────────────────────────────────────────
class _StepDocs extends StatelessWidget {
  final TextEditingController innCtrl;
  final XFile? passportPhoto, innPhoto;
  final VoidCallback onPickPassport, onPickInn;
  final bool loading;
  final VoidCallback onSubmit;
  const _StepDocs({super.key, required this.innCtrl, this.passportPhoto, this.innPhoto,
    required this.onPickPassport, required this.onPickInn, required this.loading, required this.onSubmit});

  bool get _canSubmit => passportPhoto != null && innCtrl.text.length == 9;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 20.h),
        Text('Верификация', style: TextStyle(
          fontFamily: 'Playfair', fontSize: 26.sp,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        SizedBox(height: 6.h),
        Text('Для защиты покупателей', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.lock_outline, color: AppColors.blue, size: 18),
            SizedBox(width: 8.w),
            Expanded(child: Text('Данные хранятся в зашифрованном виде и не передаются третьим лицам',
              style: TextStyle(color: AppColors.blue, fontSize: 12.sp))),
          ]),
        ),
        SizedBox(height: 24.h),

        _Label('ИНН ОРГАНИЗАЦИИ ИЛИ ИП'),
        SizedBox(height: 8.h),
        _Field(
          ctrl: innCtrl,
          hint: '123456789',
          keyboardType: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
        ),
        SizedBox(height: 20.h),

        _Label('ФОТО ПАСПОРТА *'),
        SizedBox(height: 8.h),
        _PhotoPicker(photo: passportPhoto, hint: '+ Загрузить паспорт', onTap: onPickPassport),
        SizedBox(height: 16.h),

        _Label('СВИДЕТЕЛЬСТВО ИНН (необязательно)'),
        SizedBox(height: 8.h),
        _PhotoPicker(photo: innPhoto, hint: '+ Загрузить документ', onTap: onPickInn),
        SizedBox(height: 28.h),

        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton(
            onPressed: _canSubmit && !loading ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              disabledBackgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: _canSubmit ? 4 : 0,
              shadowColor: AppColors.green.withOpacity(0.4),
            ),
            child: loading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.send_outlined, size: 18),
                  SizedBox(width: 8.w),
                  Text('Отправить заявку', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                ]),
          ),
        ),
        SizedBox(height: 8.h),
        Center(child: Text('Проверка займёт до 24 часов', style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp))),
        SizedBox(height: 32.h),
      ]),
    );
  }
}

// ── Step 3: Submitted ─────────────────────────────────────────────────────────
class _StepSubmitted extends StatelessWidget {
  final String shopName;
  final VoidCallback onGoHome;
  const _StepSubmitted({super.key, required this.shopName, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100.w, height: 100.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.green.withOpacity(0.3), AppColors.green.withOpacity(0.1)]),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.green.withOpacity(0.4), width: 2),
          ),
          child: Center(child: Text('✅', style: TextStyle(fontSize: 48.sp))),
        ),
        SizedBox(height: 24.h),
        Text('Заявка отправлена!', style: TextStyle(
          fontFamily: 'Playfair', fontSize: 26.sp,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        SizedBox(height: 10.h),
        Text(
          '"$shopName" на проверке.\nМы уведомим вас в течение 24 часов.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp, height: 1.5),
        ),
        SizedBox(height: 40.h),
        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton(
            onPressed: onGoHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('На главную', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ── Shared components ─────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) => Expanded(
        child: Container(
          height: 3,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: i < current ? AppColors.accent : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: AppColors.textMuted, fontSize: 11.sp,
    fontWeight: FontWeight.w600, letterSpacing: 1.2,
  ));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  const _Field({required this.ctrl, required this.hint, this.maxLines = 1,
    this.keyboardType, this.formatters, this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.red)),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final XFile? photo;
  final String hint;
  final VoidCallback onTap;
  const _PhotoPicker({this.photo, required this.hint, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: photo != null ? AppColors.green : AppColors.border,
            width: photo != null ? 1.5 : 1,
          ),
        ),
        child: photo != null
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle, color: AppColors.green, size: 20),
              SizedBox(width: 8.w),
              Text('Фото загружено', style: TextStyle(color: AppColors.green, fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.upload_outlined, color: AppColors.textMuted, size: 28.sp),
              SizedBox(height: 6.h),
              Text(hint, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
            ]),
      ),
    );
  }
}
