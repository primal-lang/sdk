import 'dart:io';
import 'package:primal/compiler/platform/directory/platform_directory_base.dart';

class PlatformDirectoryCli extends PlatformDirectoryBase {
  @override
  Directory fromPath(String path) => Directory(path);

  @override
  bool exists(Directory directory) => directory.existsSync();

  @override
  bool create(Directory directory) {
    try {
      directory.createSync(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool delete(Directory directory) {
    try {
      directory.deleteSync(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }
}
