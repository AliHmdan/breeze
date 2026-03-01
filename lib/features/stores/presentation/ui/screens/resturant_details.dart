import 'package:breezefood/android_swipe_back.dart';
import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/CategoryItemsGridPage.dart';
import 'package:breezefood/features/stores/presentation/ui/widget/discout_meal_section.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_sheet.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/ratings/presentation/ui/rate_dialog.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/most_popular_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ResturantDetails extends StatefulWidget {
//   final int restaurant_id;
//   final int? initialMenuItemId;

//   const ResturantDetails({
//     super.key,
//     required this.restaurant_id,
//     this.initialMenuItemId,
//   });

//   @override
//   State<ResturantDetails> createState() => _ResturantDetailsState();
// }

// class _ResturantDetailsState extends State<ResturantDetails> {
//   int selectedCategoryIndex = 0;

//   final GlobalKey<NestedScrollViewState> _nestedKey = GlobalKey();

//   late final ScrollController _outerController = ScrollController();
//   ScrollController? _innerController;

//   final List<GlobalKey> _categoryKeys = [];
//   final List<double> _categoryOffsets = [];
//   int _dbgTick = 0;

//   void _debugScroll() {
//     if ((_dbgTick++ % 12) != 0) return; // throttle
//     final outer = _outerController.hasClients ? _outerController.offset : -1;
//     final inner = _innerController?.hasClients == true
//         ? _innerController!.offset
//         : -1;
//     debugPrint(
//       "🧭 outer=$outer | inner=$inner | selected=$selectedCategoryIndex",
//     );
//   }

//   void _debugPrintOffsets() {
//     debugPrint("📌 categoryOffsets count=${_categoryOffsets.length}");
//     for (int i = 0; i < _categoryOffsets.length; i++) {
//       debugPrint("   [$i] ${_categoryOffsets[i]}");
//     }
//   }

//   bool _isProgrammaticScroll = false;
//   double get _stickyHeaderHeight => 210.h;

//   void _onInnerScroll() {
//     if (_isProgrammaticScroll) return;
//     if (_categoryOffsets.isEmpty || _innerController == null) return;

//     final viewTop = _innerController!.offset + _stickyHeaderHeight + 8.h;

//     int newIndex = 0;
//     for (int i = 0; i < _categoryOffsets.length; i++) {
//       if (_categoryOffsets[i] <= viewTop) newIndex = i;
//     }

//     if (newIndex != selectedCategoryIndex) {
//       setState(() {
//         selectedCategoryIndex = newIndex;
//         _activeCategoryIndex = newIndex;
//       });
//     }
//   }

//   late final RestaurantDetailsCubit cubit;
//   late final MostPopularCubit mostPopularCubit;
//   bool _isRestaurantOpen = true; // ✅ هنا
//   int _activeCategoryIndex = 0;
//   bool _headerReady = false;
//   String _headerUrl = "";
//   final Set<String> _preloadedImages = {};
//   Future<void> _refreshPage() async {
//     await Future.wait([
//       cubit.load(widget.restaurant_id),
//       mostPopularCubit.load(widget.restaurant_id),
//       context.read<CartCubit>().loadCart(),
//     ]);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _calculateCategoryOffsets();
//     });
//   }

//   Future<void> _precacheImage(String url) async {
//     if (url.isEmpty) return;
//     if (_preloadedImages.contains(url)) return;

//     try {
//       await precacheImage(
//         CachedNetworkImageProvider(url, cacheManager: AppCacheManager.instance),
//         context,
//       );

//       _preloadedImages.add(url);
//     } catch (_) {}
//   }

//   @override
//   void initState() {
//     super.initState();

//     cubit = getIt<RestaurantDetailsCubit>();
//     mostPopularCubit = getIt<MostPopularCubit>();

//     // اسمع على outer بس للتشخيص (اختياري)
//     _outerController.addListener(_debugScroll);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       cubit.load(widget.restaurant_id);
//       mostPopularCubit.load(widget.restaurant_id);
//       context.read<CartCubit>().loadCart();

//       _attachInnerController(); // ✅
//     });
//   }

//   void _attachInnerController() {
//     final st = _nestedKey.currentState;
//     if (st == null) return;

//     final inner = st.innerController;
//     if (_innerController == inner) return;

//     _innerController?.removeListener(_onInnerScroll);
//     _innerController = inner;
//     _innerController!.addListener(_onInnerScroll);

//     // احسب offsets أول مرة بعد الربط
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _calculateCategoryOffsets();
//     });
//   }

//   @override
//   void dispose() {
//     _innerController?.removeListener(_onInnerScroll);
//     _outerController.removeListener(_debugScroll);

//     _outerController.dispose();
//     cubit.close();
//     mostPopularCubit.close();
//     super.dispose();
//   }

//   void _calculateCategoryOffsets() {
//     _categoryOffsets.clear();
//     if (_innerController == null) return;

//     for (final key in _categoryKeys) {
//       final ctx = key.currentContext;
//       if (ctx == null) {
//         _categoryOffsets.add(double.infinity);
//         continue;
//       }

//       final ro = ctx.findRenderObject();
//       if (ro == null) {
//         _categoryOffsets.add(double.infinity);
//         continue;
//       }

//       final viewport = RenderAbstractViewport.of(ro);
//       if (viewport == null) {
//         _categoryOffsets.add(double.infinity);
//         continue;
//       }

//       final reveal = viewport.getOffsetToReveal(ro, 0.0);
//       _categoryOffsets.add(reveal.offset);
//     }

//     _debugPrintOffsets();
//   }

//   String _imageUrl(String? raw) {
//     if (raw == null) return "";
//     var v = raw.trim();
//     if (v.isEmpty) return "";

//     // 🚫 ignore local server temp paths
//     if (v.startsWith("C:/") ||
//         v.startsWith("C:\\") ||
//         v.contains("xampp/tmp")) {
//       return "";
//     }

//     // already full url
//     if (v.startsWith("http://") || v.startsWith("https://")) {
//       return v;
//     }

//     // ensure leading slash
//     if (!v.startsWith("/")) v = "/$v";

//     // cleanup double slashes (except protocol - already handled)
//     v = v.replaceAll(RegExp(r'/{2,}'), '/');

//     // if not under /uploads => prefix /uploads
//     if (!v.startsWith("/uploads/")) {
//       v = "/uploads$v";
//       v = v.replaceAll(RegExp(r'/{2,}'), '/');
//     }

//     return UrlHelper.toFullUrl(v) ?? "";
//   }

//   String _pickSingleLangFromMixed(String s, BuildContext context) {
//     final v = s.trim();
//     if (v.isEmpty) return "";

//     final separators = ['|', '/', '\n', ' - ', ' — ', ' – '];
//     for (final sep in separators) {
//       if (v.contains(sep)) {
//         final parts = v
//             .split(sep)
//             .map((e) => e.trim())
//             .where((e) => e.isNotEmpty)
//             .toList();
//         if (parts.length >= 2) {
//           return context.isAr ? parts.first : parts[1];
//         }
//       }
//     }
//     return v;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [BlocProvider(create: (_) => getIt<RatingSubmitCubit>())],
//       child: AndroidSwipeBack(
//         child: Scaffold(
//           extendBodyBehindAppBar: true,
//           bottomNavigationBar: SafeArea(
//             child: BottomCartAction(
//               haveOrder: null,
//               usePrimaryButton: true,
//               showCountAndTotal: true,
//               onViewCart: () async {
//                 if (!_isRestaurantOpen) {
//                   EasyLoading.showInfo(
//                     "restaurant.closed_cannot_checkout".tr(),
//                   );
//                   return;
//                 }

//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => MultiBlocProvider(
//                       providers: [
//                         BlocProvider.value(value: context.read<CartCubit>()),
//                         BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
//                       ],
//                       child: const RequestOrderScreen(),
//                     ),
//                   ),
//                 );
//                 if (context.mounted) context.read<CartCubit>().loadCart();
//               },
//             ),
//           ),
//           body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
//             bloc: cubit,
//             builder: (context, state) {
//               String headerImageUrl = "";
//               String restaurantName = "";
//               String description = "";
//               String reviewsCountText = "0";

//               String deliveryTime = "--";
//               String deliveryBase = "--";
//               String deliveryFinal = "--";

//               String ordersText = "0";
//               String avgRatingText = "0.0";

//               int? myReviewId;
//               double myUserRating = 0.0;

//               List<String> categories = [];
//               List<List<MenuItem>> itemsByCategory = [];
//               List<MenuItem> discountedItems = [];
//               state.maybeWhen(
//                 loaded: (data) {
//                   final g = data.general;

//                   final newIsOpen = g.isOpen;
//                   if (_isRestaurantOpen != newIsOpen) {
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (!mounted) return;
//                       setState(() => _isRestaurantOpen = newIsOpen);
//                       _calculateCategoryOffsets();
//                     });
//                   }

//                   restaurantName = g.name ?? '';
//                   description = _pickSingleLangFromMixed(
//                     g.description ?? "",
//                     context,
//                   );

//                   // ✅ الغلاف/اللوغو
//                   headerImageUrl = _imageUrl(g.cover ?? g.logo);
//                   if (_headerUrl != headerImageUrl) {
//                     _headerUrl = headerImageUrl;
//                     _headerReady = false;

//                     _precacheImage(_headerUrl).then((_) {
//                       if (mounted) {
//                         setState(() {
//                           _headerReady = true;
//                         });
//                       }
//                     });
//                   }
//                   final rc = g.reviewsCount;
//                   reviewsCountText = "$rc";

//                   // ✅ delivery
//                   if (g.deliveryTime > 0) deliveryTime = "${g.deliveryTime}";

//                   final del = g.delivery;
//                   if (del != null) {
//                     deliveryBase = context.money(del.baseFee, decimals: 0);
//                     deliveryFinal = context.money(del.finalFee, decimals: 0);
//                   } else {
//                     deliveryBase = context.money(g.deliveryCash, decimals: 0);
//                     deliveryFinal = context.money(g.deliveryCash, decimals: 0);
//                   }

//                   // ✅ ratings
//                   final avg = (g.avgRating > 0) ? g.avgRating : 0.0;
//                   avgRatingText = avg > 0 ? avg.toStringAsFixed(1) : "0.0";

//                   // ✅ orders
//                   if (g.totalCompletedOrders > 0) {
//                     ordersText = "${g.totalCompletedOrders}";
//                   }

//                   // ✅ sections
//                   final sections = data.restaurantMenuItems;

//                   if (_categoryKeys.length != sections.length) {
//                     _categoryKeys
//                       ..clear()
//                       ..addAll(
//                         List.generate(sections.length, (_) => GlobalKey()),
//                       );
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted) _calculateCategoryOffsets();
//                     });
//                   }

//                   categories = sections.map((e) {
//                     return context.pick(
//                       ar: e.category.nameAr,
//                       en: e.category.nameEn,
//                     );
//                   }).toList();

//                   itemsByCategory = sections.map((e) => e.items).toList();
//                   for (final section in sections) {
//                     for (final item in section.items.take(4)) {
//                       // أول 4 فقط من كل قسم
//                       final img = _imageUrl(item.image);
//                       _precacheImage(img);
//                     }
//                   }

//                   final allItems = sections.expand((s) => s.items).toList();
//                   discountedItems =
//                       allItems.where((x) => x.hasDiscount).toList()..sort(
//                         (a, b) =>
//                             b.discountPercent.compareTo(a.discountPercent),
//                       );

//                   myReviewId = data.myRating?.id;
//                   myUserRating = data.myRating?.rating ?? 0.0;
//                 },
//                 orElse: () {},
//               );

//               return RefreshIndicator(
//                 onRefresh: _refreshPage,
//                 child: NestedScrollView(
//                   key: _nestedKey,
//                   controller: _outerController,
//                   headerSliverBuilder: (context, innerBoxIsScrolled) {
//                     final showTwoPrices = deliveryBase != deliveryFinal;

//                     return [
//                       SliverOverlapAbsorber(
//                         handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                           context,
//                         ),
//                         sliver: SliverAppBar(
//                           expandedHeight: 180.h,
//                           pinned: true,
//                           automaticallyImplyLeading: false,
//                           toolbarHeight: 0,
//                           collapsedHeight: 0,
//                           backgroundColor: AppColor.Dark,
//                           flexibleSpace: FlexibleSpaceBar(
//                             background: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 _headerReady
//                                     ? AppNetworkImage(
//                                         path: headerImageUrl,
//                                         height: 180.h,
//                                         width: double.infinity,
//                                         fit: BoxFit.cover,
//                                       )
//                                     : SizedBox(
//                                         height: 180.h,
//                                         width: double.infinity,
//                                         child: Image.asset(
//                                           "assets/images/meal_breeze.jpeg", // حط صورتك هون
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),

//                                 Positioned.fill(
//                                   child: IgnorePointer(
//                                     child: Container(
//                                       decoration: const BoxDecoration(
//                                         gradient: LinearGradient(
//                                           begin: Alignment.bottomCenter,
//                                           end: Alignment.topCenter,
//                                           colors: [
//                                             Color(
//                                               0xB3000000,
//                                             ), // أسفل (70% سواد خفيف)
//                                             Color(0x66000000), // وسط خفيف جداً
//                                             Color(0x00000000), // شفاف بالأعلى
//                                           ],
//                                           stops: [0.0, 0.4, 1.0],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 PositionedDirectional(
//                                   top: MediaQuery.of(context).padding.top + 12,
//                                   start: 12,
//                                   child: CustomArrow(
//                                     color: AppColor.white,
//                                     background: AppColor.black,
//                                     colorborder: AppColor.grye,
//                                     onTap: () => Navigator.pop(context),
//                                   ),
//                                 ),

//                                 // Name Restaurant + Rating
//                                 PositionedDirectional(
//                                   bottom:
//                                       MediaQuery.of(context).padding.bottom + 5,
//                                   start: 10,
//                                   end: 10,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       /// 🔥 اسم المطعم
//                                       Text(
//                                         restaurantName,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 26.sp,
//                                           fontWeight: FontWeight.w900,
//                                           fontFamily: context.isAr
//                                               ? 'Cairo'
//                                               : 'Inter',
//                                         ),
//                                       ),

//                                       const SizedBox(height: 10),

//                                       /// ⭐ التقييم (له نقر خاص)
//                                       GestureDetector(
//                                         onTap: () async {
//                                           // 👇 نفس كود showRateDialog الموجود عندك
//                                           final reviewId = myReviewId;
//                                           final hasMyRating =
//                                               (reviewId ?? 0) > 0 &&
//                                               myUserRating > 0;

//                                           final res = await showRateDialog(
//                                             context,
//                                             currentRating: hasMyRating
//                                                 ? myUserRating
//                                                 : 3.0,
//                                             reviewId: hasMyRating
//                                                 ? reviewId
//                                                 : null,
//                                           );

//                                           if (res == null) return;

//                                           final submitCubit = context
//                                               .read<RatingSubmitCubit>();
//                                           EasyLoading.show(
//                                             status: "common.sending".tr(),
//                                           );

//                                           if (res.delete) {
//                                             if ((reviewId ?? 0) == 0) {
//                                               EasyLoading.showError(
//                                                 "reviews.no_review_to_delete"
//                                                     .tr(),
//                                               );
//                                               return;
//                                             }

//                                             await submitCubit
//                                                 .deleteRestaurantRate(
//                                                   reviewId: reviewId!,
//                                                 );

//                                             if (!mounted) return;

//                                             submitCubit.state.maybeWhen(
//                                               deleteSuccess: () async {
//                                                 EasyLoading.showSuccess(
//                                                   "reviews.delete_success".tr(),
//                                                 );
//                                                 await cubit.load(
//                                                   widget.restaurant_id,
//                                                 );
//                                               },
//                                               error: (msg) =>
//                                                   EasyLoading.showError(
//                                                     msg.tr(),
//                                                   ),
//                                               orElse: () =>
//                                                   EasyLoading.dismiss(),
//                                             );

//                                             return;
//                                           }

//                                           if (res.rating == null) {
//                                             EasyLoading.dismiss();
//                                             return;
//                                           }

//                                           await submitCubit
//                                               .submitRestaurantRate(
//                                                 restaurantId:
//                                                     widget.restaurant_id,
//                                                 rating: res.rating!,
//                                               );

//                                           if (!mounted) return;

//                                           submitCubit.state.maybeWhen(
//                                             success: () async {
//                                               EasyLoading.showSuccess(
//                                                 "reviews.rate_success".tr(),
//                                               );
//                                               await cubit.load(
//                                                 widget.restaurant_id,
//                                               );
//                                             },
//                                             error: (msg) =>
//                                                 EasyLoading.showError(msg.tr()),
//                                             orElse: () => EasyLoading.dismiss(),
//                                           );
//                                         },
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             const Icon(
//                                               Icons.star,
//                                               color: Colors.amber,
//                                               size: 16,
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               avgRatingText,
//                                               style: TextStyle(
//                                                 color: AppColor.Lightgry,
//                                                 fontSize: 13,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             SizedBox(width: 6.w),

//                                             // ✅ (2)
//                                             Text(
//                                               "($reviewsCountText)",
//                                               style: TextStyle(
//                                                 color: AppColor
//                                                     .Lightgry.withOpacity(0.9),
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 PositionedDirectional(
//                                   top: MediaQuery.of(context).padding.top + 12,
//                                   end: 12,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                     ),
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) => Search(
//                                               restaurantId:
//                                                   widget.restaurant_id,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(
//                                             0.08,
//                                           ), // شفافية
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.search,
//                                           color: Colors.white,
//                                           size: 22,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SliverPersistentHeader(
//                         pinned: true,
//                         delegate: _StickyHeaderDelegate(
//                           child: Container(
//                             color: AppColor.Dark,
//                             padding: const EdgeInsets.only(top: 9),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                   ),
//                                   child: GestureDetector(
//                                     child: CustomSubTitle(
//                                       subtitle: description,
//                                       color: AppColor.Lightgry,
//                                       fontsize: 10,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 5,
//                                     vertical: 20,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Spacer(),
//                                       Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Image.asset(
//                                             "assets/icons/motor.png",
//                                             width: 40.w,
//                                             height: 40.w,
//                                           ),
//                                           SizedBox(width: 6.w),

//                                           if (showTwoPrices) ...[
//                                             Text(
//                                               deliveryBase,
//                                               style: TextStyle(
//                                                 color: AppColor.LightActive,
//                                                 decoration:
//                                                     TextDecoration.lineThrough,
//                                                 fontSize: 12.sp,
//                                                 fontWeight: FontWeight.w800,
//                                                 fontFamily: context.isAr
//                                                     ? 'Cairo'
//                                                     : 'Inter',
//                                               ),
//                                             ),
//                                             SizedBox(width: 8.w),
//                                             Text(
//                                               deliveryFinal,
//                                               style: TextStyle(
//                                                 color: AppColor.red,
//                                                 fontSize: 12.sp,
//                                                 fontWeight: FontWeight.w900,
//                                                 fontFamily: context.isAr
//                                                     ? 'Cairo'
//                                                     : 'Inter',
//                                               ),
//                                             ),
//                                           ] else ...[
//                                             Text(
//                                               deliveryFinal,
//                                               style: TextStyle(
//                                                 color: AppColor.white,
//                                                 fontSize: 12.sp,
//                                                 fontWeight: FontWeight.w900,
//                                                 fontFamily: context.isAr
//                                                     ? 'Cairo'
//                                                     : 'Inter',
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ),

//                                       SizedBox(width: 45.w),
//                                       _divider(),
//                                       Spacer(),
//                                       Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Image.asset(
//                                             "assets/icons/time.png",
//                                             width: 40.w,
//                                             height: 40.w,
//                                           ),

//                                           SizedBox(width: 6.w),

//                                           Text(
//                                             deliveryTime == "--"
//                                                 ? "--"
//                                                 : "$deliveryTime ${"common.min".tr()}",
//                                             style: TextStyle(
//                                               color: AppColor.white,
//                                               fontSize: 12.sp,
//                                               fontWeight: FontWeight.w900,
//                                               fontFamily: context.isAr
//                                                   ? 'Cairo'
//                                                   : 'Inter',
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(width: 15.w),
//                                       Spacer(),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(height: 12),
//                                 SizedBox(
//                                   height: 45.h,

//                                   child: Stack(
//                                     children: [
//                                       /// ✅ الخط الرمادي الكامل
//                                       PositionedDirectional(
//                                         bottom: 7,
//                                         end: 0,
//                                         start: 0,
//                                         child: Container(
//                                           height: 3.h,
//                                           color: AppColor.white.withOpacity(
//                                             0.3,
//                                           ),
//                                         ),
//                                       ),

//                                       /// ✅ ليست العناصر
//                                       ListView.builder(
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 16.w,
//                                         ),
//                                         itemCount: categories.length,
//                                         itemBuilder: (context, index) {
//                                           final isSelected =
//                                               selectedCategoryIndex == index;

//                                           return GestureDetector(
//                                             onTap: () async {
//                                               if (_innerController == null)
//                                                 _attachInnerController();
//                                               if (_innerController == null)
//                                                 return;

//                                               if (_categoryOffsets.isEmpty)
//                                                 _calculateCategoryOffsets();

//                                               _isProgrammaticScroll = true;

//                                               try {
//                                                 // 1) اطوي الهيدر كله (outer)
//                                                 if (_outerController
//                                                     .hasClients) {
//                                                   await _outerController
//                                                       .animateTo(
//                                                         _outerController
//                                                             .position
//                                                             .maxScrollExtent,
//                                                         duration:
//                                                             const Duration(
//                                                               milliseconds: 280,
//                                                             ),
//                                                         curve: Curves.easeOut,
//                                                       );
//                                                 }

//                                                 // 2) روح للقسم داخل body (inner)
//                                                 final target =
//                                                     (_categoryOffsets[index] -
//                                                             _stickyHeaderHeight)
//                                                         .clamp(
//                                                           0.0,
//                                                           _innerController!
//                                                               .position
//                                                               .maxScrollExtent,
//                                                         );

//                                                 await _innerController!
//                                                     .animateTo(
//                                                       target,
//                                                       duration: const Duration(
//                                                         milliseconds: 450,
//                                                       ),
//                                                       curve:
//                                                           Curves.easeInOutCubic,
//                                                     );

//                                                 if (mounted) {
//                                                   setState(() {
//                                                     selectedCategoryIndex =
//                                                         index;
//                                                     _activeCategoryIndex =
//                                                         index;
//                                                   });
//                                                 }
//                                               } finally {
//                                                 // خليه بعد شوي حتى ما يلتقط آخر حركة ويغير التاب
//                                                 Future.delayed(
//                                                   const Duration(
//                                                     milliseconds: 120,
//                                                   ),
//                                                   () {
//                                                     _isProgrammaticScroll =
//                                                         false;
//                                                   },
//                                                 );
//                                               }
//                                             },

//                                             child: Padding(
//                                               padding: EdgeInsets.symmetric(
//                                                 horizontal: 14.w,
//                                               ),
//                                               child: IntrinsicWidth(
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       categories[index],
//                                                       style: TextStyle(
//                                                         color: isSelected
//                                                             ? AppColor.white
//                                                             : AppColor.gry,
//                                                         fontSize: 14.sp,
//                                                         fontWeight: isSelected
//                                                             ? FontWeight.w700
//                                                             : FontWeight.w100,
//                                                       ),
//                                                     ),

//                                                     SizedBox(height: 6.h),

//                                                     // ✅ underline ثابت لكل العناصر
//                                                     AnimatedContainer(
//                                                       duration: const Duration(
//                                                         milliseconds: 250,
//                                                       ),
//                                                       height: 3.h,
//                                                       width: double
//                                                           .infinity, // ثابت
//                                                       decoration: BoxDecoration(
//                                                         color: isSelected
//                                                             ? AppColor.white
//                                                             : AppColor.white
//                                                                   .withOpacity(
//                                                                     0.1,
//                                                                   ), // رمادي خفيف
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                               10.r,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 // SizedBox(
//                                 //   height: 35.h,
//                                 //   child: ListView.builder(
//                                 //     scrollDirection: Axis.horizontal,
//                                 //     padding: EdgeInsets.symmetric(
//                                 //       horizontal: 10.w,
//                                 //     ),
//                                 //     itemCount: categories.length,
//                                 //     itemBuilder: (context, index) {
//                                 //       final isSelected =
//                                 //           selectedCategoryIndex == index;
//                                 //       return Padding(
//                                 //         padding: EdgeInsets.symmetric(
//                                 //           horizontal: 4.w,
//                                 //         ),
//                                 //         child: GestureDetector(
//                                 //           onTap: () {
//                                 //             final keyContext =
//                                 //                 _categoryKeys[index]
//                                 //                     .currentContext;
//                                 //             if (keyContext != null) {
//                                 //               Scrollable.ensureVisible(
//                                 //                 keyContext,
//                                 //                 duration: const Duration(
//                                 //                   milliseconds: 400,
//                                 //                 ),
//                                 //                 curve: Curves.easeInOut,
//                                 //               );
//                                 //             }
//                                 //             setState(() {
//                                 //               selectedCategoryIndex = index;
//                                 //             });
//                                 //           },
//                                 //           child: Container(
//                                 //             padding: EdgeInsets.symmetric(
//                                 //               horizontal: 12.w,
//                                 //             ),
//                                 //             decoration: BoxDecoration(
//                                 //               color: isSelected
//                                 //                   ? AppColor
//                                 //                         .primaryColor // ✅ لما يكون محدد → أخضر
//                                 //                   : Colors.white.withOpacity(
//                                 //                       0.06,
//                                 //                     ),
//                                 //               borderRadius:
//                                 //                   BorderRadius.circular(12.r),
//                                 //               border: Border.all(
//                                 //                 color: AppColor.primaryColor,
//                                 //               ),
//                                 //             ),
//                                 //             child: Center(
//                                 //               child: Text(
//                                 //                 categories[index],
//                                 //                 style: TextStyle(
//                                 //                   color: AppColor.white,
//                                 //
//                                 //                   fontSize: isSelected
//                                 //                       ? 14.sp
//                                 //                       : 10.sp, // ✅ كبير إذا fixed
//                                 //                   fontWeight: isSelected
//                                 //                       ? FontWeight
//                                 //                             .bold // ✅ Bold إذا fixed
//                                 //                       : FontWeight.normal,
//                                 //                 ),
//                                 //               ),
//                                 //             ),
//                                 //           ),
//                                 //         ),
//                                 //       );
//                                 //     },
//                                 //   ),
//                                 // ),
//                                 const SizedBox(height: 8),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ];
//                   },
//                   body: Builder(
//                     builder: (context) {
//                       WidgetsBinding.instance.addPostFrameCallback(
//                         (_) => _attachInnerController(),
//                       );
//                       return CustomScrollView(
//                         slivers: [
//                           SliverOverlapInjector(
//                             handle:
//                                 NestedScrollView.sliverOverlapAbsorberHandleFor(
//                                   context,
//                                 ),
//                           ),

//                           if (discountedItems.isNotEmpty)
//                             SliverToBoxAdapter(
//                               child: DiscountMealSection(
//                                 items: discountedItems,
//                                 fullImageUrl: (raw) => _imageUrl(raw),
//                                 onTap: (it) async {
//                                   final title = context.pick(
//                                     ar: it.nameAr,
//                                     en: it.nameEn,
//                                   );
//                                   final desc = context.pick(
//                                     ar: it.descriptionAr ?? "",
//                                     en: it.descriptionEn ?? "",
//                                   );
//                                   final img = _imageUrl(it.image);

//                                   await showAddOrderDialog(
//                                     isRestaurantOpen: _isRestaurantOpen,
//                                     context,
//                                     restaurantId: widget.restaurant_id,
//                                     menuItemId: it.id,
//                                     title: title,
//                                     price: it.effectivePrice,
//                                     oldPrice: (it.priceBefore > 0
//                                         ? it.priceBefore
//                                         : it.price),
//                                     imagePathOrUrl: img.isNotEmpty
//                                         ? img
//                                         : "assets/images/shawarma_box.png",
//                                     description: desc,
//                                     extraMeals: it.mealExtras,
//                                   );

//                                   if (context.mounted) {
//                                     context.read<CartCubit>().loadCart();
//                                   }
//                                 },
//                               ),
//                             ),

//                           /// Most Popular
//                           SliverToBoxAdapter(
//                             child: BlocBuilder<MostPopularCubit, MostPopularState>(
//                               bloc: mostPopularCubit,
//                               builder: (context, mpState) {
//                                 return mpState.maybeWhen(
//                                   loading: () => const Padding(
//                                     padding: EdgeInsets.only(bottom: 12),
//                                     child: Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                   ),
//                                   error: (msg) => Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 6,
//                                     ),

//                                     child: CustomSubTitle(
//                                       subtitle: msg,
//                                       color: AppColor.red,
//                                       fontsize: 12,
//                                     ),
//                                   ),

//                                   loaded: (items) {
//                                     if (items.isEmpty)
//                                       return const SizedBox.shrink();
//                                     return Padding(
//                                       padding: const EdgeInsets.only(
//                                         bottom: 12,
//                                       ),
//                                       child: MostPopularSection(
//                                         items: items,
//                                         restaurantId: widget
//                                             .restaurant_id, // (اختياري إذا عندك)
//                                         isRestaurantOpen:
//                                             _isRestaurantOpen, // ✅
//                                       ),
//                                     );
//                                   },
//                                   orElse: () => const SizedBox.shrink(),
//                                 );
//                               },
//                             ),
//                           ),

//                           /// Menu Sections
//                           SliverToBoxAdapter(
//                             child: Column(
//                               children: List.generate(categories.length, (
//                                 index,
//                               ) {
//                                 final category = categories[index];
//                                 final items = itemsByCategory[index];

//                                 return Column(
//                                   key: _categoryKeys[index],
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                       ),
//                                       child: CustomTitleSection(
//                                         title: category,
//                                         all: "common.all".tr(),
//                                         icon: Icons.arrow_forward_ios,
//                                         ontap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   CategoryItemsGridPage(
//                                                     restaurant_id:
//                                                         widget.restaurant_id,
//                                                     title: category,
//                                                     items: items,
//                                                     isRestaurantOpen:
//                                                         _isRestaurantOpen, // ✅
//                                                   ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     SizedBox(
//                                       height: 200.h,
//                                       child: ListView.builder(
//                                         scrollDirection: Axis.horizontal,
//                                         padding:
//                                             const EdgeInsetsDirectional.only(
//                                               start: 20,
//                                             ),
//                                         itemCount: items.length,
//                                         itemBuilder: (context, i) {
//                                           final it = items[i];
//                                           final imageUrl = _imageUrl(it.image);
//                                           final price = it.effectivePrice;

//                                           final mapped = MenuItemModel(
//                                             id: it.id,
//                                             nameAr: it.nameAr,
//                                             nameEn: it.nameEn,
//                                             priceBefore: (it.priceBefore > 0
//                                                 ? it.priceBefore
//                                                 : it.price),
//                                             priceAfter: it.effectivePrice,
//                                             hasDiscount: it.hasDiscount,
//                                             discountType: it.discountType,
//                                             discountValue: it.discountPercent,
//                                             isFavorite: it.isFavorite,
//                                             primaryImage: imageUrl.isEmpty
//                                                 ? null
//                                                 : PrimaryImageModel(
//                                                     imageUrl: imageUrl,
//                                                   ),
//                                             restaurant: null,
//                                           );

//                                           return GestureDetector(
//                                             onTap: () async {
//                                               await showAddOrderDialog(
//                                                 context,
//                                                 restaurantId:
//                                                     widget.restaurant_id,
//                                                 menuItemId: it.id,
//                                                 title: context.pick(
//                                                   ar: it.nameAr,
//                                                   en: it.nameEn,
//                                                 ),
//                                                 price: price,
//                                                 oldPrice: (it.priceBefore > 0
//                                                     ? it.priceBefore
//                                                     : it.price),
//                                                 imagePathOrUrl:
//                                                     imageUrl.isNotEmpty
//                                                     ? imageUrl
//                                                     : "assets/images/shawarma_box.png",
//                                                 description: context.pick(
//                                                   ar: it.descriptionAr ?? "",
//                                                   en: it.descriptionEn ?? "",
//                                                 ),
//                                                 extraMeals: it.mealExtras,
//                                                 isRestaurantOpen:
//                                                     _isRestaurantOpen,
//                                               );

//                                               if (mounted) {
//                                                 context
//                                                     .read<CartCubit>()
//                                                     .loadCart();
//                                               }
//                                             },
//                                             child: Container(
//                                               width: 142.w,
//                                               margin:
//                                                   EdgeInsetsDirectional.only(
//                                                     end: i == items.length - 1
//                                                         ? 0
//                                                         : 8.w,
//                                                   ),
//                                               child: PopularItemCard(
//                                                 item: mapped,
//                                                 isRestaurantOpen:
//                                                     _isRestaurantOpen, // ✅ أضفها
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                   ],
//                                 );
//                               }),
//                             ),
//                           ),

//                           SliverToBoxAdapter(child: SizedBox(height: 24.h)),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _divider() {
//     return Container(
//       width: 0.5,
//       height: 25.h,
//       margin: EdgeInsets.symmetric(horizontal: 4.w),
//       color: AppColor.LightActive,
//     );
//   }
// }

// class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;

//   _StickyHeaderDelegate({required this.child});

//   @override
//   double get minExtent => 210.h;
//   double get _headerExtentPx => 210.h;

//   @override
//   double get maxExtent => 210.h;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return child;
//   }

//   @override
//   bool shouldRebuild(covariant _StickyHeaderDelegate old) {
//     return old.child != child;
//   }
// }

class DiscountItemCard extends StatelessWidget {
  final MenuItem item;
  final String imageUrl;

  const DiscountItemCard({super.key, required this.item, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final before = item.priceBefore > 0 ? item.priceBefore : item.price;
    final after = item.effectivePrice;
    final hasDiscount = item.hasDiscount && after < before;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(11.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 145.h,
                height: 145.h,
                child: AppNetworkImage(
                  path: imageUrl,
                  height: 145.h,
                  width: 145.h,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(16.r),
                  fallback: _fallback(),
                ),
              ),
              if (item.discountPercent > 0)
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColor.red,
                      borderRadius: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(20.r),
                        bottomEnd: Radius.circular(20.r),
                        bottomStart: Radius.circular(25.r),
                      ),
                    ),
                    child: CustomSubTitle(subtitle: "-${item.discountPercent.toStringAsFixed(0)}%", color: Colors.white, fontsize: 11.sp),
                  ),
                ),
            ],
          ),
          Container(
            height: 55.h,
            width: 145.h,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                  ),
                ),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        context.money(before, decimals: 0),
                        style: TextStyle(
                          color: AppColor.LightActive,
                          fontSize: 11.sp,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColor.LightActive,
                          fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                        ),
                      ),
                      const SizedBox(width: 4),
                      CustomSubTitle(subtitle: context.money(after, decimals: 0), color: AppColor.red, fontsize: 12.sp),
                    ] else ...[
                      CustomSubTitle(subtitle: context.money(after, decimals: 0), color: AppColor.white, fontsize: 12.sp),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 26),
    );
  }
}

String buildDiscountBadge(MenuItemModel item, BuildContext context) {
  if (!item.hasDiscount) return "";
  final type = item.discountType ?? "percentage";
  final v = item.discountValue ?? 0;

  if (type == "fixed") {
    return "-${context.money(v, decimals: 0)}";
  }
  return "-${v.toStringAsFixed(0)}%";
}
