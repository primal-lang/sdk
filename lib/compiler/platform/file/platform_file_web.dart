import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/file/platform_file_base.dart';

class PlatformFileWeb extends PlatformFileBase {
  @override
  File fromPath(String path) =>
      throw const UnimplementedFunctionWebError('file.fromPath');

  @override
  bool exists(File file) =>
      throw const UnimplementedFunctionWebError('file.exists');

  @override
  String read(File file) =>
      throw const UnimplementedFunctionWebError('file.read');

  @override
  bool write(File file, String content) =>
      throw const UnimplementedFunctionWebError('file.write');

  @override
  int length(File file) =>
      throw const UnimplementedFunctionWebError('file.length');

  @override
  bool create(File file) =>
      throw const UnimplementedFunctionWebError('file.create');

  @override
  bool delete(File file) =>
      throw const UnimplementedFunctionWebError('file.delete');

  @override
  String path(File file) =>
      throw const UnimplementedFunctionWebError('file.path');

  @override
  String name(File file) =>
      throw const UnimplementedFunctionWebError('file.name');

  @override
  bool rename(File file, String name) =>
      throw const UnimplementedFunctionWebError('file.rename');

  @override
  String extension(File file) =>
      throw const UnimplementedFunctionWebError('file.extension');

  @override
  bool copy(File fileSource, File fileDestination) =>
      throw const UnimplementedFunctionWebError('file.copy');

  @override
  bool move(File fileSource, File fileDestination) =>
      throw const UnimplementedFunctionWebError('file.move');

  @override
  Directory parent(File file) =>
      throw const UnimplementedFunctionWebError('file.parent');
}
