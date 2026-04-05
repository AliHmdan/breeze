import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_description.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_header_image.dart';
import 'package:breezefood/features/orders/add_order_sheet/add_order_title_price.dart';
import 'package:breezefood/features/orders/add_order_sheet/counter_sheet.dart';
import 'package:breezefood/features/orders/add_order_sheet/extra_groups_list.dart';
import 'package:breezefood/features/orders/add_order_sheet/extras_helper.dart';
import 'package:breezefood/features/orders/add_order_sheet/notes_field.dart';
import 'package:breezefood/features/orders/add_order_sheet/required_size_group_list.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderBody extends StatefulWidget {
  final String title;
  final double price;
  final ScrollController scrollController;
  final double oldPrice;
  final String imagePathOrUrl;
  final String description;
  final List<MenuExtra> extras;
  final int restaurantId;
  final int menuItemId;
  final bool isRestaurantOpen;
  final List<ExtraGrouped> extraGroups;

  const AddOrderBody({
    super.key,
    required this.isRestaurantOpen,
    required this.scrollController,
    required this.extraGroups,
    required this.restaurantId,
    required this.menuItemId,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.imagePathOrUrl,
    required this.description,
    required this.extras,
  });

  @override
  State<AddOrderBody> createState() => _AddOrderBodyState();
}

class _AddOrderBodyState extends State<AddOrderBody> {
  int _qty = 1;
  bool _withSpicy = false;

  // ✅ REQUIRED animation trigger
  bool _highlightSizeRequired = false;

  // groupId -> selected extraId
  Map<int, int?> _selectedGroupChoice = {};

  // legacy extras (إذا بدك تستعملها لاحقاً)
  final Set<int> _selectedExtrasIds = {};

  // size selected extraId
  int? _selectedSizeExtraId;

  final TextEditingController _noteCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sg = _sizeGroup;
      if (mounted && sg != null && sg.items.isNotEmpty && _selectedSizeExtraId == null) {
        setState(() => _highlightSizeRequired = true);
      }
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _hasDiscount => widget.oldPrice > widget.price && widget.oldPrice > 0;

  bool get _isRTL => Directionality.of(context) == mt.TextDirection.rtl;

  ExtraGrouped? get _sizeGroup => ExtrasHelper.findSizeGroup(widget.extraGroups);

  List<ExtraGrouped> get _otherGroups => ExtrasHelper.otherGroups(widget.extraGroups, _sizeGroup);

  double get _extrasTotal => ExtrasHelper.computeExtrasTotal(
    sizeGroup: _sizeGroup,
    selectedSizeExtraId: _selectedSizeExtraId,
    otherGroups: _otherGroups,
    selectedGroupChoice: _selectedGroupChoice,
  );

  List<AddToCartExtraRequest> _selectedExtrasPayload() {
    final ids = <int>{};

    if (_selectedSizeExtraId != null) {
      ids.add(_selectedSizeExtraId!);
    }

    ids.addAll(_selectedGroupChoice.values.whereType<int>());

    ids.addAll(_selectedExtrasIds);

    return ids.map((id) => AddToCartExtraRequest(extraId: id, quantity: 1)).toList();
  }

  String _buildShareText() {
    final price = context.syp(widget.price);
    final old = context.syp(widget.oldPrice);

    final legacyNames = widget.extras
        .where((e) => _selectedExtrasIds.contains(e.id))
        .map((e) => _isRTL ? e.nameAr : e.nameEn)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final groupedSelectedIds = _selectedGroupChoice.values.toSet()..addAll(_selectedSizeExtraId == null ? const {} : {_selectedSizeExtraId!});

    final groupedNames = widget.extraGroups
        .expand((g) => g.items)
        .where((e) => groupedSelectedIds.contains(e.id))
        .map((e) => _isRTL ? e.nameAr : e.nameEn)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final extrasNames = [...groupedNames, ...legacyNames];

    final extrasLine = extrasNames.isEmpty ? "" : "\nExtras: ${extrasNames.join(", ")}";

    final spicyLine = _withSpicy ? "\n🌶️ Hot: Yes" : "\n🌶️ Hot: No";

    final note = _noteCtrl.text.trim();
    final noteLine = note.isEmpty ? "" : "\n📝 Notes: $note";

    final discountLine = (_hasDiscount) ? "\n💸 Old: $old" : "";

    final productUrl = "";

    return """
${widget.title}
💰 Price: $price$discountLine
$spicyLine
$extrasLine$noteLine
${productUrl.isEmpty ? "" : "\n$productUrl"}
"""
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final sg = _sizeGroup;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        state.whenOrNull(
          addedSuccess: (message) async {
            EasyLoading.showSuccess(message);
            if (context.mounted) Navigator.of(context).pop(true);
          },
          error: (msg) => EasyLoading.showError(msg),
        );
      },
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: Column(
                    children: [
                      AddOrderHeaderImage(imagePathOrUrl: widget.imagePathOrUrl, shareText: _buildShareText()),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AddOrderTitlePrice(
                              title: widget.title,
                              price: widget.price,
                              oldPrice: widget.oldPrice,
                              hasDiscount: _hasDiscount,
                              description: widget.description,
                              count: _qty,
                              onInc: () => setState(() => _qty++),
                              onDec: () {
                                setState(() {
                                  if (_qty > 1) _qty--;
                                });
                              },
                            ),

                            SizedBox(height: 15.h),

                            // AddOrderDescription(
                            //   description: widget.description,
                            //   maxWidth: 300.w,
                            // ),
                            SizedBox(height: 8.h),

                            if (widget.extraGroups.isNotEmpty) ...[
                              SizedBox(height: 8.h),

                              if (sg != null && sg.items.isNotEmpty) ...[
                                RequiredSizeGroupList(
                                  group: sg,
                                  selectedExtraId: _selectedSizeExtraId,
                                  highlightRequired: _highlightSizeRequired,
                                  onSelect: (id) => setState(() {
                                    _selectedSizeExtraId = id;
                                    _highlightSizeRequired = false; // ✅ يطفي بعد الاختيار
                                  }),
                                ),
                                SizedBox(height: 12.h),
                              ],

                              if (_otherGroups.isNotEmpty)
                                ExtraGroupsList(
                                  groups: _otherGroups,
                                  selectedChoice: _selectedGroupChoice,
                                  onChanged: (groupId, extraId) {
                                    setState(() {
                                      if (extraId == null) {
                                        _selectedGroupChoice.remove(groupId);
                                      } else {
                                        _selectedGroupChoice[groupId] = extraId;
                                      }
                                    });
                                  },
                                ),

                              SizedBox(height: 8.h),
                            ],

                            SizedBox(height: 10.h),

                            NotesField(
                              controller: _noteCtrl,
                              onTap: () async {
                                Future.delayed(Duration(seconds: 2)).then((onValue) {
                                  widget.scrollController.animateTo(
                                    widget.scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  );
                                });
                              },
                            ),

                            SizedBox(height: 10.h),

                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColor.Dark,
                  child: CounterSheet(
                    count: _qty,
                    onInc: () => setState(() => _qty++),
                    onDec: () => setState(() {
                      if (_qty > 1) _qty--;
                    }),

                    isRestaurantOpen: widget.isRestaurantOpen,
                    basePrice: widget.price,
                    extrasTotal: _extrasTotal,
                    isSizeRequired: sg != null && sg.items.isNotEmpty,
                    isSizeSelected: _selectedSizeExtraId != null,
                    onMissingSize: () => setState(() => _highlightSizeRequired = true),
                    onAdd: (qty) {
                      final req = AddToCartRequest(
                        restaurantId: widget.restaurantId,
                        menuItemId: widget.menuItemId,
                        quantity: qty,
                        specialNotes: _noteCtrl.text.trim(),
                        withSpicy: _withSpicy,
                        extras: _selectedExtrasPayload(),
                      );
                      context.read<CartCubit>().add(req);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Fixed close button overlay
          PositionedDirectional(
            top: 5,
            end: 1,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black54),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                fixedSize: WidgetStateProperty.all(const Size(30, 30)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
