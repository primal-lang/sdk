import 'package:primal/compiler/platform/console/platform_console_cli.dart';

void main(List<String> args) {
  final PlatformConsoleCli console = PlatformConsoleCli();
  final String mode = args[0];
  final String content = args.length > 1 ? args[1] : '';

  switch (mode) {
    case 'outWrite':
      console.outWrite(content);
      break;
    case 'outWriteLn':
      console.outWriteLn(content);
      break;
    case 'errorWrite':
      console.errorWrite(content);
      break;
    case 'errorWriteLn':
      console.errorWriteLn(content);
      break;
    default:
      throw ArgumentError('Unsupported mode: $mode');
  }
}
