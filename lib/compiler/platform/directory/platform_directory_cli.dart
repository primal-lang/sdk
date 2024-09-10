import 'dart:io';
import 'package:primal/compiler/platform/directory/platform_directory_base.dart';

class PlatformDirectoryCli extends PlatformDirectoryBase {
  @override
  Directory fromPath(String path) => Directory(path);
}
