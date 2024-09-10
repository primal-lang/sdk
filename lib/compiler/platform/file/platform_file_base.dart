import 'dart:io';

abstract class PlatformFileBase {
  File fromPath(String path);

  bool exists(File file);

  String read(File file);

  void write(File file, String content);

  int length(File file);

  void create(File file);
}
