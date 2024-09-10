import 'dart:io';
import 'package:primal/compiler/platform/platform_base.dart';

class PlatformInterface extends PlatformBase {
  @override
  void consoleOutWrite(String content) => stdout.write(content);

  @override
  void consoleOutWriteLn(String content) => stdout.writeln(content);

  @override
  void consoleErrorWrite(String content) => stderr.write(content);

  @override
  void consoleErrorWriteLn(String content) => stderr.writeln(content);

  @override
  String consoleReadLine() => stdin.readLineSync()?.trim() ?? '';

  @override
  String environmentGetVariable(String name) =>
      Platform.environment[name] ?? '';

  @override
  File fileFromPath(String path) => File(path);

  @override
  bool fileExists(File file) => file.existsSync();

  @override
  String fileRead(File file) => file.readAsStringSync();

  @override
  void fileWrite(File file, String content) => file.writeAsStringSync(content);

  @override
  int fileLength(File file) => file.lengthSync();
}
