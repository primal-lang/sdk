import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/directory/platform_directory_base.dart';

class PlatformDirectoryWeb extends PlatformDirectoryBase {
  @override
  Directory fromPath(String path) =>
      throw const UnimplementedFunctionWebError('directory.fromPath');

  @override
  bool exists(Directory directory) =>
      throw const UnimplementedFunctionWebError('directory.exists');
}
