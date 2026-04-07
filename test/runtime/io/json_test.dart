@Tags(['runtime', 'io'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Json', () {
    test('json.decode decodes empty list', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("[]")');
      checkResult(runtime, []);
    });

    test('json.decode decodes list of numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[1, 2, 3]")',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('json.decode decodes list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('[1, \"Hello\", true]')",
      );
      checkResult(runtime, [1, '"Hello"', true]);
    });

    test('json.decode decodes object with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('{\"name\": \"John\", \"age\": 42, \"married\": true, \"numbers\": [1, 2, 3]}')",
      );
      checkResult(runtime, {
        '"name"': '"John"',
        '"age"': 42,
        '"married"': true,
        '"numbers"': [1, 2, 3],
      });
    });

    test('json.encode encodes empty list', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode([])');
      checkResult(runtime, '"[]"');
    });

    test('json.encode encodes list of numbers', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode([1, 2, 3])');
      checkResult(runtime, '"[1,2,3]"');
    });

    test('json.encode encodes list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode([1, "Hello", true])',
      );
      checkResult(runtime, '"[1,"Hello",true]"');
    });

    test('json.encode encodes nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode([1, 2, [3, 4]])',
      );
      checkResult(runtime, '"[1,2,[3,4]]"');
    });

    test('json.encode encodes empty map', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode({})');
      checkResult(runtime, '"{}"');
    });

    test('json.encode encodes map with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode({"name": "John", "age": 42, "married": true, "numbers": [1, 2, 3]})',
      );
      checkResult(
        runtime,
        '"{"name":"John","age":42,"married":true,"numbers":[1,2,3]}"',
      );
    });
  });

  group('JSON Edge Cases', () {
    test('json.decode throws JsonParseError for invalid JSON string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("not json")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Invalid JSON'),
              contains('not json'),
            ),
          ),
        ),
      );
    });

    test('json.decode empty object', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("{}")');
      checkResult(runtime, {});
    });

    test('json.decode nested', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('{\"a\": {\"b\": 1}}')",
      );
      checkResult(runtime, {
        '"a"': {'"b"': 1},
      });
    });

    test('json.encode then decode roundtrip', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(json.encode([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('JSON Type Errors', () {
    test('json.encode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.decode throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Error Cases', () {
    test('json.decode throws JsonParseError for malformed object', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("{invalid}")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws JsonParseError for incomplete array', () {
      final RuntimeFacade runtime = getRuntime(r'main = json.decode("[1, 2,")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test(
      'json.decode throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = json.decode(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('json.decode with top-level null throws RuntimeError', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("null")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('JSON null values are not supported'),
          ),
        ),
      );
    });

    test('json.decode skips null values in objects', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('{\"name\": \"John\", \"age\": null}')",
      );
      checkResult(runtime, {'"name"': '"John"'});
    });

    test('json.decode filters null values from arrays', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode('[1, null, 3]')",
      );
      checkResult(runtime, [1, 3]);
    });
  });

  group('JSON Map Key Handling', () {
    test('json.decode correctly converts string keys to StringTerm', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"key": "value"}\')',
      );
      checkResult(runtime, {'"key"': '"value"'});
    });

    test('json.decode handles numeric string keys', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"123": "numeric key"}\')',
      );
      checkResult(runtime, {'"123"': '"numeric key"'});
    });

    test('json.decode handles empty string key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"": "empty key"}\')',
      );
      checkResult(runtime, {'""': '"empty key"'});
    });

    test('json.decode handles unicode keys', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"emoji\\u2764": "heart"}\')',
      );
      checkResult(runtime, {'"emoji❤"': '"heart"'});
    });
  });

  group('JSON Top-Level Primitives', () {
    test('json.decode top-level string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'"hello"\')',
      );
      checkResult(runtime, '"hello"');
    });

    test('json.decode top-level number integer', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("42")');
      checkResult(runtime, 42);
    });

    test('json.decode top-level number float', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("3.14")');
      checkResult(runtime, 3.14);
    });

    test('json.decode top-level boolean true', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("true")');
      checkResult(runtime, true);
    });

    test('json.decode top-level boolean false', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("false")');
      checkResult(runtime, false);
    });

    test('json.decode top-level negative number', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("-123")');
      checkResult(runtime, -123);
    });

    test('json.decode top-level scientific notation', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("1.5e10")');
      checkResult(runtime, 1.5e10);
    });
  });

  group('JSON Encode Type Errors', () {
    test('json.encode throws for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.encode throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.encode throws for false boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.encode(false)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Decode Error Edge Cases', () {
    test('json.decode throws JsonParseError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws JsonParseError for whitespace only', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("   ")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws JsonParseError for trailing comma in array', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode("[1, 2,]")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws JsonParseError for single quotes', () {
      final RuntimeFacade runtime = getRuntime(
        "main = json.decode(\"{'key': 'value'}\")",
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid JSON'),
          ),
        ),
      );
    });

    test('json.decode throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('json.decode throws InvalidArgumentTypesError for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode({"key": "value"})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Nested Structures', () {
    test('json.decode deeply nested arrays', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[[[1]]]")',
      );
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('json.decode deeply nested objects', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"a": {"b": {"c": 1}}}\')',
      );
      checkResult(runtime, {
        '"a"': {
          '"b"': {'"c"': 1},
        },
      });
    });

    test('json.decode array of objects', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'[{"a": 1}, {"b": 2}]\')',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('json.encode nested maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode({"outer": {"inner": 42}})',
      );
      checkResult(runtime, '"{"outer":{"inner":42}}"');
    });

    test('json.encode list containing maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode([{"a": 1}, {"b": 2}])',
      );
      checkResult(runtime, '"[{"a":1},{"b":2}]"');
    });

    test('json.encode map containing list of maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.encode({"items": [{"id": 1}, {"id": 2}]})',
      );
      checkResult(runtime, '"{"items":[{"id":1},{"id":2}]}"');
    });
  });

  group('JSON Special Characters', () {
    test('json.decode escaped newline', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = json.decode("{\"text\": \"line1\\nline2\"}")',
      );
      checkResult(runtime, {'"text"': '"line1\nline2"'});
    });

    test('json.decode escaped tab', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = json.decode("{\"text\": \"col1\\tcol2\"}")',
      );
      checkResult(runtime, {'"text"': '"col1\tcol2"'});
    });

    test('json.decode escaped backslash', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = json.decode("{\"path\": \"C:\\\\Users\"}")',
      );
      checkResult(runtime, {'"path"': r'"C:\Users"'});
    });

    test('json.decode escaped quotes', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = json.decode("{\"quote\": \"He said \\\"Hello\\\"\"}")',
      );
      checkResult(runtime, {'"quote"': '"He said "Hello""'});
    });
  });

  group('JSON Null Handling Edge Cases', () {
    test('json.decode array with multiple nulls', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[null, 1, null, 2, null]")',
      );
      checkResult(runtime, [1, 2]);
    });

    test('json.decode array with only nulls', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[null, null, null]")',
      );
      checkResult(runtime, []);
    });

    test('json.decode object with multiple null values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"a": null, "b": 1, "c": null}\')',
      );
      checkResult(runtime, {'"b"': 1});
    });

    test('json.decode object with all null values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"a": null, "b": null}\')',
      );
      checkResult(runtime, {});
    });

    test('json.decode nested null in object', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(\'{"outer": {"inner": null}}\')',
      );
      checkResult(runtime, {'"outer"': {}});
    });

    test('json.decode nested null in array', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("[[null, 1], [2, null]]")',
      );
      checkResult(runtime, [
        [1],
        [2],
      ]);
    });
  });

  group('JSON Roundtrip', () {
    test('json encode-decode roundtrip with map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(json.encode({"name": "Alice", "age": 30}))',
      );
      checkResult(runtime, {'"name"': '"Alice"', '"age"': 30});
    });

    test('json encode-decode roundtrip with nested structure', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(json.encode({"data": [1, 2, 3]}))',
      );
      checkResult(runtime, {
        '"data"': [1, 2, 3],
      });
    });

    test('json encode-decode roundtrip with empty structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode(json.encode({"empty_list": [], "empty_map": {}}))',
      );
      checkResult(runtime, {'"empty_list"': [], '"empty_map"': {}});
    });
  });

  group('JSON Error Message Truncation', () {
    test('json.decode truncates long invalid input in error message', () {
      final String longInput =
          'a' * 100; // Input longer than 50 chars to trigger truncation
      final RuntimeFacade runtime = getRuntime(
        'main = json.decode("$longInput")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<JsonParseError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Invalid JSON'),
              contains('...'), // Truncation indicator
              isNot(contains(longInput)), // Full input should not appear
            ),
          ),
        ),
      );
    });
  });
}
