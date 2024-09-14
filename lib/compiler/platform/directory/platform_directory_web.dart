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

  @override
  bool create(Directory directory) =>
      throw const UnimplementedFunctionWebError('directory.create');

  @override
  bool delete(Directory directory) =>
      throw const UnimplementedFunctionWebError('directory.delete');

  @override
  bool copy(Directory source, Directory destination) =>
      throw const UnimplementedFunctionWebError('directory.copy');

  @override
  bool move(Directory source, Directory destination) =>
      throw const UnimplementedFunctionWebError('directory.move');

  @override
  bool rename(Directory directory, String name) =>
      throw const UnimplementedFunctionWebError('directory.rename');
}
