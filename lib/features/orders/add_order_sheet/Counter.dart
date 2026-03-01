import 'package:breezefood/core/component/color.dart';
import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  final int count;
  final bool isLoading;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const CounterWidget({
    super.key,
    required this.count,
    required this.isLoading,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(40), // pill shape
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// زر النقصان
          GestureDetector(
            onTap: (isLoading || count <= 1) ? null : onDec,
            child: Icon(
              Icons.remove,
              size: 26,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(width: 25),

          /// العدد
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(width: 25),

          /// زر الزيادة
          GestureDetector(
            onTap: isLoading ? null : onInc,
            child: Icon(
              Icons.add,
              size: 26,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}