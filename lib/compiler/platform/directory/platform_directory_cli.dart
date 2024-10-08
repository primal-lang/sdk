import 'dart:io';
import 'package:path/path.dart' as path_lib;
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

  @override
  bool copy(Directory source, Directory destination) {
    try {
      source.listSync().forEach((entity) {
        final String newPath =
            entity.path.replaceAll(source.path, destination.path);

        if (entity is File) {
          entity.copySync(newPath);
        } else if (entity is Directory) {
          copy(Directory(entity.path), Directory(newPath));
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool move(Directory source, Directory destination) {
    try {
      source.renameSync(destination.path);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool rename(Directory directory, String name) {
    try {
      final String newFilePath = '${directory.parent.path}/$name';
      directory.renameSync(newFilePath);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String path(Directory directory) => directory.absolute.path;

  @override
  String name(Directory directory) => path_lib.basename(directory.path);

  @override
  Directory parent(Directory directory) => directory.parent;

  @override
  List<FileSystemEntity> list(Directory directory) => directory.listSync();
}
