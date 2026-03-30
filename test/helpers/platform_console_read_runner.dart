import 'package:primal/compiler/platform/console/platform_console_cli.dart';

void main() {
  final PlatformConsoleCli console = PlatformConsoleCli();
  final String result = console.readLine();

  // ignore: avoid_print
  print(result);
}
