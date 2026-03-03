import 'package:breezefood/features/profile/presentation/cubit/addresses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../ui/map_picker_screen.dart';

class AddressPickerSheet extends StatelessWidget {
  const AddressPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.72,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "العناوين",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.read<AddressesCubit>().load(silent: true),
                  icon: Icon(Icons.refresh, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<AddressesCubit, AddressesState>(
              listener: (context, state) {
                state.whenOrNull(
                  loaded:
                      (items, selectedId, toast, isRefreshing, deletingIds) {
                        if (toast != null && toast.trim().isNotEmpty) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(toast)));
                        }
                      },
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (msg) => Center(child: Text(msg)),
                  loaded: (items, selectedId, toast, isRefreshing, deletingIds) {
                    if (items.isEmpty) {
                      return const Center(child: Text("لا يوجد عناوين"));
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(12.w),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (_, i) {
                        final a = items[i];
                        final isSelected = a.id != null && a.id == selectedId;
                        final isDeleting =
                            a.id != null && deletingIds.contains(a.id);

                        return InkWell(
                          onTap: () {
                            context.read<AddressesCubit>().select(a);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary.withOpacity(0.6)
                                    : colorScheme.outline.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.place, color: colorScheme.primary),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.label,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        a.address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (a.isDefault)
                                  Icon(Icons.star, color: colorScheme.primary),
                                SizedBox(width: 6.w),
                                if (a.id != null)
                                  IconButton(
                                    onPressed: isDeleting
                                        ? null
                                        : () => context
                                              .read<AddressesCubit>()
                                              .delete(a),
                                    icon: isDeleting
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : const Icon(Icons.delete_outline),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push<MapPickerResult>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPickerScreen(
                          initial: const LatLng(33.5138, 36.2765),
                        ),
                      ),
                    );
                    if (res == null) return;

                    final label = await _askLabel(context);
                    if (label == null || label.trim().isEmpty) return;

                    await context.read<AddressesCubit>().add(
                      label: label.trim(),
                      address: res.address,
                      lat: res.latitude,
                      lon: res.longitude,
                      isDefault: false,
                    );

                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("إضافة عنوان"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _askLabel(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("اسم العنوان"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "مثلاً: البيت / الشغل"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
