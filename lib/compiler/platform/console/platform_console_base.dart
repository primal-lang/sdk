abstract class PlatformConsoleBase {
  void outWrite(String content);

  void outWriteLn(String content);

  void errorWrite(String content);

  void errorWriteLn(String content);

  String readLine();
}
