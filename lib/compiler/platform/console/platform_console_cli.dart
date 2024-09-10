import 'dart:io';
import 'package:primal/compiler/platform/console/platform_console_base.dart';

class PlatformConsoleCli extends PlatformConsoleBase {
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
}
