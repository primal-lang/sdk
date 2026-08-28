import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/file/platform_file_base.dart';

class PlatformFileWeb extends PlatformFileBase {
  @override
  File fromPath(String path) =>
      throw const UnimplementedFunctionWebError('file_fromPath');

  @override
  bool exists(File file) =>
      throw const UnimplementedFunctionWebError('file_exists');

  @override
  String read(File file) =>
      throw const UnimplementedFunctionWebError('file_read');

  @override
  bool write(File file, String content) =>
      throw const UnimplementedFunctionWebError('file_write');

  @override
  int length(File file) =>
      throw const UnimplementedFunctionWebError('file_length');

  @override
  bool create(File file) =>
      throw const UnimplementedFunctionWebError('file_create');

  @override
  bool delete(File file) =>
      throw const UnimplementedFunctionWebError('file_delete');

  @override
  String path(File file) =>
      throw const UnimplementedFunctionWebError('file_path');

  @override
  String name(File file) =>
      throw const UnimplementedFunctionWebError('file_name');

  @override
  bool rename(File file, String name) =>
      throw const UnimplementedFunctionWebError('file_rename');

  @override
  String extension(File file) =>
      throw const UnimplementedFunctionWebError('file_extension');

  @override
  bool copy(File source, File destination) =>
      throw const UnimplementedFunctionWebError('file_copy');

  @override
  bool move(File source, File destination) =>
      throw const UnimplementedFunctionWebError('file_move');

  @override
  Directory parent(File file) =>
      throw const UnimplementedFunctionWebError('file_parent');

  @override
  bool append(File file, String content) =>
      throw const UnimplementedFunctionWebError('file_append');

  @override
  DateTime lastModified(File file) =>
      throw const UnimplementedFunctionWebError('file_lastModified');
}
