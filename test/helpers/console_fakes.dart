import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/utils/console.dart';

class FakePlatformConsole extends PlatformConsoleBase {
  final List<String> inputs;
  final List<String> outWrites = <String>[];
  final List<String> outLines = <String>[];
  final List<String> errorWrites = <String>[];
  final List<String> errorLines = <String>[];
  Object? readError;

  int _inputIndex = 0;

  FakePlatformConsole({List<String>? inputs}) : inputs = inputs ?? <String>[];

  @override
  void outWrite(String content) => outWrites.add(content);

  @override
  void outWriteLn(String content) => outLines.add(content);

  @override
  void errorWrite(String content) => errorWrites.add(content);

  @override
  void errorWriteLn(String content) => errorLines.add(content);

  @override
  String readLine() {
    if (readError != null) {
      throw readError!;
    }

    if (_inputIndex >= inputs.length) {
      return '';
    }

    return inputs[_inputIndex++];
  }
}

class ScriptedConsole extends Console {
  final int promptIterations;

  ScriptedConsole(
    super.platformConsole, {
    required this.promptIterations,
  });

  @override
  void prompt(void Function(String) handler) {
    for (int i = 0; i < promptIterations; i++) {
      promptOnce(handler);
    }
  }
}
