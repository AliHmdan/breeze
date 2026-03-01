import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:breezefood/features/notifications/presentation/ui/notifications_screen.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedAvatar extends StatelessWidget {
  final String? url; // path من API (uploads/avatars/..)
  final double size; // قطر الصورة
  final String fallbackAsset; // صورة افتراضية
  final VoidCallback? onTap;

  const CachedAvatar({
    super.key,
    required this.url,
    this.size = 40,
    this.fallbackAsset = 'assets/images/01.jpg',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final full = UrlHelper.toFullUrl(url); // ✅ استخدم UrlHelper تبعك

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: ClipOval(
        child: SizedBox(
          width: size.w,
          height: size.w,
          child: (full == null || full.isEmpty)
              ? Image.asset(fallbackAsset, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: full,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 120),
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      Image.asset(fallbackAsset, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

class CustomAppbarHome extends StatelessWidget {
  final String title; // ✅ جديد: النص الأساسي (طرطوس / العنوان)
  final String? subtitle; // ✅ اختياري: تلميح تحت العنوان
  final String? image;
  final IconData? icon;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLocationTap;

  const CustomAppbarHome({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.icon,
    this.avatarUrl,
    this.onProfileTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // InkWell(
        //   onTap: onProfileTap,
        //   child: BlocBuilder<ProfileCubit, ProfileState>(
        //     builder: (context, st) {
        //       final path = st.maybeWhen(
        //         loaded: (user, _, __, ___, ____, _____) => user.profileImage,
        //         orElse: () => null,
        //       );
        //
        //       final url = UrlHelper.toFullUrl(path);
        //
        //       return CircleAvatar(
        //         radius: 20.r,
        //         backgroundColor: AppColor.black,
        //         child: ClipOval(
        //           child: SizedBox(
        //             width: 40.w,
        //             height: 40.w,
        //             child: (url == null || url.isEmpty)
        //                 ? Container(
        //                     color: Colors.grey.shade200,
        //                     child: Center(
        //                       child: Icon(
        //                         Icons.person_outline,
        //                         size: 20,
        //                         color: Colors.grey.shade600,
        //                       ),
        //                     ),
        //                   )
        //                 : CachedNetworkImage(
        //                     imageUrl: url,
        //                     fit: BoxFit.cover,
        //                     placeholder: (_, __) => const Center(
        //                       child: SizedBox(
        //                         width: 14,
        //                         height: 14,
        //                         child: CircularProgressIndicator(
        //                           strokeWidth: 2,
        //                         ),
        //                       ),
        //                     ),
        //                     errorWidget: (_, __, ___) => Container(
        //                       color: Colors.grey.shade200,
        //                       child: Center(
        //                         child: Icon(
        //                           Icons.person_outline,
        //                           size: 20,
        //                           color: Colors.grey.shade600,
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),

        // ✅ العنوان + سطر تلميح
        InkWell(
          onTap: onLocationTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image != null)
                      SvgPicture.asset(
                        image!,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        width: 20,
                        height: 20,
                      ),
                    SizedBox(width: image != null ? 6.w : 0),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (icon != null)
                      Icon(icon, color: colorScheme.onSurface.withOpacity(0.7), size: 22.sp),
                  ],
                ),

                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<NotificationCubit>(),
                  child: NotificationPage(),
                ),
              ),
            );
          },
          child: Container(
            width: 35.w,
            height: 35.h,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline, width: 2),
            ),
            child: SvgPicture.asset(
              'assets/icons/notification.svg',
              color: colorScheme.onSurface,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String? url;
  const _AvatarImage({this.url});

  @override
  Widget build(BuildContext context) {
    final full = UrlHelper.toFullUrl(url);

    if (full == null || full.isEmpty) {
      return Image.asset(
        'assets/images/01.jpg',
        width: 40.w,
        height: 40.h,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      full,
      width: 40.w,
      height: 40.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/01.jpg',
        width: 40.w,
        height: 40.h,
        fit: BoxFit.cover,
      ),
    );
  }
}
