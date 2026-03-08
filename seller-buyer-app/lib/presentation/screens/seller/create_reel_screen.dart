import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../widgets/gogo_button.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});
  @override State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  XFile?  _video;
  XFile?  _thumb;
  final   _captionCtrl = TextEditingController();
  bool    _uploading = false;
  double  _progress = 0;
  String? _linkedProductId;
  String? _linkedProductTitle;

  @override void dispose() { _captionCtrl.dispose(); super.dispose(); }

  Future<void> _pickVideo() async {
    final v = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (v != null) setState(() => _video = v);
  }

  Future<void> _pickThumb() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 85,
    );
    if (img != null) setState(() => _thumb = img);
  }

  Future<void> _publish() async {
    if (_video == null) return;
    setState(() { _uploading = true; _progress = 0.1; });

    try {
      final api = getIt<ApiClient>();

      // 1. Загружаем видео
      setState(() => _progress = 0.3);
      final videoUrl = await _uploadFile(api, _video!.path, isVideo: true);

      // 2. Загружаем превью если выбрано
      String? thumbUrl;
      if (_thumb != null) {
        setState(() => _progress = 0.6);
        thumbUrl = await _uploadFile(api, _thumb!.path, isVideo: false);
      }

      // 3. Создаём рилс
      setState(() => _progress = 0.85);
      await api.createReel(
        videoUrl: videoUrl,
        thumbUrl: thumbUrl,
        title: _captionCtrl.text.trim().isNotEmpty ? _captionCtrl.text.trim() : 'Мой рилс',
        productId: _linkedProductId,
      );

      setState(() => _progress = 1.0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎬 Рилс опубликован!'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<String> _uploadFile(ApiClient api, String path, {required bool isVideo}) async {
    if (isVideo) {
      // uploadVideo через FormData
      final url = await api.uploadVideo(path);
      return url;
    } else {
      return api.uploadImage(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Создать рилс',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        foregroundColor: isDark ? AppColors.textPrimary : Colors.black,
        elevation: 0,
      ),
      body: _uploading ? _buildUploadProgress() : _buildForm(isDark),
    );
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🎬', style: TextStyle(fontSize: 64)),
          SizedBox(height: 24.h),
          Text(
            _progress < 0.5 ? 'Загружаем видео...'
              : _progress < 0.8 ? 'Обрабатываем...'
              : 'Публикуем...',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: AppColors.bgCard,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 8.h),
          Text('${(_progress * 100).toInt()}%',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp)),
        ]),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    final cardColor = isDark ? AppColors.bgCard : Colors.white;

    return ListView(padding: EdgeInsets.all(16.w), children: [

      // Видео пикер
      GestureDetector(
        onTap: _pickVideo,
        child: Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _video != null ? AppColors.accent : AppColors.border,
              width: _video != null ? 1.5 : 1,
            ),
          ),
          child: _video == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 60.w, height: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.video_library_outlined,
                    color: AppColors.accent, size: 28.sp),
                ),
                SizedBox(height: 12.h),
                Text('Выбрать видео',
                  style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text('MP4, MOV · до 60 сек · макс. 200 МБ',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle, color: AppColors.green, size: 32),
                SizedBox(width: 12.w),
                Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Видео выбрано',
                    style: TextStyle(color: AppColors.green,
                      fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  Text(File(_video!.path).uri.pathSegments.last,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  TextButton(
                    onPressed: _pickVideo,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero,
                      minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Заменить',
                      style: TextStyle(color: AppColors.accent, fontSize: 12.sp)),
                  ),
                ]),
              ]),
        ),
      ),

      SizedBox(height: 12.h),

      // Превью (опционально)
      GestureDetector(
        onTap: _pickThumb,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: cardColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            if (_thumb != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(File(_thumb!.path),
                  width: 44.w, height: 44.w, fit: BoxFit.cover),
              )
            else
              Container(width: 44.w, height: 44.w,
                decoration: BoxDecoration(color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8.r)),
                child: Icon(Icons.image_outlined,
                  color: AppColors.textMuted, size: 22.sp)),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_thumb != null ? 'Превью выбрано' : 'Добавить обложку',
                style: TextStyle(
                  color: _thumb != null ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 14.sp, fontWeight: FontWeight.w500)),
              Text('необязательно — авто-кадр из видео',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
            ])),
            Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14.sp),
          ]),
        ),
      ),

      SizedBox(height: 16.h),

      // Подпись
      Text('ПОДПИСЬ',
        style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp,
          fontWeight: FontWeight.w600, letterSpacing: 1)),
      SizedBox(height: 8.h),
      TextField(
        controller: _captionCtrl,
        maxLines: 3, maxLength: 300,
        style: TextStyle(
          color: isDark ? AppColors.textPrimary : Colors.black,
          fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Расскажите о товаре...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
          filled: true, fillColor: cardColor,
          contentPadding: EdgeInsets.all(14.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
          counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 10.sp),
        ),
      ),

      SizedBox(height: 14.h),

      // Привязать товар
      GestureDetector(
        onTap: () {
          // TODO: открыть список товаров продавца
        },
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: cardColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Icon(Icons.local_offer_outlined, color: AppColors.textMuted, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(child: Text(
              _linkedProductTitle ?? 'Привязать товар',
              style: TextStyle(
                color: _linkedProductTitle != null
                  ? (isDark ? AppColors.textPrimary : Colors.black)
                  : AppColors.textMuted,
                fontSize: 14.sp))),
            Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14.sp),
          ]),
        ),
      ),

      SizedBox(height: 28.h),

      GogoButton(
        label: 'Опубликовать рилс 🎬',
        onPressed: _video != null ? _publish : null,
      ),

      SizedBox(height: 40.h),
    ]);
  }
}
