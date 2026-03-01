class AssistantMessage {
  final String role;
  final String message;

  const AssistantMessage({required this.role, required this.message});

  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    return AssistantMessage(
      role: (json["role"] ?? "").toString(),
      message: (json["message"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "message": message,
    };
  }
}

class AssistantRestaurantLite {
  final int id;
  final String name;

  const AssistantRestaurantLite({required this.id, required this.name});

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory AssistantRestaurantLite.fromJson(Map<String, dynamic> json) {
    return AssistantRestaurantLite(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
    );
  }
}

class AssistantStartResponse {
  final List<AssistantMessage> messages;

  const AssistantStartResponse({required this.messages});

  factory AssistantStartResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["messages"] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AssistantMessage.fromJson(e.cast<String, dynamic>()))
        .toList();

    return AssistantStartResponse(messages: list);
  }
}

class AssistantChatResults {
  final String message;
  final List<AssistantRestaurantLite> restaurants;

  const AssistantChatResults({required this.message, required this.restaurants});

  factory AssistantChatResults.fromJson(Map<String, dynamic> json) {
    final restaurantsJson = (json["restaurants"] as List? ?? const []);
    final restaurants = restaurantsJson
        .whereType<Map>()
        .map((e) => AssistantRestaurantLite.fromJson(e.cast<String, dynamic>()))
        .toList();

    return AssistantChatResults(
      message: (json["message"] ?? "").toString(),
      restaurants: restaurants,
    );
  }
}

class AssistantChatResponse {
  final Map<String, dynamic>? intent;
  final AssistantChatResults? results;

  const AssistantChatResponse({required this.intent, required this.results});

  factory AssistantChatResponse.fromJson(Map<String, dynamic> json) {
    final intent = json["intent"];
    final results = json["results"];

    return AssistantChatResponse(
      intent: intent is Map ? intent.cast<String, dynamic>() : null,
      results: results is Map
          ? AssistantChatResults.fromJson(results.cast<String, dynamic>())
          : null,
    );
  }
}
