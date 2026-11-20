// mm:ss -> seconds
String formatTime(double seconds) {
  int min = seconds ~/ 60;
  int sec = (seconds % 60).toInt();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

// seconds -> mm:ss
String formatMMSS(double minutes) {
  int m = minutes.floor();
  int s = ((minutes - m) * 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// parse mm:ss (or bare minutes) -> minutes
double? parseMMSS(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'[.,]'), ':');
  if (normalized.contains(':')) {
    final parts = normalized.split(':');
    if (parts.length == 2) {
      final int? m = parts[0].isEmpty ? 0 : int.tryParse(parts[0]);
      final int? s = int.tryParse(parts[1]);
      if (m != null && s != null && m >= 0 && s >= 0) {
        return m + (s / 60.0);
      }
    }
    return null;
  }
  final int? m = int.tryParse(normalized);
  return (m != null && m >= 0) ? m.toDouble() : null;
}
