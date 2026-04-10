import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final String type;
  final String status;
  final Map<String, dynamic> title;
  final Map<String, dynamic> body;

  final Map<String, dynamic> data;

  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.sentAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String pickTitle(String lang) {
    final v = title[lang] ?? title["en"] ?? title["ar"];
    return (v ?? "").toString();
  }

  String pickBody(String lang) {
    final v = body[lang] ?? body["en"] ?? body["ar"];
    return (v ?? "").toString();
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    return AppNotification(
      id: (json["id"] ?? 0) is int ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      type: (json["type"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      title: (json["title"] is Map) ? Map<String, dynamic>.from(json["title"]) : <String, dynamic>{},
      body: (json["body"] is Map) ? Map<String, dynamic>.from(json["body"]) : <String, dynamic>{},
      data: (json["data"] is Map) ? Map<String, dynamic>.from(json["data"]) : <String, dynamic>{},
      readAt: parseDate(json["read_at"]),
      sentAt: parseDate(json["sent_at"]),
      createdAt: parseDate(json["created_at"]),
    );
  }
   String _pick(Map<String, dynamic> m, BuildContext context) {
    final lang = context.locale.languageCode; // ar/en
    final v = m[lang] ?? m["en"] ?? m["ar"];
    return (v ?? "").toString();
  }

  String titleText(BuildContext context) => _pick(title, context);
  String bodyText(BuildContext context) => _pick(body, context);
}
