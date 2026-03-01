import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/assistant/presentation/cubit/assistant_cubit.dart';
import 'package:breezefood/features/assistant/presentation/cubit/assistant_state.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showAssistantChatSheet(BuildContext context) async {
  final cartCubit = context.read<CartCubit>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetCtx) {
      final height = MediaQuery.of(sheetCtx).size.height * 0.82;

      return MediaQuery.removePadding(
        context: sheetCtx,
        removeTop: true,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColor.Dark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: cartCubit),
                BlocProvider(create: (_) => getIt<AssistantCubit>()..start()),
              ],
              child: const _AssistantChatBody(),
            ),
          ),
        ),
      );
    },
  );
}

class _AssistantChatBody extends StatefulWidget {
  const _AssistantChatBody();

  @override
  State<_AssistantChatBody> createState() => _AssistantChatBodyState();
}

class _AssistantChatBodyState extends State<_AssistantChatBody> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openRestaurant(BuildContext context, int id) async {
    if (id <= 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider(create: (_) => getIt<RatingSubmitCubit>()),
            BlocProvider(create: (_) => getIt<FavoritesCubit>()),
          ],
          child: ResturantDetails(restaurant_id: id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssistantCubit, AssistantState>(
      listener: (context, state) {
        if (state is AssistantLoaded) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final loaded = state is AssistantLoaded ? state : null;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "AI Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                children: [
                  if (state is AssistantError)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
                      ),
                    ),
                  if (loaded != null)
                    ...loaded.messages.map((m) {
                      final isUser = m.role.toLowerCase() == "user";
                      final bg = isUser
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white.withOpacity(0.06);
                      final align = isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      return Align(
                        alignment: align,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          constraints: BoxConstraints(maxWidth: 0.82.sw),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            m.message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  if (loaded != null && loaded.restaurants.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      "Restaurants",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...loaded.restaurants.map((r) {
                      return InkWell(
                        onTap: () => _openRestaurant(context, r.id),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: const Icon(
                                  Icons.storefront,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  r.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  if (loaded != null && loaded.sending)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Typing...",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: "اكتب طلبك...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      onSubmitted: (_) {
                        final text = _ctrl.text;
                        _ctrl.clear();
                        context.read<AssistantCubit>().send(text);
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      final text = _ctrl.text;
                      _ctrl.clear();
                      context.read<AssistantCubit>().send(text);
                    },
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
