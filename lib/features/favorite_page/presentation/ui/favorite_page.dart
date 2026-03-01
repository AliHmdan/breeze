import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favorite_page/data/model/favorites_response.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../profile/presentation/widget/custom_appbar_profile.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  late final FavoritesCubit cubit;

  bool _removingNow = false;
  bool _firstLoadDone = false; // ✅ أول مرة بس

  @override
  void initState() {
    super.initState();
    cubit = context.read<FavoritesCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.load();
      _firstLoadDone = true;
    });
  }

  Future<void> _handleRefresh() async {
    // ✅ Pull-to-refresh عادي (إذا بدك بدون EasyLoading خليه هيك)
    await cubit.load();
  }

  Future<void> _deleteFavorite(FavoriteItem item) async {
    _removingNow = true;
    EasyLoading.show(status: "favorites.removing".tr());

    await cubit.remove(item);
  }

  Widget _buildOrderCard(FavoriteItem item) {
    final imageUrl = UrlHelper.toFullUrl(item.image);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResturantDetails(restaurant_id: item.restaurantId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// صورة المنتج
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (imageUrl ?? "").trim().isEmpty
                      ? Container(
                          width: 60.w,
                          height: 60.h,
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.fastfood,
                              color: colorScheme.onSurface,
                              size: 30.sp,
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60.w,
                            height: 60.h,
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.fastfood,
                                color: colorScheme.onSurface,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                /// النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// اسم المنتج
                      Text(
                        item.nameAr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// اسم المطعم
                      Text(
                        item.restaurantName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// السعر
                      Text(
                        "${item.price.toStringAsFixed(2)} ${"common.currency".tr()}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            /// التاريخ
            Text(
              "Added to favorites",
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 14),

            /// Divider خفيف جداً
            Divider(
              color: colorScheme.outline.withOpacity(0.25),
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          state.maybeWhen(
            loading: () {
              // ✅ لا تعرض Loading بالـ UI إلا أول مرة (لأن silent refresh ما بيعمل loading أصلاً)
              if (_firstLoadDone) return;
            },
            loaded: (_) {
              EasyLoading.dismiss();

              if (_removingNow) {
                _removingNow = false;
                EasyLoading.showSuccess("favorites.removed".tr());
              }
            },
            error: (msg) {
              _removingNow = false;
              EasyLoading.dismiss();
              EasyLoading.showError(msg);
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final items = state.maybeWhen(
              loaded: (items) => items,
              orElse: () => const <FavoriteItem>[],
            );

            // ✅ لا نعرض spinner إلا لو فعلاً state=loading (وهذا بيصير فقط بالـ load العادي)
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  CustomAppbarProfile(
                    ontap: () {},
                    title: "favorites.title".tr(),
                  ),
                  if (isLoading && items.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (items.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.favorite_border,
                          //   color: colorScheme.onSurface,
                          //   size: 50,
                          // ),
                          // SizedBox(height: 10.h),
                          Text(
                            "favorites.empty".tr(),
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontFamily:
                                  Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar'
                                  ? 'Cairo'
                                  : 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final f in items) _buildOrderCard(f),
                        const SizedBox(height: 40),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
