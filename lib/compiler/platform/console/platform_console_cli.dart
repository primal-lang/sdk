import 'dart:io';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/utils/console.dart';
import 'package:primal/utils/line_editor.dart';

class PlatformConsoleCli extends PlatformConsoleBase {
  final LineEditor _lineEditor = LineEditor(prompt: Console.inputPrompt);
  @override
  void outWrite(String content) => stdout.write(content);

  @override
  void outWriteLn(String content) => stdout.writeln(content);

  @override
  void errorWrite(String content) => stderr.write(content);

  @override
  void errorWriteLn(String content) => stderr.writeln(content);

  @override
  String readLine() => _lineEditor.readLine();
}
