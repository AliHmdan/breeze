import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/features/assistant/data/repo/assistant_repository.dart';
import 'package:breezefood/features/assistant/model/assistant_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'assistant_state.dart';

class AssistantCubit extends Cubit<AssistantState> {
  final AssistantRepository repo;

  AssistantCubit(this.repo) : super(const AssistantInitial());

  Future<void> start() async {
    emit(const AssistantLoaded(messages: [], sending: false, restaurants: []));

    final AppResponse res = await repo.start();
    if (!res.ok) {
      emit(AssistantError(res.message ?? "فشل بدء المساعد"));
      return;
    }

    try {
      final raw = res.data;
      final map = raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};
      final parsed = AssistantStartResponse.fromJson(map);
      emit(
        AssistantLoaded(
          messages: parsed.messages,
          sending: false,
          restaurants: const [],
        ),
      );
    } catch (_) {
      emit(const AssistantError("فشل قراءة رد المساعد"));
    }
  }

  Future<void> send(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    final st = state;
    if (st is! AssistantLoaded) return;

    final nextMessages = List<AssistantMessage>.from(st.messages)
      ..add(AssistantMessage(role: "user", message: trimmed));

    emit(st.copyWith(messages: nextMessages, sending: true));

    final res = await repo.chat(message: trimmed);
    if (!res.ok) {
      emit(st.copyWith(sending: false));
      return;
    }

    try {
      final raw = res.data;
      final map = raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};
      final parsed = AssistantChatResponse.fromJson(map);

      final results = parsed.results;
      final assistantText = results?.message ?? "";
      final restaurants = results?.restaurants ?? const [];

      final updated = List<AssistantMessage>.from(nextMessages);
      if (assistantText.trim().isNotEmpty) {
        updated.add(AssistantMessage(role: "assistant", message: assistantText));
      }

      emit(
        st.copyWith(
          messages: updated,
          sending: false,
          restaurants: restaurants,
        ),
      );
    } catch (_) {
      emit(st.copyWith(sending: false));
    }
  }
}
