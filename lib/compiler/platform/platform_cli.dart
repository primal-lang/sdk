import 'dart:io';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/console/platform_console_cli.dart';
import 'package:primal/compiler/platform/platform_base.dart';

class PlatformInterface extends PlatformBase {
  @override
  PlatformConsoleBase get console => PlatformConsoleCli();

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

  @override
  void fileCreate(File file) => file.createSync();
}
