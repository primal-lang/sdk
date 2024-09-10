import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';

class PlatformConsoleWeb extends PlatformConsoleBase {
  @override
  void outWrite(String content) => print(content);

  @override
  void outWriteLn(String content) => print(content);

  @override
  void errorWrite(String content) => print(content);

  @override
  void errorWriteLn(String content) => print(content);

  @override
  String readLine() =>
      throw const UnimplementedFunctionWebError('console.read');
}
