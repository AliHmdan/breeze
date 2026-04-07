part of 'auth_flow_cubit.dart';

@freezed
class AuthFlowState with _$AuthFlowState {
  const factory AuthFlowState.initial() = _Initial;
  const factory AuthFlowState.loading() = _Loading;
  const factory AuthFlowState.error(String message) = _Error;

  const factory AuthFlowState.codeSent(dynamic data) = _CodeSent;
  const factory AuthFlowState.codeResent(dynamic data) = _CodeResent;
  const factory AuthFlowState.verified(dynamic data) = _Verified;
  const factory AuthFlowState.profileUpdated(dynamic data) = _ProfileUpdated;
  const factory AuthFlowState.addressAdded(dynamic data) = _AddressAdded;

  // ✅ جديد
  const factory AuthFlowState.loggedOut(String message) = _LoggedOut;
  //firstname
  const factory AuthFlowState.needProfileCompletion(dynamic data) = _NeedProfileCompletion;
  const factory AuthFlowState.authenticated(dynamic data) = _Authenticated;
}
