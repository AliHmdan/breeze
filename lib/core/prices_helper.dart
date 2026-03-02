import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class MoneyFormatter {
  MoneyFormatter._();

  /// يحول أي قيمة (num أو String) لرقم آمن
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();

    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;

    // شيل أي شي غير الأرقام والنقطة والسالب
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// 1200000 -> "1,200,000"
  static String _formatIntWithCommas(int n) {
    final sign = n < 0 ? "-" : "";
    var s = n.abs().toString();
    final out = StringBuffer();

    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      out.write(s[i]);
      if (left > 1 && left % 3 == 1) out.write(',');
    }
    return "$sign$out";
  }

  /// لاحقة العملة حسب اللغة
  static String _suffix(BuildContext context) {
    final code = context.locale.languageCode;
    return code == 'ar' ? 'ل.س' : 'SYP';
  }

  /// السعر النهائي جاهز للعرض
  /// - by default بدون كسور (الليرة عادةً integer)
  /// - withSymbol: تلصق لاحقة العملة
  static String formatSyp(
    BuildContext context,
    dynamic value, {
    bool withSymbol = true,
    int decimals = 0,
  }) {
    final d = _toDouble(value);
    final fixed = d.toStringAsFixed(decimals);
    final numVal = double.tryParse(fixed) ?? 0.0;

    String numberText;
    if (decimals == 0) {
      numberText = _formatIntWithCommas(numVal.round());
    } else {
      // لو بدك كسور: نفصل الجزء الصحيح ونضيف commas له
      final parts = fixed.split('.');
      final intPart = int.tryParse(parts[0]) ?? 0;
      final frac = parts.length > 1 ? parts[1] : '';
      numberText = "${_formatIntWithCommas(intPart)}.$frac";
    }

    if (!withSymbol) return numberText;
    return "$numberText ${_suffix(context)}";
  }

  /// يرجع رقم فقط + suffix لحالها (مفيد لـ TextSpan)
  static String suffix(BuildContext context) => _suffix(context);
}

/// Extension لطيف لتستخدمه مباشرة
extension MoneyX on BuildContext {
  String syp(dynamic value, {bool withSymbol = true, int decimals = 0}) =>
      MoneyFormatter.formatSyp(
        this,
        value,
        withSymbol: withSymbol,
        decimals: decimals,
      );
}
