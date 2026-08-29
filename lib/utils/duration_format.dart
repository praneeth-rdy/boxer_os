/// Formats seconds as a round clock, `3:05`.
String formatClock(int seconds) {
  final total = seconds < 0 ? 0 : seconds;
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

/// Formats seconds as whole minutes, `20 min`, never below one minute.
String formatMinutes(int seconds) {
  if (seconds < 90) return '1 min';
  return '${(seconds / 60).round()} min';
}
