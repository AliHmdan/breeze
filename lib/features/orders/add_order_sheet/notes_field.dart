import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesField extends StatefulWidget {
  final TextEditingController controller;
  final void Function()? onTap;

  const NotesField({super.key, required this.controller, this.onTap});

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    /// يمنع أخذ التركيز تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        CustomSubTitle(subtitle: "cart.item_notes_optional".tr(), color: AppColor.white, fontsize: 14.sp),

        SizedBox(height: 12.h),

        /// TEXT FIELD
        SizedBox(
          width: double.infinity,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            showCursor: true,
            maxLines: 2,
            cursorColor: AppColor.white,
            cursorWidth: 2,
            onTap: widget.onTap,
            cursorRadius: const Radius.circular(2),
            style: TextStyle(color: AppColor.white, fontSize: 14.sp),
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              hintText: "cart.item_notes_hint".tr(),
              hintStyle: TextStyle(color: AppColor.LightActive, fontSize: 12.sp),

              isDense: true,
              contentPadding: EdgeInsets.zero,

              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF373737), width: 1)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF373737), width: 1)),
            ),
          ),
        ),
      ],
    );
  }
}
