import 'dart:io';
import 'package:primal/compiler/platform/console/platform_console_base.dart';

abstract class PlatformBase {
  PlatformConsoleBase get console;

  String environmentGetVariable(String name);

  File fileFromPath(String path);

  bool fileExists(File file);

  String fileRead(File file);

  void fileWrite(File file, String content);

  int fileLength(File file);

  void fileCreate(File file);
}
