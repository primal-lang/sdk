import 'dart:io';
import 'package:primal/compiler/platform/platform_base.dart';

class PlatformInterface extends PlatformBase {
  @override
  void outWrite(String content) => stdout.write(content);

  @override
  void outWriteLn(String content) => stdout.writeln(content);

  @override
  void errorWrite(String content) => stderr.write(content);

  @override
  void errorWriteLn(String content) => stderr.writeln(content);

  @override
  String readLine() => stdin.readLineSync()?.trim() ?? '';
  
  @override
  String getEnvironmentVariable(String name) => Platform.environment[name] ?? '';
}
