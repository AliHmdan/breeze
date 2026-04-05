import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/main_shell.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_textfaild_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class InfoProfile extends StatefulWidget {
  final ProfileCubit profileCubit;
  const InfoProfile({super.key, required this.profileCubit});

  @override
  State<InfoProfile> createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _avatarVer = 0; // 🔥 لتغيير الرابط وإجبار إعادة التحميل
  String? _lastServerPath; // لتتبع تغيّر الصورة

  bool _didFillOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = widget.profileCubit.state;

      st.maybeWhen(
        loaded: (user, addresses, avatars, selectedAvatarId, isSaving, message) {
          _fillFromLoadedOnce(st);
        },
        orElse: () {
          widget.profileCubit.load();
        },
      );
    });
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _fillFromLoadedOnce(ProfileState state) {
    if (_didFillOnce) return;

    state.maybeWhen(
      loaded: (user, _, __, ___, ____, _____) {
        _firstCtrl.text = user.firstName;
        _lastCtrl.text = user.lastName;
        _phoneCtrl.text = user.phone;
        _didFillOnce = true;
      },
      orElse: () {},
    );
  }

  ImageProvider _avatarImageProvider(ProfileState state) {
    final selectedPath = state.maybeWhen(loaded: (_, __, ___, selectedAvatarPath, ____, _____) => selectedAvatarPath, orElse: () => null);

    final serverPath = state.maybeWhen(loaded: (user, _, __, ___, ____, _____) => user.profileImage, orElse: () => null);

    // ✅ اختر الصورة: preview أولاً ثم السيرفر
    final raw = (selectedPath != null && selectedPath.trim().isNotEmpty) ? selectedPath : serverPath;

    final full = UrlHelper.toFullUrl(raw);
    if (full != null && full.isNotEmpty) {
      final busted = "$full?v=$_avatarVer"; // 🔥 يجبر تحميل جديد
      return CachedNetworkImageProvider(busted);
    }

    // return const AssetImage('assets/images/person.jpg');
    return const AssetImage('assets/images/person.jpg');
  }

  Future<void> _openAvatarPicker(ProfileState state) async {
    // ✅ حمّل avatars لو فاضيين
    final avatarsEmpty = state.maybeWhen(loaded: (_, __, avatars, ___, ____, _____) => avatars.isEmpty, orElse: () => true);

    if (avatarsEmpty) {
      await widget.profileCubit.loadAvatars();
      if (!mounted) return;
    }

    final latestState = widget.profileCubit.state;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.Dark,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18.r))),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: latestState.maybeWhen(
            loaded: (user, addresses, avatars, selectedAvatarPath, isSaving, message) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'اختر صورة Avatar',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  if (avatars.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      child: const Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: avatars.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemBuilder: (_, i) {
                        final av = avatars[i];
                        final selected = selectedAvatarPath == av.path;
                        return GestureDetector(
                          onTap: () async {
                            widget.profileCubit.selectAvatar(av);

                            // 🔥 اجبار تحديث الصورة فوراً
                            final full = UrlHelper.toFullUrl(av.path);
                            if (full != null && full.isNotEmpty) {
                              await CachedNetworkImage.evictFromCache(full);
                            }

                            if (mounted) {
                              setState(() {
                                _avatarVer = DateTime.now().millisecondsSinceEpoch;
                              });
                            }

                            Navigator.pop(context);
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: selected ? AppColor.LightActive : Colors.white24, width: selected ? 3 : 1),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              backgroundColor: Colors.white10,
                              backgroundImage: av.fullUrl.isNotEmpty
                                  ? NetworkImage(av.fullUrl)
                                  : const AssetImage('assets/images/person.jpg') as ImageProvider,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
            orElse: () => Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate() {
    if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter first & last name"), behavior: SnackBarBehavior.floating));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: widget.profileCubit,
      listener: (context, state) {
        _fillFromLoadedOnce(state);

        final msg = state.maybeWhen(loaded: (_, __, ___, ____, _____, message) => message, orElse: () => null);

        if (msg != null && msg.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
        }
      },
      builder: (context, state) {
        final isSaving = state.maybeWhen(loaded: (_, __, ___, ____, isSaving, _____) => isSaving, orElse: () => false);

        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColor.Dark,
            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(60.h),
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 16.w),
            //     child: CustomAppbarProfile(title: "profile.title".tr(), icon: Icons.arrow_back_ios, ontap: () => Navigator.pop(context)),
            //   ),
            // ),
            body: state.maybeWhen(
              initial: () => const Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColor.primaryColor)),
              error: (msg) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: () => widget.profileCubit.load(),
                        child: Text("common.retry".tr(), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              loaded: (_, __, ___, ____, _____, ______) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    child: Column(
                      children: [
                        CustomAppbarProfile(title: "profile.title".tr(), icon: Icons.arrow_back_ios, ontap: () => Navigator.pop(context)),
                        SizedBox(height: 12.h),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(radius: 70.r, backgroundImage: _avatarImageProvider(state)),
                            GestureDetector(
                              onTap: () => _openAvatarPicker(state),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColor.Dark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColor.LightActive, width: 1.w),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/edit.svg",
                                  width: 18.w,
                                  height: 18.h,
                                  colorFilter: ColorFilter.mode(AppColor.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35.h),

                        LabelWidget(text: "auth.first_name".tr()),
                        SizedBox(height: 5.h),
                        CustomTextfaildInfo(label: "First Name", hint: "First Name", controller: _firstCtrl, keyboardType: TextInputType.text),
                        SizedBox(height: 15.h),
                        LabelWidget(text: "auth.last_name".tr()),
                        SizedBox(height: 5.h),
                        CustomTextfaildInfo(label: "Last Name", hint: "Last Name", controller: _lastCtrl, keyboardType: TextInputType.text),
                        SizedBox(height: 15.h),
                        LabelWidget(text: "auth.phone_number".tr()),
                        SizedBox(height: 5.h),
                        CustomTextfaildInfo(
                          label: "Phone Number",
                          hint: "0938204147",
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          // readOnly: true,
                        ),
                        SizedBox(height: 30.h),

                        CustomButton(
                          title: isSaving ? "common.saving".tr() : "common.save".tr(),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  await widget.profileCubit.saveProfile(firstName: _firstCtrl.text.trim(), lastName: _lastCtrl.text.trim());

                                  final st = widget.profileCubit.state;
                                  final serverPath = st.maybeWhen(loaded: (user, _, __, ___, ____, _____) => user.profileImage, orElse: () => null);

                                  final full = UrlHelper.toFullUrl(serverPath);
                                  if (full != null && full.isNotEmpty) {
                                    await CachedNetworkImage.evictFromCache(full);
                                  }

                                  if (!mounted) return;

                                  // ✅ Restart app shell
                                  Navigator.of(
                                    context,
                                  ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0)), (route) => false);
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

class LabelWidget extends StatelessWidget {
  final String text;
  const LabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(color: AppColor.white, fontSize: 14.w, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
