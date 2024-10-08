import 'dart:io';

abstract class PlatformFileBase {
  File fromPath(String path);

  bool exists(File file);

  String read(File file);

  bool write(File file, String content);

  int length(File file);

  bool create(File file);

  bool delete(File file);

  String path(File file);

  String name(File file);

  bool rename(File file, String name);

  String extension(File file);

  bool copy(File source, File destination);

  bool move(File source, File destination);

  Directory parent(File file);
}
