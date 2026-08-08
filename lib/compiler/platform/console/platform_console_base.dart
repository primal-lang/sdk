abstract class PlatformConsoleBase {
  void outWrite(String content);

  void outWriteLn(String content);

  void errorWrite(String content);

  void errorWriteLn(String content);

  /// The next line of input, or null once there is no more of it.
  ///
  /// Null and the empty string are different answers: a blank line is input and
  /// more may follow it, while null means the input has ended and never will.
  /// A caller that reads in a loop has to stop on null, because nothing it does
  /// afterwards can produce another line.
  String? readLine();
}
