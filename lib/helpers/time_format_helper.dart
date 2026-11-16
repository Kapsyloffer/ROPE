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

// read mm:ss as seconds
double? parseMMSS(String value) {
  if (value.contains(':')) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      double? m = double.tryParse(parts[0]);
      double? s = double.tryParse(parts[1]);
      if (m != null && s != null) {
        return m + (s / 60.0);
      }
    }
  }
  return num.tryParse(value.replaceAll(',', '.'))?.toDouble();
}
