import 'dart:io';

abstract class PlatformBase {
  void consoleOutWrite(String content);

  void consoleOutWriteLn(String content);

  void consoleErrorWrite(String content);

  void consoleErrorWriteLn(String content);

  String consoleReadLine();

  String environmentGetVariable(String name);

  File fileFromPath(String path);
}
