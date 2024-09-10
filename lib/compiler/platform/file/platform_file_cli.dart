import 'dart:io';
import 'package:primal/compiler/platform/file/platform_file_base.dart';

class PlatformFileCli extends PlatformFileBase {
  @override
  File fromPath(String path) => File(path);

  @override
  bool exists(File file) => file.existsSync();

  @override
  String read(File file) => file.readAsStringSync();

  @override
  void write(File file, String content) => file.writeAsStringSync(content);

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
}
