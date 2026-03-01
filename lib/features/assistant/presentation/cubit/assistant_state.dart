import 'package:breezefood/features/assistant/model/assistant_models.dart';

abstract class AssistantState {
  const AssistantState();
}

class AssistantInitial extends AssistantState {
  const AssistantInitial();
}

class AssistantLoaded extends AssistantState {
  final List<AssistantMessage> messages;
  final bool sending;
  final List<AssistantRestaurantLite> restaurants;

  const AssistantLoaded({
    required this.messages,
    required this.sending,
    required this.restaurants,
  });

  AssistantLoaded copyWith({
    List<AssistantMessage>? messages,
    bool? sending,
    List<AssistantRestaurantLite>? restaurants,
  }) {
    return AssistantLoaded(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      restaurants: restaurants ?? this.restaurants,
    );
  }
}

class AssistantError extends AssistantState {
  final String message;
  const AssistantError(this.message);
}
