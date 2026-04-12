@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Constants', () {
    test('boolean true', () {
      final RuntimeFacade runtime = getRuntime('main() = true');
      checkResult(runtime, true);
    });

    test('boolean false', () {
      final RuntimeFacade runtime = getRuntime('main() = false');
      checkResult(runtime, false);
    });

    test('positive integer', () {
      final RuntimeFacade runtime = getRuntime('main() = 42');
      checkResult(runtime, 42);
    });

    test('zero', () {
      final RuntimeFacade runtime = getRuntime('main() = 0');
      checkResult(runtime, 0);
    });

    test('negative integer', () {
      final RuntimeFacade runtime = getRuntime('main() = -7');
      checkResult(runtime, -7);
    });

    test('decimal number', () {
      final RuntimeFacade runtime = getRuntime('main() = 3.14');
      checkResult(runtime, 3.14);
    });

    test('string', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"');
      checkResult(runtime, '"Hello"');
    });

    test('empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = ""');
      checkResult(runtime, '""');
    });

    test('list of numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = []');
      checkResult(runtime, []);
    });

    test('nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[1, 2], [3, 4]]');
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list of mixed types', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, "two", true]');
      checkResult(runtime, [1, '"two"', true]);
    });

    test('single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = [42]');
      checkResult(runtime, [42]);
    });

    test('deeply nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('list with expressions', () {
      final RuntimeFacade runtime = getRuntime('main() = [1 + 2, 3 * 4]');
      checkResult(runtime, [3, 12]);
    });
  });

  group('Number Constants', () {
    test('negative decimal number', () {
      final RuntimeFacade runtime = getRuntime('main() = -3.14');
      checkResult(runtime, -3.14);
    });

    test('large integer', () {
      final RuntimeFacade runtime = getRuntime('main() = 9007199254740991');
      checkResult(runtime, 9007199254740991);
    });

    test('small decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = 0.0001');
      checkResult(runtime, 0.0001);
    });

    test('integer with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_000_000');
      checkResult(runtime, 1000000);
    });

    test('decimal with underscore separator', () {
      final RuntimeFacade runtime = getRuntime('main() = 3.14_159');
      checkResult(runtime, 3.14159);
    });

    test('scientific notation positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e6');
      checkResult(runtime, 1e6);
    });

    test('scientific notation explicit positive exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e+6');
      checkResult(runtime, 1e6);
    });

    test('scientific notation negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e-3');
      checkResult(runtime, 0.001);
    });

    test('decimal with scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main() = 2.5e3');
      checkResult(runtime, 2500.0);
    });

    test('negative zero', () {
      final RuntimeFacade runtime = getRuntime('main() = -0');
      checkResult(runtime, 0);
    });

    test('decimal with trailing zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = 1.00');
      checkResult(runtime, 1.0);
    });
  });

  group('String Constants', () {
    test('single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main() = 'Hello'");
      checkResult(runtime, '"Hello"');
    });

    test('empty single quoted string', () {
      final RuntimeFacade runtime = getRuntime("main() = ''");
      checkResult(runtime, '""');
    });

    test('string with newline escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello\\nWorld"');
      checkResult(runtime, '"Hello\nWorld"');
    });

    test('string with tab escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello\\tWorld"');
      checkResult(runtime, '"Hello\tWorld"');
    });

    test('string with escaped backslash', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello\\\\World"');
      checkResult(runtime, '"Hello\\World"');
    });

    test('string with escaped double quote', () {
      final RuntimeFacade runtime = getRuntime('main() = "Say \\"hello\\""');
      checkResult(runtime, '"Say "hello""');
    });

    test('string with escaped single quote in single quotes', () {
      final RuntimeFacade runtime = getRuntime("main() = 'It\\'s fine'");
      checkResult(runtime, '"It\'s fine"');
    });

    test('string with hex escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\x48\\x69"');
      checkResult(runtime, '"Hi"');
    });

    test('string with unicode escape four digits', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u0041"');
      checkResult(runtime, '"A"');
    });

    test('string with braced unicode escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{1F600}"');
      checkResult(runtime, '"😀"');
    });

    test('string with multiple escape sequences', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\n\\t\\\\\\""');
      checkResult(runtime, '"\n\t\\""');
    });

    test('single quoted string with double quote', () {
      final RuntimeFacade runtime = getRuntime('main() = \'Say "hello"\'');
      checkResult(runtime, '"Say "hello""');
    });

    test('double quoted string with single quote', () {
      final RuntimeFacade runtime = getRuntime("main() = \"It's fine\"");
      checkResult(runtime, '"It\'s fine"');
    });

    test('string with whitespace only', () {
      final RuntimeFacade runtime = getRuntime('main() = "   "');
      checkResult(runtime, '"   "');
    });

    test('string with unicode characters', () {
      final RuntimeFacade runtime = getRuntime('main() = "αβγ"');
      checkResult(runtime, '"αβγ"');
    });

    test('string with emoji', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello 👋"');
      checkResult(runtime, '"Hello 👋"');
    });
  });

  group('Map Constants', () {
    test('empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = {}');
      checkResult(runtime, {});
    });

    test('map with single string key', () {
      final RuntimeFacade runtime = getRuntime('main() = {"key": 42}');
      checkResult(runtime, {'"key"': 42});
    });

    test('map with multiple entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": 1, "b": 2, "c": 3}',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2, '"c"': 3});
    });

    test('map with number key', () {
      final RuntimeFacade runtime = getRuntime('main() = {1: "one", 2: "two"}');
      checkResult(runtime, {1: '"one"', 2: '"two"'});
    });

    test('map with boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {true: "yes", false: "no"}',
      );
      checkResult(runtime, {true: '"yes"', false: '"no"'});
    });

    test('map with mixed key types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"name": "John", 1: "first", true: "active"}',
      );
      checkResult(runtime, {
        '"name"': '"John"',
        1: '"first"',
        true: '"active"',
      });
    });

    test('map with mixed value types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"str": "hello", "num": 42, "bool": true, "list": [1, 2]}',
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
        'main() = {"outer": {"inner": 42}}',
      );
      checkResult(runtime, {
        '"outer"': {'"inner"': 42},
      });
    });

    test('map with list value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"items": [1, 2, 3]}');
      checkResult(runtime, {
        '"items"': [1, 2, 3],
      });
    });

    test('map with expression value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"sum": 1 + 2}');
      checkResult(runtime, {'"sum"': 3});
    });

    test('deeply nested map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": {"b": {"c": 1}}}',
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
        'main() = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('map containing list of maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"items": [{"x": 1}, {"y": 2}]}',
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
        'main() = {"data": [1, [2, 3], {"nested": true}]}',
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

  group('Additional Number Constants', () {
    test('very large scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e308');
      checkResult(runtime, 1e308);
    });

    test('very small scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e-308');
      checkResult(runtime, 1e-308);
    });

    test('negative large integer', () {
      final RuntimeFacade runtime = getRuntime('main() = -9007199254740991');
      checkResult(runtime, -9007199254740991);
    });

    test('decimal zero', () {
      final RuntimeFacade runtime = getRuntime('main() = 0.0');
      checkResult(runtime, 0.0);
    });

    test('negative decimal zero', () {
      final RuntimeFacade runtime = getRuntime('main() = -0.0');
      checkResult(runtime, 0.0);
    });

    test('scientific notation with capital E', () {
      final RuntimeFacade runtime = getRuntime('main() = 1E6');
      checkResult(runtime, 1e6);
    });

    test('negative scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main() = -1e6');
      checkResult(runtime, -1e6);
    });

    test('decimal scientific notation with negative exponent', () {
      final RuntimeFacade runtime = getRuntime('main() = 2.5e-3');
      checkResult(runtime, 0.0025);
    });

    test('integer with leading zeros', () {
      final RuntimeFacade runtime = getRuntime('main() = 007');
      checkResult(runtime, 7);
    });

    test('decimal with leading zeros after dot', () {
      final RuntimeFacade runtime = getRuntime('main() = 1.001');
      checkResult(runtime, 1.001);
    });

    test('very precise decimal', () {
      final RuntimeFacade runtime = getRuntime('main() = 3.141592653589793');
      checkResult(runtime, 3.141592653589793);
    });

    test('multiple underscore groups', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_234_567_890');
      checkResult(runtime, 1234567890);
    });

    test('underscore in exponent part', () {
      final RuntimeFacade runtime = getRuntime('main() = 1e1_0');
      checkResult(runtime, 1e10);
    });

    test('one', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      checkResult(runtime, 1);
    });

    test('negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = -1');
      checkResult(runtime, -1);
    });
  });

  group('Additional String Constants', () {
    test('string with carriage return via hex escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello\\x0DWorld"');
      checkResult(runtime, '"Hello\rWorld"');
    });

    test('string with carriage return and newline via hex escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "Line1\\x0D\\nLine2"');
      checkResult(runtime, '"Line1\r\nLine2"');
    });

    test('string with lowercase hex escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\x61\\x62\\x63"');
      checkResult(runtime, '"abc"');
    });

    test('string with uppercase hex escape', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\x41\\x42\\x43"');
      checkResult(runtime, '"ABC"');
    });

    test('string with unicode null character', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u0000"');
      checkResult(runtime, '"\u0000"');
    });

    test('string with unicode max BMP character', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\uFFFF"');
      checkResult(runtime, '"\uFFFF"');
    });

    test('string with braced unicode single digit', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{41}"');
      checkResult(runtime, '"A"');
    });

    test('string with braced unicode six digits', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{01F600}"');
      checkResult(runtime, '"😀"');
    });

    test('string with mixed content and escapes', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "Name:\\tJohn\\nAge:\\t30"',
      );
      checkResult(runtime, '"Name:\tJohn\nAge:\t30"');
    });

    test('single character string', () {
      final RuntimeFacade runtime = getRuntime('main() = "a"');
      checkResult(runtime, '"a"');
    });

    test('string with numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = "12345"');
      checkResult(runtime, '"12345"');
    });

    test('string with special characters', () {
      final RuntimeFacade runtime = getRuntime('main() = "!@#\$%^&*()"');
      checkResult(runtime, '"!@#\$%^&*()"');
    });

    test('string with spaces', () {
      final RuntimeFacade runtime = getRuntime('main() = "hello world"');
      checkResult(runtime, '"hello world"');
    });

    test('long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"',
      );
      checkResult(
        runtime,
        '"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"',
      );
    });

    test('string with mixed quotes escaped', () {
      final RuntimeFacade runtime = getRuntime(
        "main() = \"She said \\\"It\\'s fine\\\"\"",
      );
      checkResult(runtime, '"She said "It\'s fine""');
    });

    test('single quoted string with escaped single quote', () {
      final RuntimeFacade runtime = getRuntime("main() = 'Don\\'t worry'");
      checkResult(runtime, '"Don\'t worry"');
    });

    test('string with backslash before regular character preserved', () {
      final RuntimeFacade runtime = getRuntime('main() = "path\\\\to\\\\file"');
      checkResult(runtime, '"path\\to\\file"');
    });
  });

  group('Additional List Constants', () {
    test('list with boolean values', () {
      final RuntimeFacade runtime = getRuntime('main() = [true, false, true]');
      checkResult(runtime, [true, false, true]);
    });

    test('list with string values', () {
      final RuntimeFacade runtime = getRuntime('main() = ["a", "b", "c"]');
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('list with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = [-1, -2, -3]');
      checkResult(runtime, [-1, -2, -3]);
    });

    test('list with decimal numbers', () {
      final RuntimeFacade runtime = getRuntime('main() = [1.1, 2.2, 3.3]');
      checkResult(runtime, [1.1, 2.2, 3.3]);
    });

    test('list with nested empty lists', () {
      final RuntimeFacade runtime = getRuntime('main() = [[], [], []]');
      checkResult(runtime, [[], [], []]);
    });

    test('list with mixed nesting depths', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, [2, [3, [4]]]]');
      checkResult(runtime, [
        1,
        [
          2,
          [
            3,
            [4],
          ],
        ],
      ]);
    });

    test('list with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]',
      );
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('list with arithmetic expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1 + 1, 2 * 2, 3 - 1, 8 / 2]',
      );
      checkResult(runtime, [2, 4, 2, 4.0]);
    });

    test('list with comparison expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1 < 2, 2 > 1, 1 == 1, 1 != 2]',
      );
      checkResult(runtime, [true, true, true, true]);
    });

    test('list with conditional expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [if (true) 1 else 0, if (false) 1 else 0]',
      );
      checkResult(runtime, [1, 0]);
    });

    test('list containing empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = [{}]');
      checkResult(runtime, [{}]);
    });

    test('list with single nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[1, 2, 3]]');
      checkResult(runtime, [
        [1, 2, 3],
      ]);
    });
  });

  group('Additional Map Constants', () {
    test('map with negative number key', () {
      final RuntimeFacade runtime = getRuntime('main() = {-1: "negative one"}');
      checkResult(runtime, {-1: '"negative one"'});
    });

    test('map with decimal number key', () {
      final RuntimeFacade runtime = getRuntime('main() = {3.14: "pi"}');
      checkResult(runtime, {3.14: '"pi"'});
    });

    test('map with empty string key', () {
      final RuntimeFacade runtime = getRuntime('main() = {"": "empty"}');
      checkResult(runtime, {'""': '"empty"'});
    });

    test('map with empty list value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"items": []}');
      checkResult(runtime, {'"items"': []});
    });

    test('map with empty map value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"nested": {}}');
      checkResult(runtime, {'"nested"': {}});
    });

    test('map with boolean value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"active": true, "deleted": false}',
      );
      checkResult(runtime, {'"active"': true, '"deleted"': false});
    });

    test('map with expression key', () {
      final RuntimeFacade runtime = getRuntime('main() = {1 + 1: "two"}');
      checkResult(runtime, {2: '"two"'});
    });

    test('map with nested expression value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"result": 2 * 3 + 1}',
      );
      checkResult(runtime, {'"result"': 7});
    });

    test('map with string containing special characters as key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"key with spaces": 42}',
      );
      checkResult(runtime, {'"key with spaces"': 42});
    });

    test('map with many entries', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5}',
      );
      checkResult(runtime, {
        '"a"': 1,
        '"b"': 2,
        '"c"': 3,
        '"d"': 4,
        '"e"': 5,
      });
    });

    test('map with list of lists value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"matrix": [[1, 2], [3, 4]]}',
      );
      checkResult(runtime, {
        '"matrix"': [
          [1, 2],
          [3, 4],
        ],
      });
    });

    test('map with deeply nested map value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"level1": {"level2": {"level3": {"level4": 42}}}}',
      );
      checkResult(runtime, {
        '"level1"': {
          '"level2"': {
            '"level3"': {'"level4"': 42},
          },
        },
      });
    });

    test('map with conditional expression value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"status": if (true) "ok" else "error"}',
      );
      checkResult(runtime, {'"status"': '"ok"'});
    });

    test('map with zero key', () {
      final RuntimeFacade runtime = getRuntime('main() = {0: "zero"}');
      checkResult(runtime, {0: '"zero"'});
    });

    test('map with single character string key', () {
      final RuntimeFacade runtime = getRuntime('main() = {"x": 10, "y": 20}');
      checkResult(runtime, {'"x"': 10, '"y"': 20});
    });
  });

  group('Additional Mixed Collection Constants', () {
    test('list of empty maps', () {
      final RuntimeFacade runtime = getRuntime('main() = [{}, {}, {}]');
      checkResult(runtime, [{}, {}, {}]);
    });

    test('map with list of empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"lists": [[], [], []]}',
      );
      checkResult(runtime, {
        '"lists"': [[], [], []],
      });
    });

    test('deeply nested mixed structure', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [{"a": [{"b": [1, 2]}]}]',
      );
      checkResult(runtime, [
        {
          '"a"': [
            {
              '"b"': [1, 2],
            },
          ],
        },
      ]);
    });

    test('map with list containing maps with lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"data": [{"nums": [1, 2]}, {"nums": [3, 4]}]}',
      );
      checkResult(runtime, {
        '"data"': [
          {
            '"nums"': [1, 2],
          },
          {
            '"nums"': [3, 4],
          },
        ],
      });
    });

    test('list with maps of different structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [{"a": 1}, {"b": "two"}, {"c": true}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': '"two"'},
        {'"c"': true},
      ]);
    });

    test('map with heterogeneous list values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"numbers": [1, 2, 3], "strings": ["a", "b"], "mixed": [1, "x", true]}',
      );
      checkResult(runtime, {
        '"numbers"': [1, 2, 3],
        '"strings"': ['"a"', '"b"'],
        '"mixed"': [1, '"x"', true],
      });
    });

    test('list with alternating types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, "a", 2, "b", 3, "c"]',
      );
      checkResult(runtime, [1, '"a"', 2, '"b"', 3, '"c"']);
    });

    test('map with list key and value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"items": [1, 2], "names": ["a", "b"]}',
      );
      checkResult(runtime, {
        '"items"': [1, 2],
        '"names"': ['"a"', '"b"'],
      });
    });
  });

  group('Boolean Constants Edge Cases', () {
    test('boolean in list', () {
      final RuntimeFacade runtime = getRuntime('main() = [true]');
      checkResult(runtime, [true]);
    });

    test('boolean in map value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"flag": true}');
      checkResult(runtime, {'"flag"': true});
    });

    test('boolean in map key', () {
      final RuntimeFacade runtime = getRuntime('main() = {true: 1}');
      checkResult(runtime, {true: 1});
    });

    test('negated boolean true', () {
      final RuntimeFacade runtime = getRuntime('main() = !true');
      checkResult(runtime, false);
    });

    test('negated boolean false', () {
      final RuntimeFacade runtime = getRuntime('main() = !false');
      checkResult(runtime, true);
    });

    test('double negation', () {
      final RuntimeFacade runtime = getRuntime('main() = !!true');
      checkResult(runtime, true);
    });
  });

  group('Expression in Constants', () {
    test('parenthesized expression', () {
      final RuntimeFacade runtime = getRuntime('main() = (1 + 2) * 3');
      checkResult(runtime, 9);
    });

    test('nested parenthesized expression', () {
      final RuntimeFacade runtime = getRuntime('main() = ((1 + 2) * (3 + 4))');
      checkResult(runtime, 21);
    });

    test('expression as list element', () {
      final RuntimeFacade runtime = getRuntime('main() = [(1 + 2)]');
      checkResult(runtime, [3]);
    });

    test('expression as map key', () {
      final RuntimeFacade runtime = getRuntime('main() = {(1 + 2): "three"}');
      checkResult(runtime, {3: '"three"'});
    });

    test('expression as map value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"three": (1 + 2)}');
      checkResult(runtime, {'"three"': 3});
    });

    test('complex expression in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [if (1 < 2) 10 else 20]',
      );
      checkResult(runtime, [10]);
    });

    test('string concatenation equivalent in list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [str.concat("Hello", " World")]',
      );
      checkResult(runtime, ['"Hello World"']);
    });
  });

  group('String Error Cases', () {
    test('unterminated double quoted string', () {
      expect(
        () => getRuntime('main() = "unterminated'),
        throwsA(isA<UnterminatedStringError>()),
      );
    });

    test('unterminated single quoted string', () {
      expect(
        () => getRuntime("main() = 'unterminated"),
        throwsA(isA<UnterminatedStringError>()),
      );
    });

    test('invalid escape sequence a', () {
      expect(
        () => getRuntime('main() = "test\\a"'),
        throwsA(isA<InvalidEscapeSequenceError>()),
      );
    });

    test('invalid escape sequence z', () {
      expect(
        () => getRuntime('main() = "test\\z"'),
        throwsA(isA<InvalidEscapeSequenceError>()),
      );
    });

    test('invalid escape sequence zero', () {
      expect(
        () => getRuntime('main() = "test\\0"'),
        throwsA(isA<InvalidEscapeSequenceError>()),
      );
    });

    test('invalid hex escape non hex character', () {
      expect(
        () => getRuntime('main() = "\\xGH"'),
        throwsA(isA<InvalidHexEscapeError>()),
      );
    });

    test('invalid hex escape incomplete', () {
      expect(
        () => getRuntime('main() = "\\x4"'),
        throwsA(isA<InvalidHexEscapeError>()),
      );
    });

    test('invalid unicode escape non hex character', () {
      expect(
        () => getRuntime('main() = "\\uGHIJ"'),
        throwsA(isA<InvalidHexEscapeError>()),
      );
    });

    test('invalid unicode escape incomplete', () {
      expect(
        () => getRuntime('main() = "\\u00"'),
        throwsA(isA<InvalidHexEscapeError>()),
      );
    });

    test('empty braced unicode escape', () {
      expect(
        () => getRuntime('main() = "\\u{}"'),
        throwsA(isA<InvalidBracedEscapeError>()),
      );
    });

    test('braced unicode escape too many digits', () {
      expect(
        () => getRuntime('main() = "\\u{1234567}"'),
        throwsA(isA<InvalidBracedEscapeError>()),
      );
    });

    test('braced unicode escape invalid character', () {
      expect(
        () => getRuntime('main() = "\\u{12GH}"'),
        throwsA(isA<InvalidBracedEscapeError>()),
      );
    });

    test('braced unicode escape code point too large', () {
      expect(
        () => getRuntime('main() = "\\u{110000}"'),
        throwsA(isA<InvalidCodePointError>()),
      );
    });

    test('unterminated string with backslash at end', () {
      expect(
        () => getRuntime('main() = "test\\'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('unterminated string with incomplete hex escape', () {
      expect(
        () => getRuntime('main() = "test\\x4'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('unterminated string with incomplete braced unicode escape', () {
      expect(
        () => getRuntime('main() = "test\\u{123'),
        throwsA(isA<LexicalError>()),
      );
    });
  });

  group('Number Error Cases', () {
    test('invalid character after integer', () {
      expect(
        () => getRuntime('main() = 42a'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('consecutive underscores in integer', () {
      expect(
        () => getRuntime('main() = 1__000'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('trailing underscore in integer', () {
      expect(
        () => getRuntime('main() = 1000_'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('underscore before decimal point', () {
      expect(
        () => getRuntime('main() = 1_.5'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('consecutive underscores in decimal', () {
      expect(
        () => getRuntime('main() = 1.0__5'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('trailing underscore in decimal', () {
      expect(
        () => getRuntime('main() = 1.5_'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('incomplete exponent', () {
      expect(
        () => getRuntime('main() = 1e'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('incomplete exponent with sign', () {
      expect(
        () => getRuntime('main() = 1e+'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('invalid character after exponent', () {
      expect(
        () => getRuntime('main() = 1ea'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('underscore after exponent marker', () {
      expect(
        () => getRuntime('main() = 1e_5'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('underscore after exponent sign', () {
      expect(
        () => getRuntime('main() = 1e+_5'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('consecutive underscores in exponent', () {
      expect(
        () => getRuntime('main() = 1e1__0'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('trailing underscore in exponent', () {
      expect(
        () => getRuntime('main() = 1e5_'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('double decimal point', () {
      expect(
        () => getRuntime('main() = 1..5'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('decimal point without digits after', () {
      expect(
        () => getRuntime('main() = 1.'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });

    test('decimal point followed by letter', () {
      expect(
        () => getRuntime('main() = 1.a'),
        throwsA(isA<InvalidCharacterError>()),
      );
    });
  });

  group('Additional Number Edge Cases', () {
    test('positive infinity', () {
      final RuntimeFacade runtime = getRuntime('main() = num.infinity()');
      checkResult(runtime, double.infinity);
    });

    test('negative infinity', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = num.negative(num.infinity())',
      );
      checkResult(runtime, double.negativeInfinity);
    });

    test('number at double max finite', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 1.7976931348623157e+308',
      );
      checkResult(runtime, 1.7976931348623157e+308);
    });

    test('number at double min positive', () {
      final RuntimeFacade runtime = getRuntime('main() = 5e-324');
      checkResult(runtime, 5e-324);
    });

    test('number with many decimal places', () {
      final RuntimeFacade runtime = getRuntime('main() = 0.123456789012345');
      checkResult(runtime, 0.123456789012345);
    });

    test('integer max safe', () {
      final RuntimeFacade runtime = getRuntime('main() = 9007199254740991');
      checkResult(runtime, 9007199254740991);
    });

    test('integer min safe', () {
      final RuntimeFacade runtime = getRuntime('main() = -9007199254740991');
      checkResult(runtime, -9007199254740991);
    });

    test('underscore at different positions', () {
      final RuntimeFacade runtime = getRuntime('main() = 1_2_3_4');
      checkResult(runtime, 1234);
    });

    test('scientific notation with decimal and underscore', () {
      final RuntimeFacade runtime = getRuntime('main() = 1.23_45e2');
      checkResult(runtime, 123.45);
    });
  });

  group('Additional String Edge Cases', () {
    test('string with all escape sequences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "\\n\\t\\\\\\"\\x41\\u0042\\u{43}"',
      );
      checkResult(runtime, '"\n\t\\"ABC"');
    });

    test('string with hex escape boundary lower', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\x00"');
      checkResult(runtime, '"\x00"');
    });

    test('string with hex escape boundary upper', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\xFF"');
      checkResult(runtime, '"\xFF"');
    });

    test('string with unicode escape boundary lower', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u0000"');
      checkResult(runtime, '"\u0000"');
    });

    test('string with unicode escape boundary upper BMP', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\uFFFF"');
      checkResult(runtime, '"\uFFFF"');
    });

    test('string with braced unicode single hex digit', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{0}"');
      checkResult(runtime, '"\u0000"');
    });

    test('string with braced unicode max valid code point', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\u{10FFFF}"');
      checkResult(runtime, '"\u{10FFFF}"');
    });

    test('string with mixed case hex digits', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\xAa\\xbB"');
      checkResult(runtime, '"\xAA\xBB"');
    });

    test('string with consecutive escape sequences', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\n\\n\\n"');
      checkResult(runtime, '"\n\n\n"');
    });

    test('string with escape at start', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\nHello"');
      checkResult(runtime, '"\nHello"');
    });

    test('string with escape at end', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello\\n"');
      checkResult(runtime, '"Hello\n"');
    });

    test('very long string', () {
      final String longValue = 'a' * 1000;
      final RuntimeFacade runtime = getRuntime('main() = "$longValue"');
      checkResult(runtime, '"$longValue"');
    });

    test('string with only escape sequences', () {
      final RuntimeFacade runtime = getRuntime('main() = "\\n\\t\\n"');
      checkResult(runtime, '"\n\t\n"');
    });
  });

  group('Additional Collection Edge Cases', () {
    test('list with single empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = [""]');
      checkResult(runtime, ['""']);
    });

    test('list with single boolean true', () {
      final RuntimeFacade runtime = getRuntime('main() = [true]');
      checkResult(runtime, [true]);
    });

    test('list with single boolean false', () {
      final RuntimeFacade runtime = getRuntime('main() = [false]');
      checkResult(runtime, [false]);
    });

    test('list with single zero', () {
      final RuntimeFacade runtime = getRuntime('main() = [0]');
      checkResult(runtime, [0]);
    });

    test('list with single empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[]]');
      checkResult(runtime, [[]]);
    });

    test('list with single empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = [{}]');
      checkResult(runtime, [{}]);
    });

    test('map with single boolean true key', () {
      final RuntimeFacade runtime = getRuntime('main() = {true: 1}');
      checkResult(runtime, {true: 1});
    });

    test('map with single boolean false key', () {
      final RuntimeFacade runtime = getRuntime('main() = {false: 0}');
      checkResult(runtime, {false: 0});
    });

    test('map with zero as key', () {
      final RuntimeFacade runtime = getRuntime('main() = {0: "zero"}');
      checkResult(runtime, {0: '"zero"'});
    });

    test('map with negative number as key', () {
      final RuntimeFacade runtime = getRuntime('main() = {-42: "negative"}');
      checkResult(runtime, {-42: '"negative"'});
    });

    test('map with decimal as key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {1.5: "one point five"}',
      );
      checkResult(runtime, {1.5: '"one point five"'});
    });

    test('map with empty string as key', () {
      final RuntimeFacade runtime = getRuntime('main() = {"": "empty key"}');
      checkResult(runtime, {'""': '"empty key"'});
    });

    test('map with single entry empty list value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"list": []}');
      checkResult(runtime, {'"list"': []});
    });

    test('map with single entry empty map value', () {
      final RuntimeFacade runtime = getRuntime('main() = {"map": {}}');
      checkResult(runtime, {'"map"': {}});
    });

    test('deeply nested list five levels', () {
      final RuntimeFacade runtime = getRuntime('main() = [[[[[1]]]]]');
      checkResult(runtime, [
        [
          [
            [
              [1],
            ],
          ],
        ],
      ]);
    });

    test('deeply nested map five levels', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": {"b": {"c": {"d": {"e": 1}}}}}',
      );
      checkResult(runtime, {
        '"a"': {
          '"b"': {
            '"c"': {
              '"d"': {'"e"': 1},
            },
          },
        },
      });
    });

    test('list with many different types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, "two", true, 4.0, [], {}]',
      );
      checkResult(runtime, [1, '"two"', true, 4.0, [], {}]);
    });

    test('map with many different value types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"int": 1, "str": "two", "bool": true, "dec": 4.0, "list": [], "map": {}}',
      );
      checkResult(runtime, {
        '"int"': 1,
        '"str"': '"two"',
        '"bool"': true,
        '"dec"': 4.0,
        '"list"': [],
        '"map"': {},
      });
    });
  });

  group('Whitespace and Formatting', () {
    test('constant with leading whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() =    42');
      checkResult(runtime, 42);
    });

    test('constant with trailing whitespace', () {
      final RuntimeFacade runtime = getRuntime('main() = 42   ');
      checkResult(runtime, 42);
    });

    test('list with whitespace around elements', () {
      final RuntimeFacade runtime = getRuntime('main() = [  1  ,  2  ,  3  ]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('map with whitespace around entries', () {
      final RuntimeFacade runtime = getRuntime('main() = {  "a"  :  1  }');
      checkResult(runtime, {'"a"': 1});
    });

    test('newline in list definition', () {
      final RuntimeFacade runtime = getRuntime('main() = [\n1,\n2,\n3\n]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('newline in map definition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {\n"a": 1,\n"b": 2\n}',
      );
      checkResult(runtime, {'"a"': 1, '"b"': 2});
    });

    test('tab characters as whitespace', () {
      final RuntimeFacade runtime = getRuntime('main()\t=\t42');
      checkResult(runtime, 42);
    });
  });

  group('Logical Constants with Operators', () {
    test('boolean and operation', () {
      final RuntimeFacade runtime = getRuntime('main() = true && true');
      checkResult(runtime, true);
    });

    test('boolean or operation', () {
      final RuntimeFacade runtime = getRuntime('main() = false || true');
      checkResult(runtime, true);
    });

    test('boolean and false result', () {
      final RuntimeFacade runtime = getRuntime('main() = true && false');
      checkResult(runtime, false);
    });

    test('boolean or false result', () {
      final RuntimeFacade runtime = getRuntime('main() = false || false');
      checkResult(runtime, false);
    });

    test('chained negation three times', () {
      final RuntimeFacade runtime = getRuntime('main() = !!!true');
      checkResult(runtime, false);
    });

    test('complex boolean expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (true && false) || (true && true)',
      );
      checkResult(runtime, true);
    });
  });

  group('Numeric Comparison Constants', () {
    test('integer equality true', () {
      final RuntimeFacade runtime = getRuntime('main() = 42 == 42');
      checkResult(runtime, true);
    });

    test('integer equality false', () {
      final RuntimeFacade runtime = getRuntime('main() = 42 == 43');
      checkResult(runtime, false);
    });

    test('integer inequality true', () {
      final RuntimeFacade runtime = getRuntime('main() = 42 != 43');
      checkResult(runtime, true);
    });

    test('integer inequality false', () {
      final RuntimeFacade runtime = getRuntime('main() = 42 != 42');
      checkResult(runtime, false);
    });

    test('decimal comparison', () {
      final RuntimeFacade runtime = getRuntime('main() = 3.14 < 3.15');
      checkResult(runtime, true);
    });

    test('integer decimal equality', () {
      final RuntimeFacade runtime = getRuntime('main() = 1 == 1.0');
      checkResult(runtime, true);
    });

    test('zero equality positive negative', () {
      final RuntimeFacade runtime = getRuntime('main() = 0 == -0');
      checkResult(runtime, true);
    });
  });

  group('Comment Handling', () {
    test('constant with single line comment', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 42 // this is a comment',
      );
      checkResult(runtime, 42);
    });

    test('constant with multi line comment before', () {
      final RuntimeFacade runtime = getRuntime('/* comment */ main() = 42');
      checkResult(runtime, 42);
    });

    test('constant with multi line comment after', () {
      final RuntimeFacade runtime = getRuntime('main() = 42 /* comment */');
      checkResult(runtime, 42);
    });

    test('constant with multi line comment inline', () {
      final RuntimeFacade runtime = getRuntime('main() /* comment */ = 42');
      checkResult(runtime, 42);
    });
  });

  group('Comment Error Cases', () {
    test('unterminated multi line comment', () {
      expect(
        () => getRuntime('main() = /* unterminated'),
        throwsA(isA<UnterminatedCommentError>()),
      );
    });

    test('unterminated multi line comment at start', () {
      expect(
        () => getRuntime('/* unterminated main() = 42'),
        throwsA(isA<UnterminatedCommentError>()),
      );
    });
  });
}
