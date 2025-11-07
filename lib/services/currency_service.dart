import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Base currency the app displays alongside local currency
  static const String baseCurrency = 'USD';

  // Cache last fetched rates per base for 10 minutes
  static final Map<String, _CachedRate> _cache = {};
  static const _ttl = Duration(minutes: 10);

  Future<double> convert({
    required double amount,
    required String from,
    String to = baseCurrency,
  }) async {
    if (from.toUpperCase() == to.toUpperCase()) return amount;

    final rate = await _getRate(from: from, to: to);
    return double.parse((amount * rate).toStringAsFixed(2));
  }

  Future<double> _getRate({required String from, required String to}) async {
    final key = '${from.toUpperCase()}_${to.toUpperCase()}';
    final now = DateTime.now();
    final cached = _cache[key];
    if (cached != null && now.difference(cached.fetchedAt) < _ttl) {
      return cached.rate;
    }

    try {
      final uri = Uri.parse('https://api.exchangerate.host/convert?from=$from&to=$to&amount=1');
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        return 1.0; // Fallback to 1:1 if API fails
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = data['result'];
      final result = raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 1.0;
      final rate = result; // amount=1, so result == rate
      _cache[key] = _CachedRate(rate: rate, fetchedAt: now);
      return rate;
    } catch (_) {
      return 1.0; // Network/CORS error fallback
    }
  }
}

class _CachedRate {
  final double rate;
  final DateTime fetchedAt;
  _CachedRate({required this.rate, required this.fetchedAt});
}
