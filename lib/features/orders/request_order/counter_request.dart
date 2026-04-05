import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterRequest extends StatefulWidget {
  final int value; // ✅ value الحالي من الـ state
  final bool loading; // ✅ لودينغ على نفس العنصر
  final ValueChanged<int>? onChanged;

  const CounterRequest({super.key, required this.value, this.loading = false, this.onChanged});

  @override
  State<CounterRequest> createState() => _CounterRequestState();
}

class _CounterRequestState extends State<CounterRequest> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.value;
  }

  @override
  void didUpdateWidget(covariant CounterRequest oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ إذا القيمة القادمة من الـ Cubit تغيرت، حدّث العداد مباشرة
    if (oldWidget.value != widget.value) {
      _count = widget.value;
      if (mounted) setState(() {});
    }
  }

  void _set(int v) {
    if (widget.loading) return;
    if (v < 1) return;

    setState(() => _count = v);
    widget.onChanged?.call(_count);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 6.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _btn(icon: Icons.remove, onTap: () => _set(_count - 1)),
              SizedBox(width: 10.w),
              Text(
                "x$_count",
                style: TextStyle(color: AppColor.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 10.w),
              _btn(icon: Icons.add, onTap: () => _set(_count + 1)),
            ],
          ),
        ),

        if (widget.loading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: colorScheme.surface.withOpacity(0.35), borderRadius: BorderRadius.circular(12.r)),
              child: Center(
                child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _btn({required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: widget.loading ? null : onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(color: AppColor.search, borderRadius: BorderRadius.circular(99)),
        child: Icon(icon, size: 16, color: AppColor.white),
      ),
    );
  }
}
