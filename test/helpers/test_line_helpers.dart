import 'package:primal/utils/console.dart';

/// Builders for the result lines printed by `--test`.
///
/// The spacing is written out literally rather than derived from the status
/// width, so a regression in the production padding still fails these tests.

String passLine(String name) => '${Console.green}PASS${Console.reset}  $name';

String failLine(String name) => '${Console.red}FAIL${Console.reset}  $name';

String errorLine(String name) => '${Console.red}ERROR${Console.reset} $name';
