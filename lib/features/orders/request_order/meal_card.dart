import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealCard extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  final Widget? counter; // ✅ بدل showCounter/qty

  const MealCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.counter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.only(end: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                height: 60.h,
                width: 60.w,
                child: ClipRRect(
                  borderRadius: const BorderRadiusDirectional.all(
                    Radius.circular(12),
                  ),
                  child: _MealImage(image: image),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSubTitle(
                      subtitle: name,
                      color: colorScheme.onSurface,
                      fontsize: 14.sp,
                    ),
                    const SizedBox(height: 4),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Price : ",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 14.sp,
                            ),
                          ),
                          TextSpan(
                            text: context.syp(price),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ العداد من برا
              if (counter != null) ...[const SizedBox(width: 10), counter!],
            ],
          ),

          // PositionedDirectional(bottom: 5,end: 10,child: CustomSubTitle(subtitle: " <<<<<Delete", color: AppColor.red, fontsize: 12.sp))
        ],
      ),
    );
  }
}

class _MealImage extends StatelessWidget {
  final String image;
  const _MealImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final raw = image.trim();
    final fullUrl = UrlHelper.toFullUrl(raw);

    if (fullUrl != null) {
      return Image.network(
        fullUrl,
        width: 100.w,
        height: 105.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final asset = raw.isNotEmpty ? raw : "assets/images/shawarma_box.png";
    return Image.asset(
      asset,
      width: 100.w,
      height: 105.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      "assets/images/shawarma_box.png",
      width: 100.w,
      height: 105.h,
      fit: BoxFit.cover,
    );
  }
}
