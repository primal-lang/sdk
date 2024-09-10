import 'dart:io';

abstract class PlatformFileBase {
  File fromPath(String path);

  bool exists(File file);

  String read(File file);

  void write(File file, String content);

  int length(File file);

  bool create(File file);

  bool delete(File file);

  String path(File file);

  String name(File file);
}
