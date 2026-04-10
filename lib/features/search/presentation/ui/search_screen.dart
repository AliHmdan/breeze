import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/app/bloc/app_cubit.dart' show AppCubit;
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/search/data/models/search_response.dart';
import 'package:breezefood/features/search/presentation/cubit/search_cubit.dart';
import 'package:breezefood/features/search/presentation/cubit/search_state.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatefulWidget {
  final int? restaurantId;
  const Search({Key? key, this.restaurantId}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _searchFieldKey = GlobalKey();

  late final SearchCubit searchCubit;

  final List<String> searchTags = [];

  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    searchCubit = getIt<SearchCubit>();
    searchCubit.setRestaurantId(widget.restaurantId); // ✅ مهم

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchCubit.loadHistory();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => showSuggestions = true);
        _filterSuggestions(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterSuggestions(String input) {
    final q = input.trim().toLowerCase();
    final history = searchCubit.state.history;

    final base = {...history}.toList();

    setState(() {
      showSuggestions = true;
      filteredSuggestions = base.where((s) => s.toLowerCase().contains(q) && !searchTags.contains(s)).toList();
    });
  }

  void _addTag(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    if (!searchTags.contains(t)) setState(() => searchTags.add(t));
  }

  void _removeTag(String tag) => setState(() => searchTags.remove(tag));

  void _applySuggestionToField(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    setState(() => showSuggestions = false);
  }

  void _doSearchNow() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    _addTag(q);
    setState(() => showSuggestions = false);
    _focusNode.unfocus();

    searchCubit.search(q);
  }
  // ========================= Restaurant Block =========================

  Widget _apiRestaurantBlock(SearchBlock block) {
    final r = block.restaurant;
    final isOpen = r.isOpen;

    final ratingAvg = (r.rating?.avg ?? 0).toDouble();
    final ratingCount = r.rating?.count ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () async {
                  final cartCubit = context.read<CartCubit>();

                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cartCubit,
                        child: ResturantDetails(restaurant_id: r.id),
                      ),
                    ),
                  );

                  if (changed == true && context.mounted) {
                    await cartCubit.loadCart(silent: false);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: AppNetworkImage(
                        path: r.logo,
                        height: 35.h,
                        width: 35.w,
                        fit: BoxFit.cover,
                        fallback: Container(
                          height: 35.h,
                          width: 35.w,
                          decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Icon(Icons.store, color: AppColor.gry, size: 20.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200.w),
                      child: CustomSubTitle(subtitle: r.name, color: AppColor.white, fontsize: 14.sp),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: AppColor.yellow, size: 16.sp),
                  SizedBox(width: 4.w),
                  CustomSubTitle(subtitle: ratingAvg.toStringAsFixed(1), color: AppColor.white, fontsize: 14.sp),
                  SizedBox(width: 6.w),
                  CustomSubTitle(subtitle: "$ratingCount", color: Colors.white70, fontsize: 12.sp),
                ],
              ),
            ],
          ),
        ),

        // ================= Items =================
        SizedBox(
          height: 210.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: block.items.length,
            physics: block.items.length <= 2 ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final it = block.items[index];

              final title = context.pick(ar: it.names.ar, en: it.names.en);

              final hasDiscount = (it.hasDiscount ?? false) == true;

              final before = (it.priceBefore ?? double.tryParse(it.basePrice) ?? 0).toDouble();

              final after = (it.priceAfter ?? before).toDouble();

              final percent = double.tryParse(it.discountValue ?? "0") ?? 0;

              return Padding(
                padding: EdgeInsetsDirectional.only(start: index == 0 ? 16.w : 0, end: index == block.items.length - 1 ? 16.w : 12.w),
                child: SizedBox(
                  width: 150.w,
                  child: GestureDetector(
                    onTap: () {
                      final cartCubit = context.read<CartCubit>();

                      showAddOrderDialog(
                        context,
                        // cartCubit: cartCubit,
                        restaurantId: r.id,
                        menuItemId: it.id,
                        title: title,
                        price: hasDiscount ? after : before,
                        oldPrice: before,
                        imagePathOrUrl: it.imageUrl ?? "",
                        description: "",
                        extraMeals: const <MenuExtra>[],
                        isRestaurantOpen: isOpen,
                        extraGroups: const <ExtraGrouped>[],
                      );
                    },
                    child: _SearchApiItemCard(
                      title: title,
                      imageUrl: it.imageUrl ?? "",
                      hasDiscount: hasDiscount,
                      priceBefore: before,
                      priceAfter: after,
                      discountPercent: percent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: searchCubit,
      builder: (context, s) {
        final isDark = AppCubit.get(context).isThemDark();
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColor.Dark,

            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // icons color
          ),
          child: Scaffold(
            // backgroundColor: AppColor.Dark,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        CustomArrow(onTap: () => Navigator.pop(context), color: AppColor.white, background: Colors.transparent),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            key: _searchFieldKey,
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _controller,
                              onTap: () => _filterSuggestions(_controller.text),
                              onChanged: (v) {
                                _filterSuggestions(v);
                                searchCubit.searchDebounced(v);
                              },
                              onSubmitted: (_) => _doSearchNow(),
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 14.sp,
                                fontFamily: context.isAr ? 'Cairo' : 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.w),
                                filled: true,
                                fillColor: AppColor.search,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset('assets/icons/search.svg', color: AppColor.white, width: 20.w, height: 20.h),
                                ),
                                hintText: "search.hint".tr(),
                                hintStyle: TextStyle(
                                  color: AppColor.LightActive,
                                  fontSize: 14.sp,
                                  fontFamily: context.isAr ? 'Cairo' : 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // InkWell(
                        //   onTap: _doSearchNow,
                        //   borderRadius: BorderRadius.circular(50.0.r),
                        //   child: Container(
                        //     padding: const EdgeInsets.all(8.0),
                        //     decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(50.0.r)),
                        //     child: SvgPicture.asset('assets/icons/boxsearch.svg', width: 20.w, height: 20.h, color: AppColor.white),
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if(s.results.length>0)
                    Expanded(
                      child: ListView.builder(itemCount: s.results.length, itemBuilder: (context, i) => _apiRestaurantBlock(s.results[i])),
                    )
                    else Center(child:Text("هذه الوجبة غير موجودة")),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========================= Card =========================

class _SearchApiItemCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool hasDiscount;
  final double priceBefore;
  final double priceAfter;
  final double discountPercent;

  const _SearchApiItemCard({
    required this.title,
    required this.imageUrl,
    required this.hasDiscount,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    final beforeTxt = context.money(priceBefore, decimals: 0);
    final afterTxt = context.money(priceAfter, decimals: 0);

    final showDiscount = hasDiscount && discountPercent > 0;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 150.w,
                height: 150.w,
                child: AppNetworkImage(path: imageUrl, fit: BoxFit.cover, radius: BorderRadius.circular(16.r), height: 150.w),
              ),
              if (showDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.r)),
                    child: Text(
                      "-${discountPercent.toStringAsFixed(0)}%",
                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColor.light, fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            showDiscount ? afterTxt : beforeTxt,
            style: TextStyle(color: showDiscount ? Colors.red : AppColor.light, fontWeight: FontWeight.w800, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
