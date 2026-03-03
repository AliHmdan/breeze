import 'package:breezefood/features/profile/data/model/address_model.dart';
import 'package:breezefood/features/profile/data/repo/addresses_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'addresses_state.dart';
part 'addresses_cubit.freezed.dart';

class AddressesCubit extends Cubit<AddressesState> {
  final AddressesRepository repo;
  AddressesCubit(this.repo) : super(const AddressesState.initial());

  _Loaded? _loaded() => state is _Loaded ? state as _Loaded : null;

  Future<void> load({bool silent = false, String? phone}) async {
    final prev = _loaded();

    if (!silent || prev == null) {
      emit(const AddressesState.loading());
    } else {
      emit(prev.copyWith(isRefreshing: true, toast: null));
    }

    final res = await repo.getMyAddresses();
    if (!res.ok) {
      if (silent && prev != null) {
        emit(prev.copyWith(isRefreshing: false));
        return;
      }
      emit(AddressesState.error(res.message ?? "خطأ"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final data = map["data"];
    final list = (data is List)
        ? data
              .map(
                (e) => ProfileAddress.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <ProfileAddress>[];

    final prevSelected = prev?.selectedId;
    int? selected;
    if (prevSelected != null && list.any((a) => a.id == prevSelected)) {
      selected = prevSelected;
    } else {
      final def = list.where((a) => a.isDefault && a.id != null).toList();
      selected = def.isNotEmpty ? def.first.id : null;
    }

    emit(
      AddressesState.loaded(
        items: list,
        selectedId: selected,
        toast: null,
        isRefreshing: false,
        deletingIds: <int>{},
      ),
    );
  }

  void select(ProfileAddress a) {
    final st = _loaded();
    if (st == null) return;
    emit(st.copyWith(selectedId: a.id, toast: null));
  }

  ProfileAddress? get selected {
    final st = _loaded();
    if (st == null) return null;
    final id = st.selectedId;
    if (id == null)
      return st.items.firstWhere(
        (e) => e.isDefault,
        orElse: () =>
            st.items.isNotEmpty ? st.items.first : null as ProfileAddress,
      );
    return st.items.firstWhere(
      (e) => e.id == id,
      orElse: () =>
          st.items.isNotEmpty ? st.items.first : null as ProfileAddress,
    );
  }

  Future<void> add({
    required String label,
    required String address,
    required double lat,
    required double lon,
    bool isDefault = false,
  }) async {
    final st = _loaded();
    if (st == null) return;

    final res = await repo.addAddress(
      label: label,
      address: address,
      lat: lat,
      lon: lon,
      isDefault: isDefault,
    );

    if (!res.ok) {
      emit(st.copyWith(toast: res.message ?? "فشل إضافة العنوان"));
      return;
    }

    // بعد الإضافة حمّل من جديد
    await load(silent: true);
  }

  Future<void> delete(ProfileAddress a) async {
    final st = _loaded();
    if (st == null) return;

    final id = a.id;
    if (id == null) {
      emit(st.copyWith(toast: "لا يمكن حذف هذا العنوان"));
      return;
    }

    emit(st.copyWith(deletingIds: {...st.deletingIds, id}, toast: null));

    final res = await repo.deleteAddress(id);
    final st2 = _loaded();
    if (st2 == null) return;

    if (!res.ok) {
      emit(
        st2.copyWith(
          deletingIds: st2.deletingIds..remove(id),
          toast: res.message ?? "فشل حذف العنوان",
        ),
      );
      return;
    }

    await load(silent: true);
  }
}
