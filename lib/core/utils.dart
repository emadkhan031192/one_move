import 'dart:convert';

/// Deep-copies a JSON-encodable map via a JSON round-trip.
Map<String, dynamic> deepCopyState(Map<String, dynamic> state) {
  return jsonDecode(jsonEncode(state)) as Map<String, dynamic>;
}

/// Element-wise equality for lists.
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Stable `yyyy-MM-dd` key for a calendar date (local time).
String dateKey(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// Whole calendar days between two dates, ignoring time of day.
int daysBetween(DateTime a, DateTime b) {
  final da = DateTime(a.year, a.month, a.day);
  final db = DateTime(b.year, b.month, b.day);
  return db.difference(da).inDays;
}

/// Positive modulo that also works for negative dividends.
int posMod(int value, int mod) => ((value % mod) + mod) % mod;

/// Clamps [v] into [min]..[max].
int clampInt(int v, int min, int max) => v < min ? min : (v > max ? max : v);
