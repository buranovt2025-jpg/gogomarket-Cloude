import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';

class SellerVerificationScreen extends StatefulWidget {
  const SellerVerificationScreen({super.key});
  @override State<SellerVerificationScreen> createState() => _State();
}

class _State extends State<SellerVerificationScreen> {
  final _innCtrl  = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _picker   = ImagePicker();

  File? _passportFront;
  File? _passportBack;
  File? _selfie;
  bool _loading = false;
  int _step = 0; // 0-данные, 1-паспорт, 2-селфи, 3-готово

  @override void dispose() { _innCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pick(String type) async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return;
    setState(() {
      if (type == 'front')  _passportFront = File(img.path);
      if (type == 'back')   _passportBack  = File(img.path);
      if (type == 'selfie') _selfie        = File(img.path);
    });
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await getIt<ApiClient>().submitVerification(
        inn:           _innCtrl.text.trim(),
        fullName:      _nameCtrl.text.trim(),
        passportFront: _passportFront!,
        passportBack:  _passportBack!,
        selfie:        _selfie!,
      );
      setState(() => _step = 3);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.red, content: Text(msg.replaceAll('Exception: ', ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Верификация продавца'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: _step == 3 ? _buildSuccess() : _buildForm(),
    );
  }

  // ── Успех ─────────────────────────────────────────────────────────────────
  Widget _buildSuccess() => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100.w, height: 100.w,
          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          child: Icon(Icons.check, color: Colors.white, size: 52.sp),
        ),
        SizedBox(height: 24.h),
        Text('Документы отправлены!', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 12.h),
        Text(
          'Мы проверим ваши документы в течение 1-2 рабочих дней и уведомим вас.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted, height: 1.5),
        ),
        SizedBox(height: 32.h),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Готово'),
          )),
      ]),
    ),
  );

  // ── Форма ─────────────────────────────────────────────────────────────────
  Widget _buildForm() => Column(children: [
    // Прогресс
    Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(children: List.generate(3, (i) => Expanded(
        child: Container(
          height: 4.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: i <= _step ? AppColors.accent : AppColors.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ))),
    ),

    Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: _step == 0 ? _buildStep0() : _buildStep1(),
      ),
    ),

    // Кнопка
    Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _nextStep,
          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 54.h)),
          child: _loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(_step == 2 ? 'Отправить' : 'Далее',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
        )),
    ),
  ]);

  void _nextStep() {
    if (_step == 0) {
      if (_innCtrl.text.length < 9) { _showError('Введите корректный ИНН (9 цифр)'); return; }
      if (_nameCtrl.text.length < 5) { _showError('Введите полное имя'); return; }
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_passportFront == null || _passportBack == null) {
        _showError('Загрузите обе стороны паспорта'); return;
      }
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (_selfie == null) { _showError('Загрузите селфи с паспортом'); return; }
      _submit();
    }
  }

  // ── Шаг 0: Данные ─────────────────────────────────────────────────────────
  Widget _buildStep0() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Личные данные', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800)),
    SizedBox(height: 6.h),
    Text('Введите данные как в паспорте', style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
    SizedBox(height: 24.h),

    _label('ИНН / ПИНФЛ'),
    _field(_innCtrl, 'Введите 9-значный ИНН', TextInputType.number, maxLen: 9),
    SizedBox(height: 16.h),

    _label('Полное имя'),
    _field(_nameCtrl, 'Фамилия Имя Отчество', TextInputType.name),
    SizedBox(height: 24.h),

    Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: AppColors.accent, size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(child: Text(
          'Данные проверяются через базу налоговой службы. '
          'Убедитесь что ИНН и имя совпадают с вашим паспортом.',
          style: TextStyle(color: AppColors.accent, fontSize: 12.sp, height: 1.5),
        )),
      ]),
    ),
  ]);

  // ── Шаг 1 и 2: Документы ──────────────────────────────────────────────────
  Widget _buildStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(_step == 1 ? 'Фото паспорта' : 'Селфи с паспортом',
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800)),
    SizedBox(height: 6.h),
    Text(
      _step == 1
        ? 'Загрузите чёткие фото обеих сторон паспорта'
        : 'Сфотографируйтесь держа паспорт рядом с лицом',
      style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
    ),
    SizedBox(height: 24.h),

    if (_step == 1) ...[
      _uploadCard('Лицевая сторона', _passportFront, () => _pick('front'),
        icon: Icons.badge_outlined),
      SizedBox(height: 12.h),
      _uploadCard('Обратная сторона', _passportBack, () => _pick('back'),
        icon: Icons.credit_card_outlined),
    ] else ...[
      _uploadCard('Селфи с паспортом', _selfie, () => _pick('selfie'),
        icon: Icons.face_outlined, tall: true),
      SizedBox(height: 16.h),
      _tipRow(Icons.lightbulb_outline, 'Держите паспорт рядом с лицом'),
      _tipRow(Icons.wb_sunny_outlined, 'Хорошее освещение'),
      _tipRow(Icons.remove_red_eye_outlined, 'Данные на паспорте должны читаться'),
    ],
  ]);

  Widget _tipRow(IconData icon, String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(children: [
      Icon(icon, size: 16.sp, color: AppColors.textMuted),
      SizedBox(width: 8.w),
      Text(text, style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
    ]),
  );

  Widget _uploadCard(String label, File? file, VoidCallback onTap,
      {IconData icon = Icons.upload_outlined, bool tall = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: tall ? 200.h : 150.h,
        decoration: BoxDecoration(
          color: file != null ? null : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: file != null ? AppColors.green : AppColors.accent.withOpacity(0.4),
            width: file != null ? 2 : 1.5,
            style: file != null ? BorderStyle.solid : BorderStyle.solid,
          ),
          image: file != null ? DecorationImage(
            image: FileImage(file), fit: BoxFit.cover,
          ) : null,
        ),
        child: file != null
          ? Stack(children: [
              Positioned(
                top: 8.h, right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                ),
              ),
            ])
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 52.w, height: 52.w,
                decoration: BoxDecoration(
                  color: AppColors.accentBg, shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accent, size: 26.sp),
              ),
              SizedBox(height: 10.h),
              Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 4.h),
              Text('Нажмите чтобы выбрать фото',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
            ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
  );

  Widget _field(TextEditingController ctrl, String hint,
      TextInputType type, {int? maxLen}) =>
    TextField(
      controller: ctrl,
      keyboardType: type,
      maxLength: maxLen,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
}
