import 'dart:io';

abstract class PlatformDirectoryBase {
  Directory fromPath(String path);

  bool exists(Directory directory);

  bool create(Directory directory);

  bool delete(Directory directory);

  bool copy(Directory source, Directory destination);

  bool move(Directory source, Directory destination);

  bool rename(Directory directory, String name);

  String path(Directory directory);

  String name(Directory directory);

  Directory parent(Directory directory);

  List<FileSystemEntity> list(Directory directory);
}
