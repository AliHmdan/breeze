import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RDTabsBar extends StatefulWidget {
  const RDTabsBar({super.key, required this.categories, required this.activeIndex, required this.onTap});

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<RDTabsBar> createState() => _RDTabsBarState();
}

class _RDTabsBarState extends State<RDTabsBar> {
  int _safeIndex(int i, int len) {
    if (len <= 0) return 0;
    if (i < 0) return 0;
    if (i >= len) return len - 1;
    return i;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final safe = _safeIndex(widget.activeIndex, widget.categories.length);

    return DefaultTabController(
      key: const ValueKey<String>("rd_tabs_controller"),
      length: widget.categories.length,
      initialIndex: safe,
      child: _RDTabsBarInner(categories: widget.categories, activeIndex: safe, onTap: widget.onTap),
    );
  }
}

class _RDTabsBarInner extends StatefulWidget {
  const _RDTabsBarInner({required this.categories, required this.activeIndex, required this.onTap});

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<_RDTabsBarInner> createState() => _RDTabsBarInnerState();
}

class _RDTabsBarInnerState extends State<_RDTabsBarInner> {
  static const _anim = Duration(milliseconds: 220);

  @override
  void didUpdateWidget(covariant _RDTabsBarInner oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctl = DefaultTabController.of(context);

      if (ctl.index != widget.activeIndex && !ctl.indexIsChanging) {
        ctl.animateTo(widget.activeIndex, duration: _anim, curve: Curves.linear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctl = DefaultTabController.of(context);

    return SizedBox(
      height: 33.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 3.5.h, color: AppColor.white.withOpacity(0.18)),
          ),
          TabBar(
            tabAlignment: TabAlignment.center,
            controller: ctl,
            isScrollable: true,
            padding: EdgeInsets.zero,
            onTap: widget.onTap,
            labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
            labelColor: AppColor.white,
            unselectedLabelColor: AppColor.white.withOpacity(0.55),
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.3.h, color: AppColor.white),
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
              // insets: EdgeInsets.symmetric(horizontal: 10.w),
              // borderSide: BorderSide(width: 3.h, color: AppColor.white),
              // insets: EdgeInsets.symmetric(horizontal: 10.w),
            ),
            dividerColor: Color(0xFFF9FAFB),
            dividerHeight: -20.h,
            tabs: widget.categories.map((t) => Tab(child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
          ),
        ],
      ),
    );
  }
}
