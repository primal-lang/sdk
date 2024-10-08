import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:primal/compiler/platform/file/platform_file_base.dart';

class PlatformFileCli extends PlatformFileBase {
  @override
  File fromPath(String path) => File(path);

  @override
  bool exists(File file) => file.existsSync();

  @override
  String read(File file) => file.readAsStringSync();

  @override
  bool write(File file, String content) {
    try {
      file.writeAsStringSync(content);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  int length(File file) => file.lengthSync();

  @override
  bool create(File file) {
    try {
      file.createSync(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool delete(File file) {
    try {
      file.deleteSync(recursive: true);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String path(File file) => file.absolute.path;

  @override
  String name(File file) => path_lib.basename(file.path);

  @override
  bool rename(File file, String name) {
    try {
      final String newFilePath = '${file.parent.path}/$name';
      file.renameSync(newFilePath);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String extension(File file) {
    final String name = path_lib.extension(file.path);

    return name.startsWith('.') ? name.substring(1) : name;
  }

  @override
  bool copy(File source, File destination) {
    try {
      source.copySync(destination.path);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool move(File source, File destination) {
    try {
      source.renameSync(destination.path);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Directory parent(File file) => file.parent;
}
