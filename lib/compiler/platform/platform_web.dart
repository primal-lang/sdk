import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/platform_base.dart';

class PlatformInterface extends PlatformBase {
  @override
  void consoleOutWrite(String content) => print(content);

  @override
  void consoleOutWriteLn(String content) => print(content);

  @override
  void consoleErrorWrite(String content) => print(content);

  @override
  void consoleErrorWriteLn(String content) => print(content);

  @override
  String consoleReadLine() =>
      throw const UnimplementedFunctionWebError('console.read');

  @override
  String environmentGetVariable(String name) =>
      throw const UnimplementedFunctionWebError('env.get');

  @override
  File fileFromPath(String path) =>
      throw const UnimplementedFunctionWebError('file.fromPath');
}
