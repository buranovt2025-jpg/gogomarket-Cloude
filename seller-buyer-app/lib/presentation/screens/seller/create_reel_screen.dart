import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/gogo_button.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});
  @override State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  XFile? _video;
  final _captionCtrl = TextEditingController();
  String? _linkedProduct;

  Future<void> _pickVideo() async {
    final v = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    if (v != null) setState(() => _video = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Создать рилс', style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(padding: EdgeInsets.all(16.w), children: [
        // Video picker
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            height: 200.h,
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: _video == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.video_library_outlined, color: AppColors.textMuted, size: 48.sp),
                  SizedBox(height: 10.h),
                  Text('Выбрать видео (до 60 сек)', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
                  SizedBox(height: 4.h),
                  Text('MP4, MOV · макс. 200 МБ', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, color: AppColors.green, size: 40),
                  SizedBox(height: 8.h),
                  Text('Видео выбрано ✓', style: TextStyle(color: AppColors.green, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  TextButton(onPressed: _pickVideo, child: Text('Заменить', style: TextStyle(color: AppColors.accent, fontSize: 12.sp))),
                ]),
          ),
        ),
        SizedBox(height: 16.h),

        // Caption
        Text('ПОДПИСЬ', style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1)),
        SizedBox(height: 8.h),
        TextField(
          controller: _captionCtrl,
          maxLines: 3, maxLength: 300,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Расскажите о товаре...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            filled: true, fillColor: AppColors.bgCard,
            contentPadding: EdgeInsets.all(14.w),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 10.sp),
          ),
        ),
        SizedBox(height: 14.h),

        // Link product
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              const Icon(Icons.local_offer_outlined, color: AppColors.textMuted, size: 20),
              SizedBox(width: 10.w),
              Expanded(child: Text(_linkedProduct ?? 'Привязать товар', style: TextStyle(color: _linkedProduct != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 14.sp))),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
            ]),
          ),
        ),
        SizedBox(height: 24.h),

        GogoButton(label: 'Опубликовать рилс 🎬', onPressed: _video != null ? () {} : null),
        SizedBox(height: 40.h),
      ]),
    );
  }
}
