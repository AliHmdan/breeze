import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/CategoryItemsGridPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/restaurant_details_mapper.dart';
import 'rd_discount_section.dart';
import 'rd_most_popular_section.dart';

class RDSectionsSliverList extends StatelessWidget {
  const RDSectionsSliverList({
    super.key,
    required this.restaurantId,
    required this.isRestaurantOpen,
    required this.categories,
    required this.itemsByCategory,
    required this.categoryKeys,
    required this.imageUrl,
    required this.onContentSizeMayChange,
  });

  final int restaurantId;
  final bool isRestaurantOpen;

  final List<String> categories;
  final List<List<MenuItem>> itemsByCategory;
  final List<GlobalKey> categoryKeys;

  final String Function(String? raw) imageUrl;
  final VoidCallback onContentSizeMayChange;

  Future<void> _openItem(BuildContext context, MenuItem item) async {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final desc = context.pick(ar: item.descriptionAr ?? "", en: item.descriptionEn ?? "");
    final img = imageUrl(item.image);

    await showAddOrderDialog(
      context,
      isRestaurantOpen: isRestaurantOpen,
      restaurantId: restaurantId,
      menuItemId: item.id,
      title: title,
      price: item.effectivePrice,
      oldPrice: (item.priceBefore > 0 ? item.priceBefore : item.price),
      imagePathOrUrl: img.isNotEmpty ? img : "assets/images/shawarma_box.png",
      description: desc,
      extraMeals: item.mealExtras,
      extraGroups: item.extrasGrouped,
    );

    if (context.mounted) {
      try {
        context.read<CartCubit>().loadCart();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = [categories.length, itemsByCategory.length, categoryKeys.length].reduce((a, b) => a < b ? a : b);

    bool _isOffersTitle(String t) => t.toLowerCase().contains("offer") || t.contains("العروض");

    bool _isMostPopularTitle(String t) => t.toLowerCase().contains("most popular") || t.contains("الأكثر طلباً");

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),

        SliverToBoxAdapter(
          child: Column(
            children: List.generate(count, (i) {
              final title = categories[i];
              final items = itemsByCategory[i];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(key: categoryKeys[i], height: 1),
                  if (_isOffersTitle(title))
                    RDDiscountSection(items: items, fullImageUrl: (raw) => imageUrl(raw), onTap: (it) => _openItem(context, it))
                  else if (_isMostPopularTitle(title))
                    RDMostPopularSection(restaurantId: restaurantId, items: items, isRestaurantOpen: isRestaurantOpen, imageUrl: imageUrl)
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomTitleSection(
                            title: title,
                            all: "common.all".tr(),
                            icon: Icons.arrow_forward_ios,
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryItemsGridPage(
                                    restaurant_id: restaurantId,
                                    title: title,
                                    items: items,
                                    isRestaurantOpen: isRestaurantOpen,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 200.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsetsDirectional.only(start: 20),
                            itemCount: items.length,
                            itemBuilder: (context, x) {
                              final it = items[x];
                              final img = imageUrl(it.image);

                              final mapped = RestaurantDetailsMapper.mapMenuItemToHomeModel(it: it, imageUrl: img);

                              return GestureDetector(
                                onTap: () => _openItem(context, it),
                                child: Container(
                                  width: 142.w,
                                  margin: EdgeInsetsDirectional.only(end: x == items.length - 1 ? 0 : 8.w),
                                  child: PopularItemCard(item: mapped, isRestaurantOpen: isRestaurantOpen),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              );
            }),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }
}
