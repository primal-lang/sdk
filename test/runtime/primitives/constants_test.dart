@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Constants', () {
    test('boolean true', () {
      final RuntimeFacade runtime = getRuntime('main = true');
      checkResult(runtime, true);
    });

    test('boolean false', () {
      final RuntimeFacade runtime = getRuntime('main = false');
      checkResult(runtime, false);
    });

    test('positive integer', () {
      final RuntimeFacade runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('zero', () {
      final RuntimeFacade runtime = getRuntime('main = 0');
      checkResult(runtime, 0);
    });

    test('negative integer', () {
      final RuntimeFacade runtime = getRuntime('main = -7');
      checkResult(runtime, -7);
    });

    test('decimal number', () {
      final RuntimeFacade runtime = getRuntime('main = 3.14');
      checkResult(runtime, 3.14);
    });

    test('string', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello"');
      checkResult(runtime, '"Hello"');
    });

    test('empty string', () {
      final RuntimeFacade runtime = getRuntime('main = ""');
      checkResult(runtime, '""');
    });

    test('list of numbers', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('empty list', () {
      final RuntimeFacade runtime = getRuntime('main = []');
      checkResult(runtime, []);
    });

    test('nested list', () {
      final RuntimeFacade runtime = getRuntime('main = [[1, 2], [3, 4]]');
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list of mixed types', () {
      final RuntimeFacade runtime = getRuntime('main = [1, "two", true]');
      checkResult(runtime, [1, '"two"', true]);
    });

    test('single element list', () {
      final RuntimeFacade runtime = getRuntime('main = [42]');
      checkResult(runtime, [42]);
    });

    test('deeply nested list', () {
      final RuntimeFacade runtime = getRuntime('main = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('list with expressions', () {
      final RuntimeFacade runtime = getRuntime('main = [1 + 2, 3 * 4]');
      checkResult(runtime, [3, 12]);
    });
  });

  group('Number Constants', () {
    test('negative decimal number', () {
      final RuntimeFacade runtime = getRuntime('main = -3.14');
      checkResult(runtime, -3.14);
    });

    test('large integer', () {
      final RuntimeFacade runtime = getRuntime('main = 9007199254740991');
      checkResult(runtime, 9007199254740991);
    });

    test('small decimal', () {
      final RuntimeFacade runtime = getRuntime('main = 0.0001');
      checkResult(runtime, 0.0001);
    });

    test('integer with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main = 1_000_000');
      checkResult(runtime, 1000000);
    });

    test('decimal with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main = 3.14_159');
      checkResult(runtime, 3.14159);
    });

    test('scientific notation positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e6');
      checkResult(runtime, 1e6);
    });

    test('scientific notation explicit positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e+6');
      checkResult(runtime, 1e6);
    });

    test('scientific notation negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main = 1e-3');
      checkResult(runtime, 0.001);
    });

    test('decimal with scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main = 2.5e3');
      checkResult(runtime, 2500.0);
    });

    test('negative zero', () {
      final RuntimeFacade runtime = getRuntime('main = -0');
      checkResult(runtime, 0);
    });

    test('decimal with trailing zeros', () {
      final RuntimeFacade runtime = getRuntime('main = 1.00');
      checkResult(runtime, 1.0);
    });
  });

  group('String Constants', () {
    test('single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main = 'Hello'");
      checkResult(runtime, '"Hello"');
    });

    test('empty single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main = ''");
      checkResult(runtime, '""');
    });

    test('string with newline escape', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello\\nWorld"');
      checkResult(runtime, '"Hello\nWorld"');
    });

    test('string with tab escape', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello\\tWorld"');
      checkResult(runtime, '"Hello\tWorld"');
    });

    test('string with escaped backslash', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello\\\\World"');
      checkResult(runtime, '"Hello\\World"');
    });

    test('string with escaped double quote', () {
      final RuntimeFacade runtime = getRuntime('main = "Say \\"hello\\""');
      checkResult(runtime, '"Say "hello""');
    });

    test('string with escaped single quote in single quotes', () {
      final RuntimeFacade runtime = getRuntime("main = 'It\\'s fine'");
      checkResult(runtime, '"It\'s fine"');
    });

    test('string with hex escape', () {
      final RuntimeFacade runtime = getRuntime('main = "\\x48\\x69"');
      checkResult(runtime, '"Hi"');
    });

    test('string with unicode escape four digits', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u0041"');
      checkResult(runtime, '"A"');
    });

    test('string with braced unicode escape', () {
      final RuntimeFacade runtime = getRuntime('main = "\\u{1F600}"');
      checkResult(runtime, '"😀"');
    });

    test('string with multiple escape sequences', () {
      final RuntimeFacade runtime = getRuntime('main = "\\n\\t\\\\\\""');
      checkResult(runtime, '"\n\t\\""');
    });

    test('single quoted string with double quote', () {
      final RuntimeFacade runtime = getRuntime('main = \'Say "hello"\'');
      checkResult(runtime, '"Say "hello""');
    });

    test('double quoted string with single quote', () {
      final RuntimeFacade runtime = getRuntime("main = \"It's fine\"");
      checkResult(runtime, '"It\'s fine"');
    });

    test('string with whitespace only', () {
      final RuntimeFacade runtime = getRuntime('main = "   "');
      checkResult(runtime, '"   "');
    });

    test('string with unicode characters', () {
      final RuntimeFacade runtime = getRuntime('main = "αβγ"');
      checkResult(runtime, '"αβγ"');
    });

    test('string with emoji', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello 👋"');
      checkResult(runtime, '"Hello 👋"');
    });
  });

  group('Map Constants', () {
    test('empty map', () {
      final RuntimeFacade runtime = getRuntime('main = {}');
      checkResult(runtime, {});
    });

    test('map with single string key', () {
      final RuntimeFacade runtime = getRuntime('main = {"key": 42}');
      checkResult(runtime, {'"key"': 42});
    });

    test('map with multiple entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1, "b": 2, "c": 3}',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2, '"c"': 3});
    });

    test('map with number key', () {
      final RuntimeFacade runtime = getRuntime('main = {1: "one", 2: "two"}');
      checkResult(runtime, {1: '"one"', 2: '"two"'});
    });

    test('map with boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {true: "yes", false: "no"}',
      );
      checkResult(runtime, {true: '"yes"', false: '"no"'});
    });

    test('map with mixed key types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"name": "John", 1: "first", true: "active"}',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        1: '"first"',
        true: '"active"',
      });
    });

    test('map with mixed value types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"str": "hello", "num": 42, "bool": true, "list": [1, 2]}',
      );
      checkResult(runtime, {
        '"str"': '"hello"',
        '"num"': 42,
        '"bool"': true,
        '"list"': [1, 2],
      });
    });

    test('nested map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"outer": {"inner": 42}}',
      );
      checkResult(runtime, {
        '"outer"': {'"inner"': 42},
      });
    });

    test('map with list value', () {
      final RuntimeFacade runtime = getRuntime('main = {"items": [1, 2, 3]}');
      checkResult(runtime, {
        '"items"': [1, 2, 3],
      });
    });

    test('map with expression value', () {
      final RuntimeFacade runtime = getRuntime('main = {"sum": 1 + 2}');
      checkResult(runtime, {'"sum"': 3});
    });

    test('deeply nested map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": {"b": {"c": 1}}}',
      );
      checkResult(runtime, {
        '"a"': {
          '"b"': {'"c"': 1},
        },
      });
    });
  });

  group('Mixed Collection Constants', () {
    test('list containing maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('map containing list of maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"items": [{"x": 1}, {"y": 2}]}',
      );
      checkResult(runtime, {
        '"items"': [
          {'"x"': 1},
          {'"y"': 2},
        ],
      });
    });

    test('complex nested structure', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"data": [1, [2, 3], {"nested": true}]}',
      );
      checkResult(runtime, {
        '"data"': [
          1,
          [2, 3],
          {'"nested"': true},
        ],
      });
    });
  });
}
