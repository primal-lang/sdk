@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Environment', () {
    group('env.get', () {
      test('returns empty string for non-existent variable', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("INVALID_VARIABLE")',
        );
        checkResult(runtime, '""');
      });

      test('returns value of existing variable HOME', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("HOME")');
        checkResult(runtime, '"$home"');
      });

      test('returns value of existing variable PATH', () {
        final String path = Platform.environment['PATH'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("PATH")');
        checkResult(runtime, '"$path"');
      });

      test('returns value of existing variable USER', () {
        final String user = Platform.environment['USER'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("USER")');
        checkResult(runtime, '"$user"');
      });

      test('returns empty string for empty variable name', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get("")');
        checkResult(runtime, '""');
      });

      test('is case-sensitive for variable names', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtimeLower = getRuntime(
          'main() = env.get("home")',
        );
        final RuntimeFacade runtimeUpper = getRuntime(
          'main() = env.get("HOME")',
        );
        // On Unix systems, HOME exists but home likely does not
        checkResult(runtimeUpper, '"$home"');
        // home (lowercase) should return empty string if not set
        final String homeLower = Platform.environment['home'] ?? '';
        checkResult(runtimeLower, '"$homeLower"');
      });

      test('returns empty string for variable name with only spaces', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get("   ")');
        checkResult(runtime, '""');
      });

      test('handles variable names with underscores', () {
        // LC_ALL is a common environment variable with underscore
        final String lcAll = Platform.environment['LC_ALL'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("LC_ALL")');
        checkResult(runtime, '"$lcAll"');
      });
    });

    group('env.get type errors', () {
      test('throws InvalidArgumentTypesError when given a number', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(42)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(true)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Boolean)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a list', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(["HOME"])');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (List)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get({"key": "value"})',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Map)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given false', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(false)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Boolean)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given zero', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(0)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given negative number', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(-1)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given floating point', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get(3.14)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given empty list', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get([])');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (List)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given empty map', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get({})');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Map)'),
              ),
            ),
          ),
        );
      });
    });

    group('env.get edge cases', () {
      test('handles single character variable name', () {
        // Single character env variable names are rare but valid
        final String singleCharValue = Platform.environment['_'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("_")');
        checkResult(runtime, '"$singleCharValue"');
      });

      test('handles variable name with numbers', () {
        // TERM is a common variable, LC_ALL contains numbers in name pattern
        final String termValue = Platform.environment['TERM'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("TERM")');
        checkResult(runtime, '"$termValue"');
      });

      test('returns empty string for variable name starting with number', () {
        // Environment variable names starting with numbers are unusual
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("1INVALID")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty string for variable name with dash', () {
        // Dashes are typically not valid in env var names
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("INVALID-NAME")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty string for variable name with equals sign', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("INVALID=NAME")',
        );
        checkResult(runtime, '""');
      });

      test('handles variable name with consecutive underscores', () {
        final String value = Platform.environment['__'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("__")');
        checkResult(runtime, '"$value"');
      });

      test('returns empty string for variable name with tab character', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("TAB\\tNAME")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty string for variable name with newline', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("NEW\\nLINE")',
        );
        checkResult(runtime, '""');
      });

      test('handles very long variable name', () {
        // Very long variable names should just return empty string if not found
        final String longName = 'A' * 1000;
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("$longName")',
        );
        checkResult(runtime, '""');
      });

      test('returns empty string for uppercase version of lowercase var', () {
        // Testing case sensitivity in reverse
        final RuntimeFacade runtime = getRuntime('main() = env.get("path")');
        final String pathLower = Platform.environment['path'] ?? '';
        checkResult(runtime, '"$pathLower"');
      });

      test('handles SHELL environment variable', () {
        final String shell = Platform.environment['SHELL'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("SHELL")');
        checkResult(runtime, '"$shell"');
      });

      test('handles PWD environment variable', () {
        final String pwd = Platform.environment['PWD'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("PWD")');
        checkResult(runtime, '"$pwd"');
      });

      test('handles LANG environment variable', () {
        final String lang = Platform.environment['LANG'] ?? '';
        final RuntimeFacade runtime = getRuntime('main() = env.get("LANG")');
        checkResult(runtime, '"$lang"');
      });
    });

    group('env.get in expressions', () {
      test('result can be used in string concatenation', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = str.concat(env.get("HOME"), "/test")',
        );
        checkResult(runtime, '"$home/test"');
      });

      test('result can be compared for equality', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = comp.eq(env.get("HOME"), "$home")',
        );
        checkResult(runtime, 'true');
      });

      test('result can be compared for inequality with empty string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = comp.eq(env.get("NONEXISTENT"), "")',
        );
        checkResult(runtime, 'true');
      });

      test('result length can be computed', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = str.length(env.get("HOME"))',
        );
        checkResult(runtime, '${home.length}');
      });

      test('result can be checked for emptiness', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.isEmpty(env.get("NONEXISTENT"))',
        );
        checkResult(runtime, 'true');
      });

      test('existing variable is not empty', () {
        final String home = Platform.environment['HOME'] ?? '';
        // Only test if HOME is actually set and non-empty
        if (home.isNotEmpty) {
          final RuntimeFacade runtime = getRuntime(
            'main() = str.isEmpty(env.get("HOME"))',
          );
          checkResult(runtime, 'false');
        }
      });

      test('result can be used in conditional', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (str.isEmpty(env.get("NONEXISTENT"))) "empty" else "has value"',
        );
        checkResult(runtime, '"empty"');
      });

      test('result can be used with str.uppercase', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = str.uppercase(env.get("HOME"))',
        );
        checkResult(runtime, '"${home.toUpperCase()}"');
      });

      test('multiple env.get calls can be used together', () {
        final String home = Platform.environment['HOME'] ?? '';
        final String user = Platform.environment['USER'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = str.concat(env.get("HOME"), str.concat(":", env.get("USER")))',
        );
        checkResult(runtime, '"$home:$user"');
      });

      test('env.get with dynamic variable name from expression', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get(str.concat("HO", "ME"))',
        );
        checkResult(runtime, '"$home"');
      });

      test('result can be compared with another env.get result', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = comp.eq(env.get("HOME"), env.get("HOME"))',
        );
        checkResult(runtime, 'true');
      });
    });

    group('env.get return type verification', () {
      test('always returns a string type', () {
        final RuntimeFacade runtime = getRuntime('main() = env.get("HOME")');
        final String result = runtime.executeMain();
        // Result should be a quoted string
        expect(result.startsWith('"'), isTrue);
        expect(result.endsWith('"'), isTrue);
      });

      test('returns empty string as quoted empty string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.get("DEFINITELY_DOES_NOT_EXIST_12345")',
        );
        checkResult(runtime, '""');
      });

      test('result type can be used with string functions', () {
        // This verifies the return type is compatible with string operations
        final RuntimeFacade runtime = getRuntime(
          'main() = str.reverse(env.get("NONEXISTENT"))',
        );
        checkResult(runtime, '""');
      });
    });

    group('env.has', () {
      test('returns false for non-existent variable', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("INVALID_VARIABLE_THAT_DOES_NOT_EXIST_12345")',
        );
        checkResult(runtime, 'false');
      });

      test('returns true for existing variable HOME', () {
        final bool hasHome = Platform.environment.containsKey('HOME');
        final RuntimeFacade runtime = getRuntime('main() = env.has("HOME")');
        checkResult(runtime, '$hasHome');
      });

      test('returns true for existing variable PATH', () {
        final bool hasPath = Platform.environment.containsKey('PATH');
        final RuntimeFacade runtime = getRuntime('main() = env.has("PATH")');
        checkResult(runtime, '$hasPath');
      });

      test('returns true for existing variable USER', () {
        final bool hasUser = Platform.environment.containsKey('USER');
        final RuntimeFacade runtime = getRuntime('main() = env.has("USER")');
        checkResult(runtime, '$hasUser');
      });

      test('returns false for empty variable name', () {
        final bool hasEmpty = Platform.environment.containsKey('');
        final RuntimeFacade runtime = getRuntime('main() = env.has("")');
        checkResult(runtime, '$hasEmpty');
      });

      test('is case-sensitive for variable names', () {
        final bool hasHomeUpper = Platform.environment.containsKey('HOME');
        final bool hasHomeLower = Platform.environment.containsKey('home');
        final RuntimeFacade runtimeUpper = getRuntime(
          'main() = env.has("HOME")',
        );
        final RuntimeFacade runtimeLower = getRuntime(
          'main() = env.has("home")',
        );
        checkResult(runtimeUpper, '$hasHomeUpper');
        checkResult(runtimeLower, '$hasHomeLower');
      });

      test('returns false for variable name with only spaces', () {
        final bool hasSpaces = Platform.environment.containsKey('   ');
        final RuntimeFacade runtime = getRuntime('main() = env.has("   ")');
        checkResult(runtime, '$hasSpaces');
      });

      test('handles variable names with underscores', () {
        final bool hasLcAll = Platform.environment.containsKey('LC_ALL');
        final RuntimeFacade runtime = getRuntime('main() = env.has("LC_ALL")');
        checkResult(runtime, '$hasLcAll');
      });
    });

    group('env.has type errors', () {
      test('throws InvalidArgumentTypesError when given a number', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(42)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(true)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Boolean)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a list', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(["HOME"])');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (List)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has({"key": "value"})',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Map)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given false', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(false)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Boolean)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given zero', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(0)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given negative number', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(-1)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given floating point', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has(3.14)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given empty list', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has([])');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (List)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given empty map', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has({})');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.has"'),
                contains('Expected: (String)'),
                contains('Actual: (Map)'),
              ),
            ),
          ),
        );
      });
    });

    group('env.has edge cases', () {
      test('handles single character variable name', () {
        final bool hasSingleChar = Platform.environment.containsKey('_');
        final RuntimeFacade runtime = getRuntime('main() = env.has("_")');
        checkResult(runtime, '$hasSingleChar');
      });

      test('handles TERM variable', () {
        final bool hasTerm = Platform.environment.containsKey('TERM');
        final RuntimeFacade runtime = getRuntime('main() = env.has("TERM")');
        checkResult(runtime, '$hasTerm');
      });

      test('returns false for variable name starting with number', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("1INVALID")',
        );
        checkResult(runtime, 'false');
      });

      test('returns false for variable name with dash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("INVALID-NAME")',
        );
        checkResult(runtime, 'false');
      });

      test('returns false for variable name with equals sign', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("INVALID=NAME")',
        );
        checkResult(runtime, 'false');
      });

      test('handles variable name with consecutive underscores', () {
        final bool hasDoubleUnderscore = Platform.environment.containsKey('__');
        final RuntimeFacade runtime = getRuntime('main() = env.has("__")');
        checkResult(runtime, '$hasDoubleUnderscore');
      });

      test('returns false for variable name with tab character', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("TAB\\tNAME")',
        );
        checkResult(runtime, 'false');
      });

      test('returns false for variable name with newline', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("NEW\\nLINE")',
        );
        checkResult(runtime, 'false');
      });

      test('handles very long variable name', () {
        final String longName = 'A' * 1000;
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("$longName")',
        );
        checkResult(runtime, 'false');
      });

      test('handles SHELL environment variable', () {
        final bool hasShell = Platform.environment.containsKey('SHELL');
        final RuntimeFacade runtime = getRuntime('main() = env.has("SHELL")');
        checkResult(runtime, '$hasShell');
      });

      test('handles PWD environment variable', () {
        final bool hasPwd = Platform.environment.containsKey('PWD');
        final RuntimeFacade runtime = getRuntime('main() = env.has("PWD")');
        checkResult(runtime, '$hasPwd');
      });

      test('handles LANG environment variable', () {
        final bool hasLang = Platform.environment.containsKey('LANG');
        final RuntimeFacade runtime = getRuntime('main() = env.has("LANG")');
        checkResult(runtime, '$hasLang');
      });
    });

    group('env.has in expressions', () {
      test('result can be used in conditional', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (env.has("HOME")) "exists" else "not found"',
        );
        final bool hasHome = Platform.environment.containsKey('HOME');
        checkResult(runtime, hasHome ? '"exists"' : '"not found"');
      });

      test('result can be negated', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool.not(env.has("NONEXISTENT_VAR_12345"))',
        );
        checkResult(runtime, 'true');
      });

      test('result can be combined with bool.and', () {
        final bool hasHome = Platform.environment.containsKey('HOME');
        final bool hasPath = Platform.environment.containsKey('PATH');
        final RuntimeFacade runtime = getRuntime(
          'main() = bool.and(env.has("HOME"), env.has("PATH"))',
        );
        checkResult(runtime, '${hasHome && hasPath}');
      });

      test('result can be combined with bool.or', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool.or(env.has("NONEXISTENT_12345"), env.has("HOME"))',
        );
        final bool hasHome = Platform.environment.containsKey('HOME');
        checkResult(runtime, '$hasHome');
      });

      test('env.has with dynamic variable name from expression', () {
        final bool hasHome = Platform.environment.containsKey('HOME');
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has(str.concat("HO", "ME"))',
        );
        checkResult(runtime, '$hasHome');
      });

      test('env.has and env.get can be used together', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (env.has("HOME")) env.get("HOME") else "default"',
        );
        final String home = Platform.environment['HOME'] ?? '';
        final bool hasHome = Platform.environment.containsKey('HOME');
        checkResult(runtime, hasHome ? '"$home"' : '"default"');
      });

      test('multiple env.has calls can be used together', () {
        final bool hasHome = Platform.environment.containsKey('HOME');
        final bool hasUser = Platform.environment.containsKey('USER');
        final RuntimeFacade runtime = getRuntime(
          'main() = [env.has("HOME"), env.has("USER")]',
        );
        checkResult(runtime, '[$hasHome, $hasUser]');
      });
    });

    group('env.has return type verification', () {
      test('always returns a boolean type', () {
        final RuntimeFacade runtime = getRuntime('main() = env.has("HOME")');
        final String result = runtime.executeMain();
        expect(result == 'true' || result == 'false', isTrue);
      });

      test('returns false for definitely non-existent variable', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = env.has("DEFINITELY_DOES_NOT_EXIST_ABCDEF_12345")',
        );
        checkResult(runtime, 'false');
      });

      test('result type can be used with boolean functions', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool.not(env.has("NONEXISTENT_VAR"))',
        );
        checkResult(runtime, 'true');
      });
    });
  });
}
