import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeTabsBar extends StatefulWidget {
  const HomeTabsBar({super.key, required this.titles, required this.activeIndex, required this.onTap});

  final List<String> titles;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<HomeTabsBar> createState() => _HomeTabsBarState();
}

class _HomeTabsBarState extends State<HomeTabsBar> {
  int _safe(int i, int len) {
    if (len <= 0) return 0;
    if (i < 0) return 0;
    if (i >= len) return len - 1;
    return i;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.titles.isEmpty) {
      return const SizedBox.shrink();
    }

    final safe = _safe(widget.activeIndex, widget.titles.length);

    return DefaultTabController(
      key: const ValueKey<String>("home_tabs_controller"),
      length: widget.titles.length,
      initialIndex: safe,
      child: _HomeTabsBarInner(titles: widget.titles, activeIndex: safe, onTap: widget.onTap),
    );
  }
}

class _HomeTabsBarInner extends StatefulWidget {
  const _HomeTabsBarInner({required this.titles, required this.activeIndex, required this.onTap});

  final List<String> titles;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  State<_HomeTabsBarInner> createState() => _HomeTabsBarInnerState();
}

class _HomeTabsBarInnerState extends State<_HomeTabsBarInner> {
  static const _anim = Duration(milliseconds: 220);

  @override
  void didUpdateWidget(covariant _HomeTabsBarInner oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ctl = DefaultTabController.of(context);

      if (ctl.index != widget.activeIndex && !ctl.indexIsChanging) {
        ctl.animateTo(widget.activeIndex, duration: _anim, curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ctl = DefaultTabController.of(context);

    return SizedBox(
      height: 45.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// Bottom faint line
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 3.h, color: colorScheme.outline.withOpacity(0.25)),
          ),

          /// Tabs
          TabBar(
            controller: ctl,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            padding: EdgeInsets.zero,
            onTap: widget.onTap,
            labelPadding: EdgeInsets.symmetric(horizontal: 14.w),

            labelColor: colorScheme.onSurface,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.55),

            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),

            unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),

            indicatorSize: TabBarIndicatorSize.tab,

            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.h, color: colorScheme.onSurface),
              insets: EdgeInsets.symmetric(horizontal: 12.w),
            ),

            tabs: widget.titles.map((t) => Tab(child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
          ),
        ],
      ),
    );
  }
}
