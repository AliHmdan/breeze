import 'package:breezefood/features/search/data/api/search_api_service.dart';
import 'package:breezefood/features/search/data/models/search_history_response.dart';
import 'package:breezefood/features/search/data/models/search_response.dart';

class SearchRepo {
  final SearchApiService api;
  SearchRepo(this.api);

  Future<SearchResponse> search(String query, {int? restaurantId}) async {
    final body = <String, dynamic>{"query": query};

    if (restaurantId != null && restaurantId != 0) {
      body["rest_id"] = restaurantId; // أو "rest_id" حسب السيرفر
    }

    final res = await api.search(body);
    return SearchResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SearchHistoryResponse> history() async {
    final res = await api.history();
    return SearchHistoryResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
