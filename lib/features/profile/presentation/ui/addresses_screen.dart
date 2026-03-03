// import 'package:breezefood/core/component/color.dart';
// import 'package:breezefood/features/profile/data/model/address_model.dart';
// import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// import 'map_picker_screen.dart'; // ✅ عدّل المسار حسب مكان ملفك

// enum AddressesMode { manage, pick }

// class AddressesScreen extends StatelessWidget {
//   final ProfileCubit profileCubit;
//   final AddressesMode mode;

//   final int? selectedId;
//   bool get isPick => mode == AddressesMode.pick;
//   const AddressesScreen({
//     super.key,
//     required this.profileCubit,
//     this.mode = AddressesMode.manage,
//     this.selectedId,
//   });
//   @override
//   Widget build(BuildContext context) {
//     final addresses = profileCubit.state.maybeWhen(
//       loaded: (_, addresses, __, ___, ____, _____) => addresses,
//       orElse: () => <AddressModel>[],
//     );

//     return Scaffold(
//       backgroundColor: AppColor.Dark,
//       appBar: AppBar(
//         backgroundColor: AppColor.Dark,
//         title: const Text("Addresses"),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColor.LightActive,
//         onPressed: () => _showAddSheet(context),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),

//       body: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: addresses.isEmpty
//             ? Center(
//                 child: Text(
//                   "No addresses yet.\nTap + to add one.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: AppColor.gry, fontSize: 14.sp),
//                 ),
//               )
//             : ListView.separated(
//                 itemCount: addresses.length,
//                 separatorBuilder: (_, __) => SizedBox(height: 10.h),
//                 itemBuilder: (_, i) => _AddressCard(
//                   address: addresses[i],
//                   selectable: isPick,
//                   selected: selectedId == addresses[i].id,
//                   onTap: isPick
//                       ? () => Navigator.pop(context, addresses[i])
//                       : null,
//                   onDelete: isPick
//                       ? null
//                       : () => _confirmDelete(context, addresses[i].id),
//                 ),
//               ),
//       ),
//     );
//   }

//   void _confirmDelete(BuildContext context, int id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppColor.black,
//         title: const Text(
//           "Delete address?",
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           "Are you sure you want to delete this address?",
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await profileCubit.deleteAddress(id);
//               if (context.mounted) profileCubit.refreshAddresses();
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ مساعد: نجيب موقع مبدئي (موقع المستخدم) أو fallback
//   Future<LatLng> _getInitialLatLng() async {
//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return const LatLng(33.5138, 36.2765); // دمشق fallback
//       }

//       var perm = await Geolocator.checkPermission();
//       if (perm == LocationPermission.denied) {
//         perm = await Geolocator.requestPermission();
//       }
//       if (perm == LocationPermission.denied ||
//           perm == LocationPermission.deniedForever) {
//         return const LatLng(33.5138, 36.2765);
//       }

//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       return LatLng(pos.latitude, pos.longitude);
//     } catch (_) {
//       return const LatLng(33.5138, 36.2765);
//     }
//   }

//   void _showAddSheet(BuildContext context) {
//     final addressCtrl = TextEditingController();
//     bool isDefault = true;

//     double? pickedLat;
//     double? pickedLng;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColor.Dark,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
//       ),
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             Future<void> pickFromMap() async {
//               final initial = await _getInitialLatLng();
//               if (!context.mounted) return;

//               final res = await Navigator.push<MapPickerResult>(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => MapPickerScreen(initial: initial),
//                 ),
//               );

//               if (res != null) {
//                 setState(() {
//                   pickedLat = res.latitude;
//                   pickedLng = res.longitude;
//                 });
//               }
//             }

//             return Padding(
//               padding: EdgeInsets.only(
//                 left: 16.w,
//                 right: 16.w,
//                 top: 16.h,
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 44.w,
//                     height: 5.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   SizedBox(height: 14.h),

//                   SizedBox(height: 10.h),
//                   _field(addressCtrl, "Address (text)"),
//                   SizedBox(height: 10.h),

//                   // ✅ زر اختيار من الخريطة بدل إدخال lat/lng
//                   SizedBox(
//                     width: double.infinity,
//                     height: 46.h,
//                     child: OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: Colors.white.withOpacity(0.25)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                       onPressed: pickFromMap,
//                       icon: const Icon(Icons.map_outlined, color: Colors.white),
//                       label: Text(
//                         pickedLat == null
//                             ? "Pick location from map"
//                             : "Picked: ${pickedLat!.toStringAsFixed(6)}, ${pickedLng!.toStringAsFixed(6)}",
//                         style: const TextStyle(color: Colors.white),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: 10.h),

//                   SwitchListTile(
//                     value: isDefault,
//                     onChanged: (v) => setState(() => isDefault = v),
//                     title: const Text(
//                       "Set as default",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     activeColor: AppColor.LightActive,
//                   ),

//                   SizedBox(height: 10.h),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 46.h,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColor.LightActive,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                       onPressed: () async {
//                         final addr = addressCtrl.text.trim();

//                         if (pickedLat == null || pickedLng == null) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Please pick location from map"),
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                           return;
//                         }

//                         await profileCubit.addAddress(
//                           address: addr,
//                           latitude: pickedLat!,
//                           longitude: pickedLng!,
//                           isDefault: isDefault,
//                         );

//                         if (context.mounted) Navigator.pop(context);
//                       },
//                       child: const Text(
//                         "Save",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _field(TextEditingController c, String hint) {
//     return TextField(
//       controller: c,
//       keyboardType: TextInputType.text,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.white38),
//         filled: true,
//         fillColor: AppColor.black,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }

// class _AddressCard extends StatelessWidget {
//   final AddressModel address;
//   final VoidCallback? onDelete;

//   final bool selectable;
//   final bool selected;
//   final VoidCallback? onTap;

//   const _AddressCard({
//     required this.address,
//     required this.onDelete,
//     this.selectable = false,
//     this.selected = false,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(12.r),
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: AppColor.black,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: selected
//                 ? AppColor.LightActive.withOpacity(0.8)
//                 : Colors.white.withOpacity(0.06),
//             width: selected ? 1.4 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44.w,
//               height: 44.w,
//               decoration: BoxDecoration(
//                 color: AppColor.Dark,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Icon(
//                 address.isDefault
//                     ? Icons.star_rounded
//                     : Icons.location_on_rounded,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(width: 12.w),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     address.address,
//                     style: TextStyle(color: AppColor.gry, fontSize: 13.sp),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),

//             if (selectable)
//               Icon(
//                 selected ? Icons.radio_button_checked : Icons.radio_button_off,
//                 color: selected ? AppColor.LightActive : Colors.white54,
//               )
//             else
//               IconButton(
//                 onPressed: onDelete,
//                 icon: const Icon(
//                   Icons.delete_outline_rounded,
//                   color: Colors.redAccent,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
