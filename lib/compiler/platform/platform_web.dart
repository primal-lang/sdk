import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/console/platform_console_web.dart';
import 'package:primal/compiler/platform/platform_base.dart';

class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleWeb();

  @override
  String environmentGetVariable(String name) =>
      throw const UnimplementedFunctionWebError('env.get');

  @override
  File fileFromPath(String path) =>
      throw const UnimplementedFunctionWebError('file.fromPath');

  @override
  bool fileExists(File file) =>
      throw const UnimplementedFunctionWebError('file.exists');

  @override
  String fileRead(File file) =>
      throw const UnimplementedFunctionWebError('file.read');

  @override
  void fileWrite(File file, String content) =>
      throw const UnimplementedFunctionWebError('file.write');

  @override
  int fileLength(File file) =>
      throw const UnimplementedFunctionWebError('file.length');

  @override
  void fileCreate(File file) =>
      throw const UnimplementedFunctionWebError('file.create');
}
