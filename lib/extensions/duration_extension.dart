extension DurationFormatting on Duration {
  String toFormattedString() {
    final int days = inDays;
    final int hours = inHours.remainder(24);
    final int minutes = inMinutes.remainder(60);
    final int seconds = inSeconds.remainder(60);
    final int milliseconds = inMilliseconds.remainder(1000);
    final String minutesString = minutes.toString().padLeft(2, '0');
    final String secondsString = seconds.toString().padLeft(2, '0');
    final String millisecondsString = milliseconds.toString().padLeft(3, '0');

    return '${days}d ${hours}h ${minutesString}m ${secondsString}s ${millisecondsString}ms';
  }
}
