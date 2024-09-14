import 'dart:io';

abstract class PlatformDirectoryBase {
  Directory fromPath(String path);

  bool exists(Directory directory);

  bool create(Directory directory);

  bool delete(Directory directory);
}
