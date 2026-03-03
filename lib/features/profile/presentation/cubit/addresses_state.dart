part of 'addresses_cubit.dart';

@freezed
class AddressesState with _$AddressesState {
  const factory AddressesState.initial() = _Initial;
  const factory AddressesState.loading() = _Loading;

  const factory AddressesState.loaded({
    required List<ProfileAddress> items,
    int? selectedId,
    String? toast,
    @Default(false) bool isRefreshing,
    @Default(<int>{}) Set<int> deletingIds,
  }) = _Loaded;

  const factory AddressesState.error(String message) = _Error;
}
